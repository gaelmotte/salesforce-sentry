public class SomeClass {
  public Double throwsMathException() {
    return 1 / 0;
  }
  public Account throwsDmlException() {
    Account acc = new Account();
    insert acc;
    return acc;
  }
}

try {
  (new SomeClass()).throwsMathException();
} catch (Exception e) {
  System.debug(e.getStacktraceString());
  System.debug(
    JSON.serialize(SentryStacktraceParser.parse(e.getStacktraceString()))
  );
  Sentry.captureException(e);
}
