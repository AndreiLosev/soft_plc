import 'dart:convert';
import 'dart:typed_data';

import 'package:typed_data/typed_data.dart';

class SmartBuffer {
  final Uint8Buffer _payload;

  SmartBuffer([Uint8Buffer? buffer]) : _payload = buffer ?? Uint8Buffer();

  Uint8Buffer get payload => _payload;

  int get length => _payload.length;

  void addBuffer(Uint8Buffer buffer) {
    _payload.addAll(buffer);
  }

  void addByte(int val) {
    _payload.add(val);
  }

  void addBool(bool val) {
    val ? addByte(1) : addByte(0);
  }

  void addUint16(int val, [bool bigEndian = false]) {
    final tmp = Uint16List.fromList([val]);
    final bytes = _byteOrder(tmp.buffer.asUint8List(), bigEndian);
    _payload.addAll(bytes);
  }

  void addUint32(int val, [bool bigEndian = false]) {
    final tmp = Uint32List.fromList(<int>[val]);
    final bytes = _byteOrder(tmp.buffer.asUint8List(), bigEndian);
    _payload.addAll(bytes);
  }

  void addUint64(int val, [bool bigEndian = false]) {
    final tmp = Uint64List.fromList(<int>[val]);
    final bytes = _byteOrder(tmp.buffer.asUint8List(), bigEndian);
    _payload.addAll(bytes);
  }

  void addString(Object val) {
    const encoder = Utf8Encoder();
    _payload.addAll(encoder.convert(val.toString()));
  }

  void addFloat32(double val, [bool bigEndian = false]) {
    final tmp = Float32List.fromList([val]);
    final bytes = _byteOrder(tmp.buffer.asUint8List(), bigEndian);
    _payload.addAll(bytes);
  }

  void addDouble(double val, [bool bigEndian = false]) {
    final tmp = Float64List.fromList([val]);
    final bytes = _byteOrder(tmp.buffer.asUint8List(), bigEndian);
    _payload.addAll(bytes);
  }

  void clear() {
    _payload.clear();
  }

  bool getAsBool() {
    final slice = _sliceFromBuffer(1, false);
    return slice.first > 0;
  }

  String getAsString([int? length]) {
    final slice = _sliceFromBuffer(length, false);
    const decoder = Utf8Decoder();

    return decoder.convert(slice);
  }

  num getAsNumString([int? length]) {
      final slice = _sliceFromBuffer(length, false);
      const decoder = Utf8Decoder();
      return num.parse(decoder.convert(slice));
  }

  bool getAsBoolString([int? length]) {
      final slice = _sliceFromBuffer(length, false);
      const decoder = Utf8Decoder();
      return bool.parse(decoder.convert(slice));
  }

  T getAsJsonString<T>([int? length]) {
      final slice = _sliceFromBuffer(length, false);
      const decoder = Utf8Decoder();
      return jsonDecode(decoder.convert(slice)) as T;
  }

  int getAsUint64([bool bigEndian = false]) {
    final slice = _sliceFromBuffer(8, bigEndian);
    return Uint8List.fromList(slice).buffer.asUint64List().first;
  }

  int getAsInt64([bool bigEndian = false]) {
    final slice = _sliceFromBuffer(8, bigEndian);
    return Uint8List.fromList(slice).buffer.asInt64List().first;
  }

  int getAsUint32([bool bigEndian = false]) {
    final slice = _sliceFromBuffer(4, bigEndian);
    return Uint8List.fromList(slice).buffer.asUint32List().first;
  }

  int getAsInt32([bool bigEndian = false]) {
    final slice = _sliceFromBuffer(4, bigEndian);
    return Uint8List.fromList(slice).buffer.asInt32List().first;
  }

  int getAsUint16([bool bigEndian = false]) {
    final slice = _sliceFromBuffer(2, bigEndian);
    return Uint8List.fromList(slice).buffer.asUint16List().first;
  }

  int getAsInt16([bool bigEndian = false]) {
    final slice = _sliceFromBuffer(2, bigEndian);
    return Uint8List.fromList(slice).buffer.asInt16List().first;
  }

  int getAsUint8([bool bigEndian = false]) {
    return _sliceFromBuffer(1, bigEndian).first;
  }

  int getAsInt8([bool bigEndian = false]) {
    return _sliceFromBuffer(1, bigEndian).first;
  }

  double getAsFloat([bool bigEndian = false]) {
    final slice = _sliceFromBuffer(4, bigEndian);
    return slice.buffer.asFloat32List().first;
  }

  double getAsDouble([bool bigEndian = false]) {
    final slice = _sliceFromBuffer(8, bigEndian);
    return slice.buffer.asFloat64List().first;
  }

  Uint8Buffer _sliceFromBuffer(int? length, bool bigEndian) {
    final len = length ?? _payload.length;
    final slice = Uint8Buffer(len);

    for (var i = 0; i < len; i++) {
      final byte = _payload.removeLast();
      final index = bigEndian ? i : len - i - 1;
      slice[index] = byte;
    }

    return slice;
  }

  Iterable<int> _byteOrder(Uint8List bytes, bool bigEndian) {
    if (bigEndian) {
      return bytes.reversed;
    }

    return bytes;
  }
}

enum BinType {
  bool,
  uint8,
  uint16,
  uint32,
  uint64,
  int8,
  int16,
  int32,
  int64,
  float,
  double,
  string,
  numFromString,
  boolFromString,
  fromJsonString,
}
