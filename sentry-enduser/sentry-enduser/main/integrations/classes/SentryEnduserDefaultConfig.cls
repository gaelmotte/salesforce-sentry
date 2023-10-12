public with sharing class SentryEnduserDefaultConfig {
  public virtual List<ISentryIntegration> getIntegrations() {
    return new List<ISentryIntegration>{
      new SentryUserIntegration(true), // capture user PII
      new SentryDebugLogsIntegration(),
      new SentryStacktraceIntegration(
        new SentryStacktraceIntegration.Options() // keep the defaults
      )
    };
  }
}
