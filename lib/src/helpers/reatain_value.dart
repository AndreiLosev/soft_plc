import 'dart:convert';

abstract class ReatainValue<T extends Object> {
  T value;

  ReatainValue(this.value);

  String toJson();

  void fromJson(String strValue);
}

class ReatainBoolValue extends ReatainValue<bool> {
  ReatainBoolValue(super.value);

  @override
  String toJson() => super.value.toString();

  @override
  void fromJson(String strValue) => value = bool.parse(strValue);
}

class ReatainNumValue extends ReatainValue<num> {
  ReatainNumValue(super.value);

  @override
  String toJson() => super.value.toString();

  @override
  void fromJson(String strValue) => value = num.parse(strValue);
}

class ReatainStringValue extends ReatainValue<String> {
  ReatainStringValue(super.value);

  @override
  String toJson() => super.value;

  @override
  void fromJson(String strValue) => value = strValue;
}

class ReatainListValue<T> extends ReatainValue<List<T>> {
  ReatainListValue(super.value);

  @override
  String toJson() => jsonEncode(value);

  @override
  void fromJson(String strValue) {
    final json = jsonDecode(strValue) as List;
    value = [];
    for (var item in json) {
      value.add(item);
    }
  }
}

class ReatainMapValue<T> extends ReatainValue<Map<String, T>> {
  ReatainMapValue(super.value);

  @override
  String toJson() => jsonEncode(value);

  @override
  void fromJson(String strValue) {
    value = {};
    final json = jsonDecode(strValue) as Map;
    for (var item in json.entries) {
      value[item.key] = item.value as T;
    }
  }
}
