import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:cryptography/cryptography.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:walletconnectdartv2/walletconnectdartv2.dart';

part 'types.g.dart';

@JsonSerializable(includeIfNull: false)
class RelayProtocolOptions {
  String protocol;
  List<String>? params;

  RelayProtocolOptions({required this.protocol, this.params});

  factory RelayProtocolOptions.fromJson(Map<String, dynamic> json) =>
      _$RelayProtocolOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$RelayProtocolOptionsToJson(this);
}

class WalletConnectURI {
  String topic;
  String version;
  String publicKey;
  bool isController;
  RelayProtocolOptions relay;

  WalletConnectURI(
      {required this.topic,
      required this.version,
      required this.publicKey,
      required this.isController,
      required this.relay});

  String get absoluteString =>
      'wc:$topic@$version?controller=$isController&publicKey=$publicKey&relay=${Uri.encodeComponent(jsonEncode(relay))}';

  factory WalletConnectURI.parse(String uriString) {
    if (!uriString.startsWith('wc:')) {
      throw ArgumentError('Invalid walletconnect URI');
    }

    uriString = !uriString.startsWith("wc://")
        ? uriString.replaceFirst("wc:", "wc://")
        : uriString;

    final uri = Uri.parse(uriString);

    return WalletConnectURI(
      topic: uri.userInfo,
      version: uri.host,
      publicKey: uri.queryParameters['publicKey']!,
      isController: uri.queryParameters['controller'] == 'true',
      relay: RelayProtocolOptions.fromJson(
          jsonDecode(uri.queryParameters['relay']!)),
    );
  }
}

class PairingTypeJSONRPC {
  List<String> methods;

  PairingTypeJSONRPC({required this.methods});

  static final payloadMethodSessionPropose = "wc_sessionPropose";
}

@JsonSerializable(includeIfNull: false)
class PairingParticipant {
  String publicKey;
  PairingParticipant({required this.publicKey});

  factory PairingParticipant.fromJson(Map<String, dynamic> json) =>
      _$PairingParticipantFromJson(json);

  Map<String, dynamic> toJson() => _$PairingParticipantToJson(this);
}

@JsonSerializable(includeIfNull: false)
class AppMetadata {
  String? name;
  String? description;
  String? url;
  List<String>? icons;

  AppMetadata({
    this.name,
    this.description,
    this.url,
    this.icons,
  });

  factory AppMetadata.fromJson(Map<String, dynamic> json) =>
      _$AppMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$AppMetadataToJson(this);
}

@JsonSerializable(includeIfNull: false)
class PairingState {
  AppMetadata? metadata;

  PairingState({this.metadata});

  factory PairingState.fromJson(Map<String, dynamic> json) =>
      _$PairingStateFromJson(json);

  Map<String, dynamic> toJson() => _$PairingStateToJson(this);
}

@JsonSerializable(includeIfNull: false)
class PairingTypeApprovalParams
    implements Encodeable<PairingTypeApprovalParams> {
  RelayProtocolOptions relay;
  PairingParticipant responder;
  int expiry;
  PairingState? state;

  PairingTypeApprovalParams({
    required this.relay,
    required this.responder,
    required this.expiry,
    this.state,
  });

  factory PairingTypeApprovalParams.fromJson(Map<String, dynamic> json) =>
      _$PairingTypeApprovalParamsFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PairingTypeApprovalParamsToJson(this);
}

class PairingProposer {
  String publicKey;
  bool controller;

  PairingProposer({required this.publicKey, required this.controller});
}

class PairingSignalParams {
  String uri;
  PairingSignalParams({required this.uri});
}

class PairingSignal {
  String type;
  PairingSignalParams params;

  PairingSignal({required this.type, required this.params});

  factory PairingSignal.from({required String uri}) {
    return PairingSignal(type: 'uri', params: PairingSignalParams(uri: uri));
  }
}

class ProposedPermissions {
  PairingTypeJSONRPC jsonrpc;
  ProposedPermissions({required this.jsonrpc});

