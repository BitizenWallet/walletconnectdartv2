import 'dart:convert';
import 'dart:math';

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

@JsonSerializable()
class PairingParticipant {
  String publicKey;
  PairingParticipant({required this.publicKey});

  factory PairingParticipant.fromJson(Map<String, dynamic> json) =>
      _$PairingParticipantFromJson(json);

  Map<String, dynamic> toJson() => _$PairingParticipantToJson(this);
}

@JsonSerializable()
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

@JsonSerializable()
class PairingState {
  AppMetadata? metadata;

  PairingState({this.metadata});

  factory PairingState.fromJson(Map<String, dynamic> json) =>
      _$PairingStateFromJson(json);

  Map<String, dynamic> toJson() => _$PairingStateToJson(this);
}

@JsonSerializable()
class PairingTypeApprovalParams extends Encodeable<PairingTypeApprovalParams> {
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

  @override
  PairingTypeApprovalParams fromJson(Object? json) {
    return fromJson(json);
  }
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

class SimplePublicKeyJsonConverter
    implements JsonConverter<SimplePublicKey, Map<String, dynamic>> {
  const SimplePublicKeyJsonConverter();
  @override
  Map<String, dynamic> toJson(SimplePublicKey key) {
    assert(key.type.name == 'x25519', 'Only x25519 keys are supported');
    return {
      'type': 'x25519',
      'bytes': key.bytes.hexWith0x,
    };
  }

  @override
  SimplePublicKey fromJson(Map<String, dynamic> json) {
    assert(json['type'] == 'x25519', 'Invalid public key type');
    return SimplePublicKey(
      (json['bytes'] as String).bytes,
      type: KeyPairType.x25519,
    );
  }
}

@JsonSerializable()
@SimplePublicKeyJsonConverter()
class AgreementSecret extends Encodeable<AgreementSecret> {
  List<int> sharedSecret;
  SimplePublicKey publicKey;

  AgreementSecret({required this.sharedSecret, required this.publicKey});

  Future<String> derivedTopic() async {
    final hash = await Sha256().hash(sharedSecret);
    return hash.bytes.hexWith0x;
  }

  factory AgreementSecret.fromJson(Map<String, dynamic> json) =>
      _$AgreementSecretFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AgreementSecretToJson(this);

  @override
  AgreementSecret fromJson(Object? json) {
    return fromJson(json);
  }
}

abstract class Encodeable<T> {
  Map<String, dynamic> toJson();
  T fromJson(Object? json);
}

enum WCRequestMethod {
  @JsonValue("wc_pairingApprove")
  wcPairingApprove,
}

@JsonSerializable(genericArgumentFactories: true)
class WCRequest<T extends Encodeable<T>> {
  late int id;
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
    } else {
      id = generateId();
    }
  }

  factory WCRequest.fromJson(Map<String, dynamic> json) {
    return _$WCRequestFromJson(
        json, (Object? json) => (T as Encodeable).fromJson(json));
  }

  Map<String, dynamic> toJson() {
    return _$WCRequestToJson(this, (T t) => t.toJson());
  }

  static int generateId() {
    return DateTime.now().millisecondsSinceEpoch * 1000 +
        Random().nextInt(1000);
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
}
