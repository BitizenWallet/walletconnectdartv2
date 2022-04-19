import 'dart:typed_data';

abstract class Storage {
  Future<bool> write(String key, Uint8List data);
  Future<Uint8List?> read(String key);
}