  static ProposedPermissions defaultPermissions = ProposedPermissions(
      jsonrpc: PairingTypeJSONRPC(
          methods: [PairingTypeJSONRPC.payloadMethodSessionPropose]));
}

@DurationJsonConverter()
class PairingProposal {
  String topic;
  RelayProtocolOptions relay;
  PairingProposer proposer;
  PairingSignal signal;
  ProposedPermissions permissions;
  Duration ttl;

  PairingProposal({
    required this.topic,
    required this.relay,
    required this.proposer,
    required this.signal,
    required this.permissions,
    required this.ttl,
  });

  factory PairingProposal.from(WalletConnectURI uri) {
    return PairingProposal(
        topic: uri.topic,
        relay: uri.relay,
        proposer: PairingProposer(
            controller: uri.isController, publicKey: uri.publicKey),
        signal: PairingSignal.from(uri: uri.absoluteString),
        permissions: ProposedPermissions.defaultPermissions,
        ttl: PairingSequence.timeToLiveSettled);
  }
}

class PairingSequence {
  static Duration timeToLiveSettled = Duration(days: 30);
}

@JsonSerializable(includeIfNull: false)
@SimplePublicKeyJsonConverter()
class AgreementSecret implements Encodeable<AgreementSecret> {
  List<int> sharedSecret;
  SimplePublicKey publicKey;

  AgreementSecret({required this.sharedSecret, required this.publicKey});

  Future<String> derivedTopic() async {
    final hash = await Sha256().hash(sharedSecret);
    return hash.bytes.hexWithout0x;
  }

  factory AgreementSecret.fromJson(Map<String, dynamic> json) =>
      _$AgreementSecretFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AgreementSecretToJson(this);
}

enum WCRequestMethod {
  @JsonValue("wc_pairingApprove")
  wcPairingApprove,
}

extension WCRequestMethodExtension on WCRequestMethod {
  bool get shouldPrompt {
    switch (this) {
      // TODO .sessionPayload, .pairingPayload
      default:
        return false;
    }
  }
}

@JsonSerializable(genericArgumentFactories: true, includeIfNull: false)
class WCRequest<T extends Encodeable<T>> implements Encodeable<WCRequest> {
  int id = generateId();
  String jsonrpc;
  WCRequestMethod method;
  T params;

  WCRequest({
    int? id,
    this.jsonrpc = "2.0",
    required this.method,
    required this.params,
  }) {
    if (id != null) {
      this.id = id;
    }
  }

  factory WCRequest.fromJson(Map<String, dynamic> json) {
    return _$WCRequestFromJson(
        json, (Object? json) => Encodeable.fromJsonMixin<T>(json)!);
  }

  @override
  Map<String, dynamic> toJson() {
    return _$WCRequestToJson(this, (T t) => t.toJson());
  }
}

class EncryptionPayload {
  List<int> iv;
  List<int> publicKey;
  List<int> mac;
  List<int> cipherText;

  EncryptionPayload(
      {required this.iv,
      required this.publicKey,
      required this.mac,
      required this.cipherText});

  static int ivLength = 16;
  static int publicKeyLength = 32;
  static int macLength = 32;
}

const Duration relayDefaultTtl = Duration(hours: 6);

enum RelayJSONRPCMethod {
  @JsonValue("waku_subscribe")
  subscribe,
  @JsonValue("waku_publish")
  publish,
  @JsonValue("waku_subscription")
  subscription,
  @JsonValue("waku_unsubscribe")
  unsubscribe,
}

@JsonSerializable(includeIfNull: false)
@DurationJsonConverter()
class RelayJSONRPCPublishParams
    implements Encodeable<RelayJSONRPCPublishParams> {
  String topic;
  String message;
  Duration ttl;
  bool? prompt;
  RelayJSONRPCPublishParams({
    required this.topic,
    required this.message,
    required this.ttl,
    this.prompt,
  });

  factory RelayJSONRPCPublishParams.fromJson(Map<String, dynamic> json) {
    return _$RelayJSONRPCPublishParamsFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    return _$RelayJSONRPCPublishParamsToJson(this);
  }
}

