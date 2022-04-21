import 'package:walletconnectdartv2/mock/mock_storage.dart';
import 'package:walletconnectdartv2/walletconnectdartv2.dart';

void main() async {
  var uri = WalletConnectURI.parse(
      'wc:3cf65a668f7665ae9e2e2139a3b6fffad379f23a7e92f32ee5bfca61e7bfe426@2?controller=false&publicKey=42f8273ba5b76586c59ac2249e00cbf0ede3df6cb48e5379c21c0360ac0b0b14&relay=%7B%22protocol%22%3A%22waku%22%7D');
  final client = Client(
      metadata: AppMetadata(
        name: "Bitizen",
        description: "BitizenWallet",
        url: "https://bitizen.org",
        icons: [
          "https://bitizen.org/wp-content/uploads/2021/07/cropped-cropped-lALPBGnDc6ar_GfNBADNBAA_1024_1024.png_720x720g-192x192.jpg"
        ],
      ),
      projectId: '', // TODO: set your project id
      relayHost: 'relay.walletconnect.com',
      kms: KeyManagementService(storage: MockStorage()));
  await client.approve(uri);
}
