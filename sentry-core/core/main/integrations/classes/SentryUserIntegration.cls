public with sharing class SentryUserIntegration implements ISentryIntegration {
  private Boolean captureUserPII;
  private Boolean captureUserPermissions;

  public SentryUserIntegration() {
    this(true, false);
  }
  public SentryUserIntegration(
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
