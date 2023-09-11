public virtual class SentryExceptionMechanismFormatter implements Comparable {
  public virtual System.Type getExceptionType() {
    return Exception.class;
  }

  public virtual SentryValueClass.Mechanism getMechanism(Exception ex) {
    Map<String, Object> data = new Map<String, Object>{
      'stacktraceString' => ex.getStackTraceString() // will be used by transport to generate the SentryValueClass.Stacktrace
    };

    SentryValueClass.Mechanism mechanism = new SentryValueClass.Mechanism();
    mechanism.data = data;
    mechanism.type = getExceptionType().getName();

    return mechanism;
  }

  public Integer compareTo(Object other) {
    System.type otherType = ((SentryExceptionMechanismFormatter) other)
      .getExceptionType();
    System.debug(
      'comapring ' + getExceptionType().getName() + 'and' + otherType.getName()
    );
    if (getExceptionType().isAssignableFrom(otherType)) {
      return 1;
    }
    if (getExceptionType().isAssignableFrom(otherType)) {
      return -1;
    }
    return 0;
  }
}
