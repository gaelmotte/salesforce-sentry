public virtual class SentryExceptionMechanismFormatter {
  public virtual Boolean supports(Exception ex) {
    return true;
  }
  public virtual SentryValueClass.Mechanism getMechanism(Exception ex) {
    Map<String, Object> data = new Map<String, Object>{
      'stacktraceString' => ex.getStackTraceString() // will be used by transport to generate the SentryValueClass.Stacktrace
    };

    SentryValueClass.Mechanism mechanism = new SentryValueClass.Mechanism();
    mechanism.data = data;
    mechanism.type = 'Exception';

    return mechanism;
  }
}
