abstract interface class IReatainService {

    Future<void> createIfNotExists(String name, Object value);

    Future<void> update(String name, Object value);

    Future<Map<String, Object>> select(Iterable<String> names);

}

abstract interface class IErrorLogger {
    Future<void> build();
    Future<void> log(Object e, StackTrace s, [bool $isFatal = false]);
}

abstract interface class ILoggingService {

    Future<void> build();

    Future<void> setLog(Map<String, Object> property);
}

abstract interface class IUsesDatabase {
    String get table;
}
