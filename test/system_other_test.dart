import 'package:soft_plc/src/contracts/task.dart';
import 'package:soft_plc/src/system/console_error_logger.dart';
import 'package:soft_plc/src/system/event_queue.dart';
import 'package:test/test.dart';

void main() {
    test('event_queue', () async {
        final eLoger = ConsoleErrorLogger();
        final queue = EventQueue(eLoger);

        queue.dispatch(Tev());
        queue.dispatch(Tev());

        var i = 0;

        await for (final item in queue.listen()) {
            expect(true, item is Tev);
            i += 1;
            if (i == 2) {
                break;
            }
        }
    });
}


class Tev extends Event {}
