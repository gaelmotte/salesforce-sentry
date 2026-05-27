public with sharing class SentryISVConfig extends SentryConfig {
  public override List<ISentryIntegration> getIntegrations() {
    return new List<ISentryIntegration>{
      new SentryISVContextIntegration(),
      new SentryUserIntegration(),
      new SentryStacktraceIntegration(),
      new SentryFlowFaultIntegration(),
      new SentryLWCErrorIntegration()
    };
  }
}
