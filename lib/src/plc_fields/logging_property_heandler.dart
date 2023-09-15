import 'dart:async';

import 'package:soft_plc/src/config.dart';
import 'package:soft_plc/src/contracts/property_handlers.dart';
import 'package:soft_plc/src/contracts/services.dart';

class LoggingPropertyHeandler {
    
    final List<ILoggingProperty> _tasks;
    final ILoggingService _loggingService;
    final Duration _period;
    Timer? _timer;

    LoggingPropertyHeandler(
        this._tasks,
        this._loggingService,
        Config config,
    ): _period = config.loggingPeriod;

    Future<void> build() async {
        await _loggingService.build();
    }

    void run() {
        _timer = Timer.periodic(_period, (timer) async {
            final properties = _tasks
                .map((t) => t.getLoggingProperty())
                .reduce((acc, t) => acc..addAll(t));

            await _loggingService.setLog(properties);
        });
    }

    void cancel() {
        _timer?.cancel();
    }

}
