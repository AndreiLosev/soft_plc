import 'dart:async';

class CancelableFutureDelayed<T> {
  final Duration _delay;
  final FutureOr<T> Function()? _computation;
  bool _run = false;
  bool _execut = false;

  CancelableFutureDelayed(this._delay, [this._computation]);

  FutureOr<T> call() async {
    final delay = const Duration(milliseconds: 100);
    final start = DateTime.now();
    _run = true;
    _execut = true;

    while (DateTime.now().difference(start) < _delay && _run) {
      await Future.delayed(delay);
    }

    return _computation != null && _execut ? _computation!() : Future.value();
  }

  void cancel() {
    _run = false;
    _execut = false;
  }

  void executeNow() {
    _run = false;
  }
}
