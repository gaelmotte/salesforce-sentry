global with sharing class SentryFlowFaultIntegration implements ISentryIntegration {
  global SentryFlowFaultIntegration() {
  }

  public void applyToScope(SentryScope scope) {
    scope.addProcessor(new SentryFlowFaultEventProcessor());
  }
}
