public virtual class SentryMechanismExceptionStrategy implements Comparable {
  private string stacktraceStringKey;

  public SentryMechanismExceptionStrategy(String stacktraceStringKey) {
    this.stacktraceStringKey = stacktraceStringKey;
  }

  public SentryMechanismExceptionStrategy() {
    this.stacktraceStringKey = SentryStacktraceIntegration.STACKTRACE_AS_STRING_KEY;
  }

  public virtual System.Type getExceptionType() {
    return Exception.class;
  }

  public virtual SentryValueClassMechanism getMechanism(Exception ex) {
    Map<String, Object> data = new Map<String, Object>{
      stacktraceStringKey => ex.getStackTraceString() // will be used by transport to generate the SentryValueClass.Stacktrace
    };

    SentryValueClassMechanism mechanism = new SentryValueClassMechanism();
    mechanism.data = data;
    mechanism.type = getExceptionType().getName();

    return mechanism;
  }

  // sorts from most specific to least specific expcetion type
  public Integer compareTo(Object other) {
    System.type otherType = ((SentryMechanismExceptionStrategy) other)
      .getExceptionType();
    if (getExceptionType().isAssignableFrom(otherType)) {
      return 1;
    }
    if (getExceptionType().isAssignableFrom(otherType)) {
      return -1;
    }
    return 0;
  }
}
