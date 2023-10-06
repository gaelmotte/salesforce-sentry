public with sharing class SentryConfig implements ISentryConfig {
  public Boolean isEnabled() {
    return true;
  }
  public SentryDSN getDSN() {
    return new SentryDSN('https://your.sentry.dsn');
  }

  public List<ISentryIntegration> getIntegrations() {
    return new List<ISentryIntegration>{
      new SentryUserIntegration(true), // capture user PII
      new SentryDebugLogsIntegration(),
      new SentryStacktraceIntegration(
        new SentryStacktraceIntegration.Options(5)
      )
    };
  }
}
