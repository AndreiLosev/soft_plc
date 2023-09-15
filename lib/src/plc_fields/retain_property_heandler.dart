import 'package:soft_plc/src/contracts/property_handlers.dart';
import 'package:soft_plc/src/contracts/services.dart';

class RetainPropertyHeandler {
    final IReatainService _reatainService;

    RetainPropertyHeandler(this._reatainService);

    Future<void> init(IRetainProperty task) async {
        final retainProperty = task.getRetainProperty();
        for (final i in retainProperty.entries) {
            await _reatainService.createIfNotExists(i.key, i.value);
        }

        final restoredProeprty = await _reatainService.select(retainProperty.keys.toSet());

        task.setRetainProperties(restoredProeprty);
    }

    Future<void> save(IRetainProperty task) async {
        final retainProperty = task.getRetainProperty();
        retainProperty.forEach(
            (name, value) async => await _reatainService.update(name, value),
        );
    }
}
