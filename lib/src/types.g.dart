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

Map<String, dynamic> _$AppMetadataToJson(AppMetadata instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  writeNotNull('description', instance.description);
  writeNotNull('url', instance.url);
  writeNotNull('icons', instance.icons);
  return val;
}

PairingState _$PairingStateFromJson(Map<String, dynamic> json) => PairingState(
      metadata: json['metadata'] == null
          ? null
          : AppMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PairingStateToJson(PairingState instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('metadata', instance.metadata);
  return val;
}

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
    PairingTypeApprovalParams instance) {
  final val = <String, dynamic>{
    'relay': instance.relay,
    'responder': instance.responder,
    'expiry': instance.expiry,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('state', instance.state);
  return val;
}

AgreementSecret _$AgreementSecretFromJson(Map<String, dynamic> json) =>
    AgreementSecret(
      sharedSecret:
          (json['sharedSecret'] as List<dynamic>).map((e) => e as int).toList(),
      publicKey: const SimplePublicKeyJsonConverter()
          .fromJson(json['publicKey'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AgreementSecretToJson(AgreementSecret instance) {
  final val = <String, dynamic>{
    'sharedSecret': instance.sharedSecret,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('publicKey',
      const SimplePublicKeyJsonConverter().toJson(instance.publicKey));
  return val;
}

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

RelayJSONRPCPublishParams _$RelayJSONRPCPublishParamsFromJson(
        Map<String, dynamic> json) =>
    RelayJSONRPCPublishParams(
      topic: json['topic'] as String,
      message: json['message'] as String,
      ttl: const DurationJsonConverter().fromJson(json['ttl'] as int),
      prompt: json['prompt'] as bool?,
    );

Map<String, dynamic> _$RelayJSONRPCPublishParamsToJson(
    RelayJSONRPCPublishParams instance) {
  final val = <String, dynamic>{
    'topic': instance.topic,
    'message': instance.message,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('ttl', const DurationJsonConverter().toJson(instance.ttl));
  writeNotNull('prompt', instance.prompt);
  return val;
}

JSONRPCRequest<T> _$JSONRPCRequestFromJson<T extends Encodeable<T>>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    JSONRPCRequest<T>(
      params: fromJsonT(json['params']),
      id: json['id'] as int?,
      jsonrpc: json['jsonrpc'] as String? ?? "2.0",
      method: $enumDecodeNullable(_$RelayJSONRPCMethodEnumMap, json['method']),
    );

Map<String, dynamic> _$JSONRPCRequestToJson<T extends Encodeable<T>>(
  JSONRPCRequest<T> instance,
  Object? Function(T value) toJsonT,
) {
  final val = <String, dynamic>{
    'id': instance.id,
    'jsonrpc': instance.jsonrpc,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('method', _$RelayJSONRPCMethodEnumMap[instance.method]);
  val['params'] = toJsonT(instance.params);
  return val;
}

const _$RelayJSONRPCMethodEnumMap = {
  RelayJSONRPCMethod.subscribe: 'waku_subscribe',
  RelayJSONRPCMethod.publish: 'waku_publish',
  RelayJSONRPCMethod.subscription: 'waku_subscription',
  RelayJSONRPCMethod.unsubscribe: 'waku_unsubscribe',
};

JSONRPCErrorResponseError _$JSONRPCErrorResponseErrorFromJson(
        Map<String, dynamic> json) =>
    JSONRPCErrorResponseError(
      code: json['code'] as int,
      message: json['message'] as String,
    );

Map<String, dynamic> _$JSONRPCErrorResponseErrorToJson(
        JSONRPCErrorResponseError instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
    };

JSONRPCResponse<T> _$JSONRPCResponseFromJson<T extends Encodeable<T>>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    JSONRPCResponse<T>(
      id: json['id'] as int,
      result: fromJsonT(json['result']),
      jsonrpc: json['jsonrpc'] as String? ?? "2.0",
    );

Map<String, dynamic> _$JSONRPCResponseToJson<T extends Encodeable<T>>(
  JSONRPCResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'jsonrpc': instance.jsonrpc,
      'id': instance.id,
      'result': toJsonT(instance.result),
    };

JSONRPCErrorResponse _$JSONRPCErrorResponseFromJson(
        Map<String, dynamic> json) =>
    JSONRPCErrorResponse(
      id: json['id'] as int,
      error: JSONRPCErrorResponseError.fromJson(
          json['error'] as Map<String, dynamic>),
      jsonrpc: json['jsonrpc'] as String? ?? "2.0",
    );

Map<String, dynamic> _$JSONRPCErrorResponseToJson(
        JSONRPCErrorResponse instance) =>
    <String, dynamic>{
      'jsonrpc': instance.jsonrpc,
      'id': instance.id,
      'error': instance.error,
    };

RelayJSONRPCSubscribeParams _$RelayJSONRPCSubscribeParamsFromJson(
        Map<String, dynamic> json) =>
    RelayJSONRPCSubscribeParams(
      topic: json['topic'] as String,
    );

Map<String, dynamic> _$RelayJSONRPCSubscribeParamsToJson(
        RelayJSONRPCSubscribeParams instance) =>
    <String, dynamic>{
      'topic': instance.topic,
    };

RelayJSONRPCSubscriptionData _$RelayJSONRPCSubscriptionDataFromJson(
        Map<String, dynamic> json) =>
    RelayJSONRPCSubscriptionData(
      topic: json['topic'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$RelayJSONRPCSubscriptionDataToJson(
        RelayJSONRPCSubscriptionData instance) =>
    <String, dynamic>{
      'topic': instance.topic,
      'message': instance.message,
    };

RelayJSONRPCSubscriptionParams _$RelayJSONRPCSubscriptionParamsFromJson(
        Map<String, dynamic> json) =>
    RelayJSONRPCSubscriptionParams(
      id: json['id'] as String,
      data: RelayJSONRPCSubscriptionData.fromJson(
          json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RelayJSONRPCSubscriptionParamsToJson(
        RelayJSONRPCSubscriptionParams instance) =>
    <String, dynamic>{
      'id': instance.id,
      'data': instance.data,
    };
