/// Support for doing something awesome.
///
/// More dartdocs go here.
library walletconnectdartv2;

import 'package:convert/convert.dart';

export 'src/types.dart';
export 'src/client.dart';
export 'src/storage.dart';

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

  List<int> get bytes {
    return hex.decode(remove0x);
  }
}
