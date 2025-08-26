public with sharing class SentryEnduserDefaultConfig extends SentryConfig {
  public virtual override List<ISentryIntegration> getIntegrations() {
    return new List<ISentryIntegration>{
      new SentryUserIntegration(), // all de defaults
      new SentryDebugLogsIntegration(), // all de defaults
      new SentryStacktraceIntegration(), // all the defaults,
      new SentryFlowFaultIntegration(),
      new SentryLWCErrorIntegration()
    };
  }
}
