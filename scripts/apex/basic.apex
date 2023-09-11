public class SomeClass {
  public Double throws() {
    return 1/0;
  }
}

try {
  (new SomeClass()).throws();
} catch (Exception e) {
  Sentry.captureException(e);
}
