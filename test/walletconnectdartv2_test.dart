import 'package:cryptography/cryptography.dart';
import 'package:walletconnectdartv2/mock/mock_storage.dart';
import 'package:walletconnectdartv2/src/key_managment_service.dart';
import 'package:walletconnectdartv2/walletconnectdartv2.dart';
import 'package:test/test.dart';

void main() {
  final rawUri =
      'wc:be93382bb37cc25e05fafe6e839929a5476b395a3204f9dff738ded1f5440709@2?controller=false&publicKey=8c3aa3a733e4594ee5466154310aac7898e9da5edd453bae6897665aa7f66e57&relay=%7B%22protocol%22%3A%22waku%22%7D';

  group('A group of tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('WalletConnect URI parse', () {
      final wcUri = WalletConnectURI.parse(rawUri);
      expect(wcUri.absoluteString, rawUri);
    });

    test('serialize and deserialize SimpleKeyPair', () async {
      final x25519 = Cryptography.instance.x25519();
      final kpOld = await x25519.newKeyPair();
      final kpOldPubkeyBytes = (await kpOld.extractPublicKey()).bytes;
      final kpNew =
          await x25519.newKeyPairFromSeed(await kpOld.extractPrivateKeyBytes());
      final kpNewPubkeyBytes = (await kpNew.extractPublicKey()).bytes;
      expect(kpOldPubkeyBytes, kpNewPubkeyBytes);
    });

    test('test approve', () async {
      final wcUri = WalletConnectURI.parse(rawUri);
      final client = Client(kms: KeyManagementService(storage: MockStorage()));
      await client.approve(wcUri);
    });
  });
}
