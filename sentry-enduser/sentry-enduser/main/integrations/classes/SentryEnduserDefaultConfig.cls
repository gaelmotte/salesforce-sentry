public with sharing class SentryEnduserDefaultConfig {
  public virtual List<ISentryIntegration> getIntegrations() {
    return new List<ISentryIntegration>{
      new SentryUserIntegration(true, true), // capture user PII, which is not default
      new SentryDebugLogsIntegration(), // all de defaults
      new SentryStacktraceIntegration() // all the defaults
    };
  }
}
