import 'dart:convert';

extension ObjectDebug on Object {
  Object getDebugValue() {
    return switch (runtimeType) {
      bool || int || String || double => this,
      _ => jsonEncode(this, toEncodable: _fn),
    };
  }

  void setDebugValue(String name, Object? value) {}
}

Object? _fn(Object? obj) {
  return obj.toString();
}
