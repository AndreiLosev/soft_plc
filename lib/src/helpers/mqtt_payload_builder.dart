import 'dart:convert';
import 'dart:typed_data';

import 'package:typed_data/typed_data.dart';

class MqttPayloadBuilder {
  
    final Uint8Buffer _payload = Uint8Buffer();

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

    void addUint16(int val) {
        final tmp = Uint16List.fromList([val]);
        _payload.addAll(tmp.buffer.asUint8List());
    }

    void addUint32(int val) {
        final tmp = Uint32List.fromList(<int>[val]);
        _payload.addAll(tmp.buffer.asInt8List());
    }

    void addUint64(int val) {
        final tmp = Uint64List.fromList(<int>[val]);
        _payload.addAll(tmp.buffer.asUint8List());
    }

    void addString(String val) {
        addUTF16String(val);
    }

    void addUTF16String(String val) {
        for (final codeUnit in val.codeUnits) {
            if (codeUnit <= 0xff && codeUnit >= 0) {
                _payload.add(codeUnit);
            } else {
                addUint16(codeUnit);
            }
        }
    }

    void addUTF8String(String val) {
        const encoder = Utf8Encoder();
        _payload.addAll(encoder.convert(val));
    }

    void addFloat32(double val) {
        final tmp = Float32List.fromList([val]);
        _payload.addAll(tmp.buffer.asUint8List());
    }

    void addDouble(double val) {
        final tmp = Float64List.fromList([val]);
        _payload.addAll(tmp.buffer.asUint8List());
    }

    void clear() {
        _payload.clear();
    }

    String getAsUTF8String([int? length]) {
        final slice = _sliceFromBuffer(length);        
        const decoder = Utf8Decoder();

        return decoder.convert(slice);
    }

    String getAsUTF16String([int? length]) {
        final slice = _sliceFromBuffer(length);
        final sb = StringBuffer();
        slice.forEach(sb.writeCharCode);

        return sb.toString();
    }

    int getAsUint64() {
        final slice = _sliceFromBuffer(8);
        return Uint8List.fromList(slice).buffer.asUint64List().first;
    }

    int getAsInt64() {
        final slice = _sliceFromBuffer(8);
        return Uint8List.fromList(slice).buffer.asInt64List().first;
    }

    int getAsUint32() {
        final slice = _sliceFromBuffer(4);
        return Uint8List.fromList(slice).buffer.asUint32List().first;
    }

    int getAsInt32() {
        final slice = _sliceFromBuffer(4);
        return Uint8List.fromList(slice).buffer.asInt32List().first;
    }

    int getAsUint16() {
        final slice = _sliceFromBuffer(2);
        return Uint8List.fromList(slice).buffer.asUint16List().first;
    }

    int getAsInt16() {
        final slice = _sliceFromBuffer(2);
        return Uint8List.fromList(slice).buffer.asInt16List().first;
    }

    int getAsUint8() {
        return _sliceFromBuffer(1).first;
    }

    int getAsInt8() {
        return _sliceFromBuffer(1).first;
    }

    Uint8Buffer _sliceFromBuffer(int? length) {
        
        final slice = Uint8Buffer();

        final len = length ?? _payload.length;

        for (var i = 0; i < len; i++) {
            final byte = _payload.removeLast();
            slice.add(byte);
        }

        return slice;

    }
}
