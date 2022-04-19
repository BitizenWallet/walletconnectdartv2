import 'dart:convert';
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
    return keyPair.extractPublicKey();
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

  _setAgreementSecret(String topic, AgreementSecret secret) async {
    final ok = await storage.write(
        "agms::$topic", Uint8List.fromList(jsonEncode(secret).bytes));
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
        SimplePublicKey(peerPublicKeyHex.bytes, type: KeyPairType.x25519);
    final SecretKey sharedSecret = await algorithm.sharedSecretKey(
        keyPair: selfPrivateKey, remotePublicKey: peerPublicKey);
    final sharedSecretBytes = await sharedSecret.extractBytes();
    return AgreementSecret(
        sharedSecret: Uint8List.fromList(sharedSecretBytes),
        publicKey: await selfPrivateKey.extractPublicKey());
  }

  Future<String> serialize<T>(T req, String topic) async {
    String json = jsonEncode(req);
    final agreementSecret = await _getAgreementSecret(topic);
    if (agreementSecret != null) {
      final payload = await _encrypt(json, agreementSecret);
      return '${payload.iv.hexWithout0x}${payload.publicKey.hexWithout0x}${payload.mac.hexWithout0x}${payload.cipherText.hexWithout0x}';
    }
    return json.bytes.hexWithout0x;
  }

  /// _getKeyPair returns a tuple of (encryptionKey, authenticationKey)
  Tuple2<List<int>, List<int>> _getKeyPair(List<int> sharedSecret) {
    assert(sharedSecret.length == 64, 'Invalid shared secret');
    return Tuple2(sharedSecret.sublist(0, 32), sharedSecret.sublist(32, 64));
  }

  Future<EncryptionPayload> _encrypt(
      String json, AgreementSecret agreementSecret) async {
    // encrypt
    final keyPair = _getKeyPair(agreementSecret.sharedSecret);
    final aesCbc256 = AesCbc.with256bits(macAlgorithm: MacAlgorithm.empty);
    final iv = aesCbc256.newNonce();
    final cipher = await aesCbc256.encrypt(json.bytes,
        secretKey: SecretKey(keyPair.item1), nonce: iv);

    // encode
    final dataToMac = iv;
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
}
