public with sharing class SentryDebugLogsIntegration implements ISentryIntegration {
  // TODO take arguments :
  // * NamedCred developername ?
  // * What debug log level to set ?

  public void applyToScope(SentryScope scope) {
    scope.addProcessor(new SentryDebugLogsEventProcessor());
  }
}
