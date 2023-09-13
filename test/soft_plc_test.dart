import 'second.dart' as second_test;
import 'package:test/test.dart';

void main() {
    second_test.main();
    test('calculate', () {
        expectLater(42, 42);
    });

    test('second test', () => {
        expectLater('32', '32')
    });
}
