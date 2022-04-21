import 'dart:convert';
import 'dart:developer';

import 'package:cryptography/cryptography.dart';

import 'package:walletconnectdartv2/walletconnectdartv2.dart';
import 'package:web_socket_channel/io.dart';

class Client {
  KeyManagementService kms;
  AppMetadata metadata;
  String projectId;
  String relayHost;

  late IOWebSocketChannel channel;

  Client(
      {required this.kms,
      required this.metadata,
      required this.relayHost,
      required this.projectId}) {
    channel = IOWebSocketChannel.connect(
        Uri.parse('wss://$relayHost?projectId=$projectId'));
    channel.stream.listen(_onWcMessage);
  }

  Future<bool> approve(WalletConnectURI pairingUri) async {
    final proposal = PairingProposal.from(pairingUri);
    assert(!proposal.proposer.controller, 'Controller cannot approve');

    SimplePublicKey selfPublicKey = await kms.createX25519KeyPair();
    AgreementSecret agreementSecret = await kms.performKeyAgreement(
        selfPublicKey: selfPublicKey,
        peerPublicKeyHex: proposal.proposer.publicKey);

    final settledTopic = await agreementSecret.derivedTopic();

    channel.sink.add(jsonEncode(JSONRPCRequest(
            method: RelayJSONRPCMethod.subscribe,
            params: RelayJSONRPCSubscribeParams(topic: proposal.topic))
        .toJson()));
    channel.sink.add(jsonEncode(JSONRPCRequest(
            method: RelayJSONRPCMethod.subscribe,
            params: RelayJSONRPCSubscribeParams(topic: settledTopic))
        .toJson()));

    await kms.setAgreementSecret(settledTopic, agreementSecret);

    final approvalParams = PairingTypeApprovalParams(
      relay: proposal.relay,
      responder:
          PairingParticipant(publicKey: selfPublicKey.bytes.hexWithout0x),
      expiry: (DateTime.now().millisecondsSinceEpoch / 1000 +
              proposal.ttl.inSeconds)
          .toInt(),
    );

    final req = WCRequest(
        method: WCRequestMethod.wcPairingApprove, params: approvalParams);

    final msg = await kms.serialize(req, proposal.topic);

    final publishParams = RelayJSONRPCPublishParams(
        topic: proposal.topic,
        message: msg,
        ttl: relayDefaultTtl,
        prompt: req.method.shouldPrompt);

    final wkReq = JSONRPCRequest(
        method: RelayJSONRPCMethod.publish, params: publishParams);

    log("wkReq ${proposal.topic} ${jsonEncode(wkReq.toJson())}",
        name: packageName);

    channel.sink.add(jsonEncode(wkReq.toJson()));
    return true;
  }

  void _onWcMessage(event) {
    log("_onWcMessage ${event.runtimeType} $event", name: packageName);
    final subscription = _tryDecode(
        event, JSONRPCRequest<RelayJSONRPCSubscriptionParams>.fromJson);
    if (subscription != null &&
        subscription.method == RelayJSONRPCMethod.subscription) {
      final data = kms.deserialize<WCRequest<EncodeableWrap<dynamic>>>(
          subscription.params.data.topic, subscription.params.data.message);
      log("bingo _onWcMessage $data");
      return;
    }
    final requestAcknowledgement =
        _tryDecode(event, JSONRPCResponse<EncodeableWrap<bool>>.fromJson);
    if (requestAcknowledgement != null) {
      return;
    }
    final subscriptionResponse =
        _tryDecode(event, JSONRPCResponse<EncodeableWrap<String>>.fromJson);
    if (subscriptionResponse != null) {
      return;
    }
    final responseError = _tryDecode(event, JSONRPCErrorResponseError.fromJson);
    if (responseError != null) {
      return;
    }
  }

  T? _tryDecode<T>(
      dynamic event, T Function(Map<String, dynamic> json) decoder) {
    try {
      final obj = decoder(jsonDecode(event));
      log("_tryDecode $T successful", name: packageName);
      return obj;
    } catch (e) {
      log("_tryDecode $T error: $e", name: packageName);
      return null;
    }
  }
}
