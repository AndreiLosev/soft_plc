import 'package:soft_plc/src/config.dart';
import 'package:soft_plc/src/contracts/property_handlers.dart';
import 'package:soft_plc/src/contracts/services.dart';

class LoggingPropertyHeandler {
    
    final List<ILoggingProperty> _tasks;
    final ILoggingService _loggingService;
    final Duration _period;
    bool _run = false;

    LoggingPropertyHeandler(
        this._tasks,
        this._loggingService,
        Config config,
    ): _period = config.loggingPeriod;

    Future<void> build() async {
        await _loggingService.build();
    }

    Future<void> run() async {
    
        _run = true;

        while (_run) {
            await Future.delayed(_period);
            final properties = _tasks
                .map((t) => t.getLoggingProperty())
                .reduce((acc, t) => acc..addAll(t));

            await _loggingService.setLog(properties);
        }
    }

    void cancel() {
        _run = false;
    }

}
