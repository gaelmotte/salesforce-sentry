public with sharing class SentryLWCErrorIntegration implements ISentryIntegration {
  public SentryLWCErrorIntegration() {
  }

  public void applyToScope(SentryScope scope) {
    scope.addProcessor(new SentryLWCErrorEventProcessor());
  }
}
