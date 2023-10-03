import 'package:soft_plc/soft_plc.dart';
import 'package:soft_plc/src/plc_fields/event_task_collection.dart';
import 'package:soft_plc/src/plc_fields/logging_property_handler.dart';
import 'package:soft_plc/src/plc_fields/monitoring_property_handler.dart';
import 'package:soft_plc/src/plc_fields/network_property_handler.dart';
import 'package:soft_plc/src/plc_fields/periodic_task_collection.dart';

class SoftPlc {
  final ServiceContainer _container;
  final LoggingPropertyHandler _loggingPropertyHeandler;
  final MonitoringPropertyHandler _monitoringPropertyHandler;
  final NetworkPropertyHandler _networkPropertyHandler;
  final PeriodicTaskCollection _periodicTaskCollection;
  final EventTaskCollection _eventTaskCollection;

  SoftPlc(
    this._container,
    this._loggingPropertyHeandler,
    this._monitoringPropertyHandler,
    this._networkPropertyHandler,
    this._periodicTaskCollection,
    this._eventTaskCollection,
  );

  Future<void> run() async {
    try {
      _loggingPropertyHeandler.run();

      await Future.any([
        _monitoringPropertyHandler.run(),
        _networkPropertyHandler.run(),
        _periodicTaskCollection.run(_container),
        _eventTaskCollection.run(_container),
      ]);
    } catch (e, s) {
      _container.get<IErrorLogger>().log(e, s, true);
    }
  }

  void dispatchEvent(Event event) =>
      _container.get<EventQueue>().dispatch(event);

  void stop() {
    _loggingPropertyHeandler.cancel();
    _monitoringPropertyHandler.cancel();
    _networkPropertyHandler.cancel();
    _periodicTaskCollection.cancel();
    _eventTaskCollection.cancel();
  }
}
