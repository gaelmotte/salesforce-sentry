public with sharing class SentryDebugLogsIntegration implements ISentryIntegration {
  public void applyToScope(SentryScope scope) {
    scope.addProcessor(new SentryDebugLogsEventProcessor());
  }
}
