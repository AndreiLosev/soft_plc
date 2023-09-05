class Config {
    
    final loggingPeriod = Duration(minutes: 10);

    bool floatIsEquals(double a, double b) =>
        (a - b).abs() < 0.1;
}
