import 'dart:developer';

import 'package:cryptography/cryptography.dart';
import 'package:walletconnectdartv2/src/key_managment_service.dart';
import 'package:walletconnectdartv2/walletconnectdartv2.dart';
import 'package:web_socket_channel/io.dart';

class Client {
  KeyManagementService kms;

  Client({required this.kms});

  Future<bool> approve(WalletConnectURI pairingUri) async {
    final proposal = PairingProposal.from(pairingUri);
    assert(!proposal.proposer.controller, 'Controller cannot approve');

    final metadata = AppMetadata(
      name: "Bitizen",
      description: "BitizenWallet",
      url: "https://bitizen.org",
      icons: [
        "https://bitizen.org/wp-content/uploads/2021/07/cropped-cropped-lALPBGnDc6ar_GfNBADNBAA_1024_1024.png_720x720g-192x192.jpg"
      ],
    );

    final relay = 'relay.walletconnect.com';

    var channel = IOWebSocketChannel.connect(Uri.parse('wss://$relay'));

    channel.stream.listen((message) {
      log("bingo channel listen $message");
    });

    SimplePublicKey selfPublicKey = await kms.createX25519KeyPair();
    AgreementSecret agreementSecret = await kms.performKeyAgreement(
        selfPublicKey: selfPublicKey,
        peerPublicKeyHex: proposal.proposer.publicKey);

    final settledTopic = await agreementSecret.derivedTopic();

    final params = PairingTypeApprovalParams(
      relay: proposal.relay,
      responder: PairingParticipant(publicKey: selfPublicKey.bytes.hexWith0x),
      expiry: (DateTime.now().millisecondsSinceEpoch / 1000 +
              proposal.ttl.inSeconds)
          .toInt(),
    );

    final req =
        WCRequest(method: WCRequestMethod.wcPairingApprove, params: params);

    await kms.serialize(req, proposal.topic);
    return true;
  }
}
