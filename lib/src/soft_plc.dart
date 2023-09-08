
import 'package:soft_plc/soft_plc.dart';
import 'package:soft_plc/src/plc_fields/event_task_collection.dart';
import 'package:soft_plc/src/plc_fields/logging_property_heandler.dart';
import 'package:soft_plc/src/plc_fields/monitoring_property_heandler.dart';
import 'package:soft_plc/src/plc_fields/network_property_heandler.dart';
import 'package:soft_plc/src/plc_fields/periodic_task_collection.dart';

class SoftPlc {
    final ServiceContainer _container;
    final LoggingPropertyHeandler _loggingPropertyHeandler;
    final MonitoringPropertyHeandler _monitoringPropertyHeandler;
    final NetworkPropertyHeandler _networkPropertyHeandler; 
    final PeriodicTaskCollection _periodicTaskCollection;
    final EventTaskCollection _eventTaskCollection;


    SoftPlc(
        this._container,
        this._loggingPropertyHeandler,
        this._monitoringPropertyHeandler,
        this._networkPropertyHeandler,
        this._periodicTaskCollection,
        this._eventTaskCollection,
    );

    Future<void> run() async {
        try {
            await Future.any([
                _loggingPropertyHeandler.run(),
                _monitoringPropertyHeandler.run(),
                _networkPropertyHeandler.run(),
                _periodicTaskCollection.run(_container),
                _eventTaskCollection.run(_container),
            ]);
        } catch (e, s) {
            _container.get<IErrorLogger>().log(e, s, true);
        }
    }

    void dispatchEvent(Event event) =>
        _container.get<EventQueue>().dispatch(event);

}
