import 'package:walletconnectdartv2/walletconnectdartv2.dart';

void main() {
  var uri1 = WalletConnectURI.parse(
      'wc://be93382bb37cc25e05fafe6e839929a5476b395a3204f9dff738ded1f5440709@2?controller=false&publicKey=8c3aa3a733e4594ee5466154310aac7898e9da5edd453bae6897665aa7f66e57&relay=%7B%22protocol%22%3A%22waku%22%7D');
  var uri2 = WalletConnectURI.parse(
      'wc:be93382bb37cc25e05fafe6e839929a5476b395a3204f9dff738ded1f5440709@2?controller=false&publicKey=8c3aa3a733e4594ee5466154310aac7898e9da5edd453bae6897665aa7f66e57&relay=%7B%22protocol%22%3A%22waku%22%7D');
  print('uri1: ${uri1.absoluteString}');
  print('uri2: ${uri2.absoluteString}');
  assert(uri1.absoluteString == uri2.absoluteString);
}
