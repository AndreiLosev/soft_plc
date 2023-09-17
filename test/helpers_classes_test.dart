import 'package:soft_plc/soft_plc.dart';
import 'package:test/test.dart';
import 'package:typed_data/typed_data.dart';

void main() {
    test('mqtt_payload_builder_test', () {

        final builder = SmartBuffer();

        builder
            ..addByte(66)
            ..addBool(true)
            ..addUint16(299)
            ..addUint32(-98746215)
            ..addString("hello or Привет !%^&")
            ..addDouble(-9.234)
            ..addFloat32(9555.8975)
        ;

        final expect = Uint8Buffer();
        expect
            ..add(66)
            ..add(1)
            ..addAll([0x2b, 0x01])
            ..addAll([0x99, 0x40, 0x1d, 0xfa])
            ..addAll([104, 101, 108, 108, 111, 32, 111, 114, 32, 208, 159, 209, 128,
                      208, 184, 208, 178, 208, 181, 209, 130, 32, 33, 37, 94, 38])
            ..addAll([0x2b, 0x87, 0x16, 0xd9, 0xce, 0x77, 0x22, 0xc0])
            ..addAll([0x97, 0x4f, 0x15, 0x46])
        ;

        expectLater(expect, builder.payload);
        expectLater(9555.8975.round(), builder.getAsFloat().round());
        expectLater(-9.234.round(), builder.getAsDouble().round());
        expectLater("hello or Привет !%^&", builder.getAsString(26));
        expectLater(-98746215, builder.getAsInt32());
        expectLater(299, builder.getAsUint16());
        expectLater(true, builder.getAsBool());
        expectLater(66, builder.getAsUint8());

    });

    test("retain_value", () {
        final b = ReatainBoolValue(true);
        expectLater('true', b.toJson());
        b.fromJson('false');
        expectLater(false, b.value);

        final n = ReatainNumValue(620);
        expectLater('620', n.toJson());
        n.fromJson('7777');
        expectLater(7777, n.value);

        final m = ReatainMapValue({"one": 1.22, 'two': 33});
        expectLater('{"one":1.22,"two":33}', m.toJson());
        m.fromJson('{"one":13.22,"two":33.33}');
        expectLater(<String, num>{"one": 13.22, "two": 33.33}, m.value);

        final l = ReatainListValue([true, false, true]);
        expectLater("[true,false,true]", l.toJson());
        l.fromJson("[true,true,false]");
        expectLater([true, true, false], l.value);
    });
}
