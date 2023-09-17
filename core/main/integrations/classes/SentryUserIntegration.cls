public with sharing class SentryUserIntegration implements ISentryIntegration {
  private Boolean captureUserPII;

  public SentryUserIntegration() {
    this(false);
  }
  public SentryUserIntegration(Boolean captureUserPII) {
    this.captureUserPII = captureUserPII;
  }

  public void applyToScope(SentryScope scope) {
    scope.addProcessor(new SentryUserEventProcessor(captureUserPII));
  }
}
