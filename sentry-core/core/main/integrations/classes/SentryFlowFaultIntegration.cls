public with sharing class SentryFlowFaultIntegration implements ISentryIntegration {
  public SentryFlowFaultIntegration() {
  }

  public void applyToScope(SentryScope scope) {
    scope.addProcessor(new SentryFlowFaultEventProcessor());
  }
}
