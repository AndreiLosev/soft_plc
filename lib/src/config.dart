class Config {
    
    final loggingPeriod = Duration(minutes: 10);

    final bool useDefaultSqlite3 = true;

    bool floatIsEquals(double a, double b) =>
        (a - b).abs() < 0.1;
}
