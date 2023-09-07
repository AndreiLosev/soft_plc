import 'package:soft_plc/soft_plc.dart';

class Config {
    
    Duration get loggingPeriod => Duration(minutes: 10);

    String get database => defaultDatabase;
    String get sqlitePath => 'soft_pls.db'; 

    bool floatIsEquals(double a, double b) =>
        (a - b).abs() < 0.1;
}
