abstract interface class IRetainProperty {
    
    Map<String, dynamic> getRetainProperty();
    void setRetainProperties(Map<String, dynamic> properties);
}

abstract interface class ILoggingProperty {
    
    Map<String, dynamic> getLoggingProperty();
}

abstract interface class IMonitoringProperty {
    
    Map<String, dynamic> getEventValues();
    bool floatIsEquals(double a, double b);
}

abstract interface class INetworkProperty {

    Map<String, dynamic> getNetworkProperty();
    void setNetworkProperty(Map<String, dynamic> properties);
}
