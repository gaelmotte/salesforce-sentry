global with sharing class SentryUserIntegration implements ISentryIntegration {
  private Boolean captureUserPII;
  private Boolean captureUserPermissions;

  global SentryUserIntegration() {
    this(true, false);
  }
  global SentryUserIntegration(
    Boolean captureUserPermissions,
    Boolean captureUserPII
  ) {
    this.captureUserPII = captureUserPII;
    this.captureUserPermissions = captureUserPermissions;
  }

  public void applyToScope(SentryScope scope) {
    scope.addProcessor(
      new SentryUserEventProcessor(captureUserPermissions, captureUserPII)
    );
  }
}
