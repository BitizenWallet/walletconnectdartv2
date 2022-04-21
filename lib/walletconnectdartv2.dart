/// Support for doing something awesome.
///
/// More dartdocs go here.
library walletconnectdartv2;

import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';
import 'package:json_annotation/json_annotation.dart';

export 'src/types.dart';
export 'src/client.dart';
export 'src/storage.dart';
export 'src/key_managment_service.dart';
export 'src/encodeable.dart';

const packageName = "WalletConnectV2";

extension HexExtForBytes on List<int> {
  String get hexWith0x => hex.encode(this).add0x;
  String get hexWithout0x => hex.encode(this);
}

extension HexExtForString on String {
  String get add0x {
    if (startsWith('0x')) {
      return this;
    }
    return '0x' + this;
  }

  String get remove0x {
    if (!startsWith('0x')) {
      return this;
    }
    return substring(2);
  }

  List<int> get hexDecode {
    return hex.decode(remove0x);
  }
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
      (json['bytes'] as String).hexDecode,
      type: KeyPairType.x25519,
    );
  }
}

class DurationJsonConverter implements JsonConverter<Duration, int> {
  const DurationJsonConverter();
  @override
  int toJson(Duration duration) {
    return duration.inSeconds;
  }

  @override
  Duration fromJson(int val) {
    return Duration(
      seconds: val,
    );
  }
}