@JsonSerializable(genericArgumentFactories: true, includeIfNull: false)
class JSONRPCRequest<T extends Encodeable<T>> {
  int id = generateId();
  String jsonrpc;
  RelayJSONRPCMethod? method;
  T params;

  JSONRPCRequest({
    required this.params,
    int? id,
    this.jsonrpc = "2.0",
    this.method,
  }) {
    if (id != null) {
      this.id = id;
    }
  }

  factory JSONRPCRequest.fromJson(Map<String, dynamic> json) {
    log("JSONRPCRequest.fromJson $T $json", name: packageName);
    return _$JSONRPCRequestFromJson(
        json, (Object? json) => Encodeable.fromJsonMixin<T>(json)!);
  }

  Map<String, dynamic> toJson() {
    return _$JSONRPCRequestToJson(this, (T t) => t.toJson());
  }
}

@JsonSerializable(includeIfNull: false)
class JSONRPCErrorResponseError {
  int code;
  String message;
  JSONRPCErrorResponseError({required this.code, required this.message});

  factory JSONRPCErrorResponseError.fromJson(Map<String, dynamic> json) {
    return _$JSONRPCErrorResponseErrorFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$JSONRPCErrorResponseErrorToJson(this);
  }
}

@JsonSerializable(includeIfNull: false, genericArgumentFactories: true)
class JSONRPCResponse<T extends Encodeable<T>> {
  String jsonrpc;
  int id;
  T result;

  JSONRPCResponse({
    required this.id,
    required this.result,
    this.jsonrpc = "2.0",
  });

  factory JSONRPCResponse.fromJson(Map<String, dynamic> json) {
    log("JSONRPCResponse.fromJson $T $json", name: packageName);
    return _$JSONRPCResponseFromJson(
        json, (Object? json) => Encodeable.fromJsonMixin<T>(json)!);
  }

  Map<String, dynamic> toJson() {
    return _$JSONRPCResponseToJson(this, (T t) => t.toJson());
  }
}

@JsonSerializable(includeIfNull: false)
class JSONRPCErrorResponse {
  String jsonrpc;
  int id;
  JSONRPCErrorResponseError error;

  JSONRPCErrorResponse(
      {required this.id, required this.error, this.jsonrpc = "2.0"});

  factory JSONRPCErrorResponse.fromJson(Map<String, dynamic> json) {
    return _$JSONRPCErrorResponseFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$JSONRPCErrorResponseToJson(this);
  }
}

@JsonSerializable(includeIfNull: false)
class RelayJSONRPCSubscribeParams
    implements Encodeable<RelayJSONRPCSubscribeParams> {
  String topic;
  RelayJSONRPCSubscribeParams({
    required this.topic,
  });

  factory RelayJSONRPCSubscribeParams.fromJson(Map<String, dynamic> json) {
    return _$RelayJSONRPCSubscribeParamsFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    return _$RelayJSONRPCSubscribeParamsToJson(this);
  }
}

@JsonSerializable(includeIfNull: false)
class RelayJSONRPCSubscriptionData {
  String topic;
  String message;

  RelayJSONRPCSubscriptionData({
    required this.topic,
    required this.message,
  });

  factory RelayJSONRPCSubscriptionData.fromJson(Map<String, dynamic> json) {
    return _$RelayJSONRPCSubscriptionDataFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$RelayJSONRPCSubscriptionDataToJson(this);
  }
}

@JsonSerializable(includeIfNull: false)
class RelayJSONRPCSubscriptionParams
    implements Encodeable<RelayJSONRPCSubscriptionParams> {
  String id;
  RelayJSONRPCSubscriptionData data;

  RelayJSONRPCSubscriptionParams({
    required this.id,
    required this.data,
  });

  factory RelayJSONRPCSubscriptionParams.fromJson(Map<String, dynamic> json) {
    return _$RelayJSONRPCSubscriptionParamsFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    return _$RelayJSONRPCSubscriptionParamsToJson(this);
  }
}

int generateId() {
  return DateTime.now().millisecondsSinceEpoch * 1000 +
      math.Random().nextInt(1000);
}
