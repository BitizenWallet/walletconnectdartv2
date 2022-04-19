// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RelayProtocolOptions _$RelayProtocolOptionsFromJson(
        Map<String, dynamic> json) =>
    RelayProtocolOptions(
      protocol: json['protocol'] as String,
      params:
          (json['params'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$RelayProtocolOptionsToJson(
    RelayProtocolOptions instance) {
  final val = <String, dynamic>{
    'protocol': instance.protocol,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('params', instance.params);
  return val;
}

PairingParticipant _$PairingParticipantFromJson(Map<String, dynamic> json) =>
    PairingParticipant(
      publicKey: json['publicKey'] as String,
    );

Map<String, dynamic> _$PairingParticipantToJson(PairingParticipant instance) =>
    <String, dynamic>{
      'publicKey': instance.publicKey,
    };

AppMetadata _$AppMetadataFromJson(Map<String, dynamic> json) => AppMetadata(
      name: json['name'] as String?,
      description: json['description'] as String?,
      url: json['url'] as String?,
      icons:
          (json['icons'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$AppMetadataToJson(AppMetadata instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'url': instance.url,
      'icons': instance.icons,
    };

PairingState _$PairingStateFromJson(Map<String, dynamic> json) => PairingState(
      metadata: json['metadata'] == null
          ? null
          : AppMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PairingStateToJson(PairingState instance) =>
    <String, dynamic>{
      'metadata': instance.metadata,
    };

PairingTypeApprovalParams _$PairingTypeApprovalParamsFromJson(
        Map<String, dynamic> json) =>
    PairingTypeApprovalParams(
      relay:
          RelayProtocolOptions.fromJson(json['relay'] as Map<String, dynamic>),
      responder: PairingParticipant.fromJson(
          json['responder'] as Map<String, dynamic>),
      expiry: json['expiry'] as int,
      state: json['state'] == null
          ? null
          : PairingState.fromJson(json['state'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PairingTypeApprovalParamsToJson(
        PairingTypeApprovalParams instance) =>
    <String, dynamic>{
      'relay': instance.relay,
      'responder': instance.responder,
      'expiry': instance.expiry,
      'state': instance.state,
    };

AgreementSecret _$AgreementSecretFromJson(Map<String, dynamic> json) =>
    AgreementSecret(
      sharedSecret:
          (json['sharedSecret'] as List<dynamic>).map((e) => e as int).toList(),
      publicKey: const SimplePublicKeyJsonConverter()
          .fromJson(json['publicKey'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AgreementSecretToJson(AgreementSecret instance) =>
    <String, dynamic>{
      'sharedSecret': instance.sharedSecret,
      'publicKey':
          const SimplePublicKeyJsonConverter().toJson(instance.publicKey),
    };

WCRequest<T> _$WCRequestFromJson<T extends Encodeable<T>>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    WCRequest<T>(
      id: json['id'] as int?,
      jsonrpc: json['jsonrpc'] as String? ?? "2.0",
      method: $enumDecode(_$WCRequestMethodEnumMap, json['method']),
      params: fromJsonT(json['params']),
    );

Map<String, dynamic> _$WCRequestToJson<T extends Encodeable<T>>(
  WCRequest<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'id': instance.id,
      'jsonrpc': instance.jsonrpc,
      'method': _$WCRequestMethodEnumMap[instance.method],
      'params': toJsonT(instance.params),
    };

const _$WCRequestMethodEnumMap = {
  WCRequestMethod.wcPairingApprove: 'wc_pairingApprove',
};
