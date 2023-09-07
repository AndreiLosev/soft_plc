import 'package:soft_plc/src/contracts/services.dart';

class ConsoleErrorLogger implements IErrorLogger {

    @override
    Future<void> build() => Future.value();

    @override
    Future<void> log(Object e, StackTrace s, [bool $isFatal = false]) {
        print(e);
        print(s);
        return Future.value();
    }
}
