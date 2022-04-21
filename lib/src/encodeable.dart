import 'dart:developer';

import 'package:walletconnectdartv2/walletconnectdartv2.dart';

abstract class Encodeable<T> {
  dynamic toJson();

  static BaseType? fromJsonMixin<BaseType>(Object? json) {
    if (json == null) {
      return null;
    }
    log("Encodeable.fromJsonMixin: $BaseType $json", name: packageName);
    // TODO implement all children types
    switch (BaseType) {
      case RelayJSONRPCSubscriptionParams:
        return RelayJSONRPCSubscriptionParams.fromJson(
            json as Map<String, dynamic>) as BaseType;
      case EncodeableWrap<bool>:
        return EncodeableWrap<bool>(json as bool) as BaseType;
      case EncodeableWrap<String>:
        return EncodeableWrap<String>(json as String) as BaseType;
      case EncodeableWrap<dynamic>:
        return EncodeableWrap<dynamic>(json) as BaseType;
      case WCRequest<EncodeableWrap<dynamic>>:
        return WCRequest<EncodeableWrap<dynamic>>.fromJson(
            json as Map<String, dynamic>) as BaseType;
      default:
        return null;
    }
  }
}

class EncodeableWrap<T> extends Encodeable<EncodeableWrap<T>> {
  final T val;

  EncodeableWrap(this.val);

  @override
  T toJson() => val;
}
