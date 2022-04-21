import 'dart:developer';
import 'dart:typed_data';

import 'package:walletconnectdartv2/walletconnectdartv2.dart';

class MockStorage extends Storage {
  final Map<String, Uint8List> _data = {};
  @override
  Future<Uint8List?> read(String key) {
    log("MockStorage.read($key)", name: packageName);
    return Future.value(_data[key]);
  }

  @override
  Future<bool> write(String key, Uint8List data) {
    log("MockStorage.write($key, ${String.fromCharCodes(data)})",
        name: packageName);
    _data[key] = data;
    return Future.value(true);
  }
}
