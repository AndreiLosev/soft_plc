import 'dart:async';

import 'package:soft_plc/src/config.dart';
import 'package:soft_plc/src/contracts/property_handlers.dart';
import 'package:soft_plc/src/contracts/services.dart';

class LoggingPropertyHandler {
  final List<ILoggingProperty> _tasks;
  final ILoggingService _loggingService;
  final IErrorLogger _errorLogger;
  final Duration _period;
  Timer? _timer;

  LoggingPropertyHandler(
    this._tasks,
    this._loggingService,
    this._errorLogger,
    Config config,
  ) : _period = config.loggingPeriod;

  Future<void> build() async {
    await _loggingService.build();
  }

  void run() {
    _timer = Timer.periodic(_period, (timer) async {
      try {
        final properties = _tasks
            .map((t) => t.getLoggingProperty())
            .reduce((acc, t) => acc..addAll(t));

        await _loggingService.setLog(properties);
      } catch (e, s) {
        _errorLogger.log(e, s);
      }
    });
  }

  void cancel() {
    _timer?.cancel();
  }
}
