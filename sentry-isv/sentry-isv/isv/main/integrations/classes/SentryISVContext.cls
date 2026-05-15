public class SentryISVContext implements ISentryIntegration {
  private final String release;

  public SentryISVContext() {
    this(null);
  }

  public SentryISVContext(String release) {
    this.release = release;
  }

  public void applyToScope(SentryScope scope) {
    scope.addProcessor(new SentryISVEventProcessor(release));
  }
}
