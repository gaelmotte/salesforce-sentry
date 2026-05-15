global with sharing class SentryLWCErrorIntegration implements ISentryIntegration {
  global SentryLWCErrorIntegration() {
  }

  public void applyToScope(SentryScope scope) {
    scope.addProcessor(new SentryLWCErrorEventProcessor());
  }
}
