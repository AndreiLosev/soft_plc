abstract interface class IReatainService {

    Future<void> createIfNotExists(String name, dynamic value);

    Future<void> update(String name, dynamic value);

    Future<Map<String, dynamic>> select(Iterable<String> names);

}

abstract interface class IErrorLogger {
    Future<void> build();
    Future<void> log(Object e, [bool $isFatal = false]);
}

abstract interface class ILoggingService {

    Future<void> setLog(Map<String, dynamic> property);
}
