import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:tuple/tuple.dart';
import 'package:walletconnectdartv2/walletconnectdartv2.dart';

class KeyManagementService {
  Storage storage;

  KeyManagementService({required this.storage});

  Future<SimplePublicKey> createX25519KeyPair() async {
    final algorithm = Cryptography.instance.x25519();
    final SimpleKeyPair keyPair = await algorithm.newKeyPair();
    final SimplePublicKey pubkey = await keyPair.extractPublicKey();
    await _setPrivateKey(pubkey.bytes.hexWith0x, keyPair);
    return pubkey;
  }

  Future<SimpleKeyPair?> _getPrivateKey(String pubkeyHash) async {
    final data = await storage.read('prik::' + pubkeyHash);
    if (data == null) {
      return null;
    }
    final algorithm = Cryptography.instance.x25519();
    final keyPair = await algorithm.newKeyPairFromSeed(data);
    return keyPair;
  }

  _setPrivateKey(String pubkeyHash, SimpleKeyPair keyPair) async {
    final ok = await storage.write("prik::$pubkeyHash",
        Uint8List.fromList(await keyPair.extractPrivateKeyBytes()));
    assert(ok, 'Failed to write private key');
  }

  Future<AgreementSecret?> _getAgreementSecret(String topic) async {
    final data = await storage.read('agms::' + topic);
    if (data == null) {
      return null;
    }
    return AgreementSecret.fromJson(jsonDecode(String.fromCharCodes(data)));
  }

  setAgreementSecret(String topic, AgreementSecret secret) async {
    final ok = await storage.write(
        "agms::$topic", Uint8List.fromList(jsonEncode(secret).codeUnits));
    assert(ok, 'Failed to write agreement secret');
  }

  Future<AgreementSecret> performKeyAgreement(
      {required SimplePublicKey selfPublicKey,
      required String peerPublicKeyHex}) async {
    final privateKey = await _getPrivateKey(selfPublicKey.bytes.hexWith0x);
    assert(privateKey != null, 'Private key not found');
    return generateAgreementSecret(
        selfPrivateKey: privateKey!, peerPublicKeyHex: peerPublicKeyHex);
  }

  static Future<AgreementSecret> generateAgreementSecret(
      {required SimpleKeyPair selfPrivateKey,
      required String peerPublicKeyHex}) async {
    final algorithm = Cryptography.instance.x25519();
    final peerPublicKey =
        SimplePublicKey(peerPublicKeyHex.hexDecode, type: KeyPairType.x25519);
    final SecretKey sharedSecret = await algorithm.sharedSecretKey(
        keyPair: selfPrivateKey, remotePublicKey: peerPublicKey);
    final sharedSecretBytes = await sharedSecret.extractBytes();
    return AgreementSecret(
        sharedSecret: Uint8List.fromList(sharedSecretBytes),
        publicKey: await selfPrivateKey.extractPublicKey());
  }

  Future<String> serialize<T extends Encodeable>(T req, String topic) async {
    String json = jsonEncode(req.toJson());
    log("serialize req $json", name: packageName);
    final agreementSecret = await _getAgreementSecret(topic);
    if (agreementSecret != null) {
      final payload = await _encrypt(json, agreementSecret);
      return '${payload.iv.hexWithout0x}${payload.publicKey.hexWithout0x}${payload.mac.hexWithout0x}${payload.cipherText.hexWithout0x}';
    }
    return json.codeUnits.hexWithout0x;
  }

  Future<T> deserialize<T extends Encodeable>(
      String topic, String message) async {
    final agreementSecret = await _getAgreementSecret(topic);
    if (agreementSecret != null) {
      final payload = await _decrypt(message, agreementSecret);
      return Encodeable.fromJsonMixin<T>(jsonDecode(payload))!;
    }
    return Encodeable.fromJsonMixin<T>(
        jsonDecode(String.fromCharCodes(message.hexDecode)))!;
  }

  /// _getKeyPair returns a tuple of (encryptionKey, authenticationKey)
  Future<Tuple2<List<int>, List<int>>> _getKeyPair(
      List<int> sharedSecret) async {
    final hash = await Sha512().hash(sharedSecret);
    return Tuple2(hash.bytes.sublist(0, 32), hash.bytes.sublist(32, 64));
  }

  Future<EncryptionPayload> _encrypt(
      String json, AgreementSecret agreementSecret) async {
    // encrypt
    final keyPair = await _getKeyPair(agreementSecret.sharedSecret);
    final aesCbc256 = AesCbc.with256bits(macAlgorithm: MacAlgorithm.empty);
    final iv = aesCbc256.newNonce();
    final cipher = await aesCbc256.encrypt(json.codeUnits,
        secretKey: SecretKey(keyPair.item1), nonce: iv);

    // encode
    final List<int> dataToMac = [];
    dataToMac.addAll(iv);
    dataToMac.addAll(agreementSecret.publicKey.bytes);
    dataToMac.addAll(cipher.cipherText);

    final mac = await Hmac.sha256()
        .calculateMac(dataToMac, secretKey: SecretKey(keyPair.item2));
    return EncryptionPayload(
        iv: iv,
        publicKey: agreementSecret.publicKey.bytes,
        mac: mac.bytes,
        cipherText: cipher.cipherText);
  }

  Future<String> _decrypt(
      String message, AgreementSecret agreementSecret) async {
    final cipherData = message.codeUnits;
    assert(
        cipherData.length >
            EncryptionPayload.ivLength +
                EncryptionPayload.macLength +
                EncryptionPayload.publicKeyLength,
        'message too short');

    // decode

    final pubKeyRangeStartIndex = EncryptionPayload.ivLength;
    final macStartIndex =
        pubKeyRangeStartIndex + EncryptionPayload.publicKeyLength;
    final cipherTextStartIndex = macStartIndex + EncryptionPayload.macLength;

    final iv = cipherData.sublist(0, pubKeyRangeStartIndex);
    final pubKey = cipherData.sublist(pubKeyRangeStartIndex, macStartIndex);
    final mac = cipherData.sublist(macStartIndex, cipherTextStartIndex);
    final cipherText = cipherData.sublist(cipherTextStartIndex);

    final payload = EncryptionPayload(
        iv: iv, publicKey: pubKey, mac: mac, cipherText: cipherText);

    // checksum

    final keyPair = await _getKeyPair(agreementSecret.sharedSecret);
    final List<int> dataToMac = [];
    dataToMac.addAll(iv);
    dataToMac.addAll(payload.publicKey);
    dataToMac.addAll(payload.cipherText);
    assert(
        payload.mac ==
            (await Hmac.sha256().calculateMac(dataToMac,
                    secretKey: SecretKey(keyPair.item2)))
                .bytes,
        'MAC mismatch');

    // decrypt

    final aesCbc256 = AesCbc.with256bits(macAlgorithm: MacAlgorithm.empty);
    final plainData = await aesCbc256.decrypt(
        SecretBox(cipherText, nonce: iv, mac: Mac.empty),
        secretKey: SecretKey(keyPair.item1));

    return String.fromCharCodes(plainData);
  }
}
