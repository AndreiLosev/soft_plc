
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
