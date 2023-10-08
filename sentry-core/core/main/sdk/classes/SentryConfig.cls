public virtual with sharing class SentryConfig {
  public SentryDSN dsn;
  public Boolean enabled;

  public List<ISentryIntegration> integrations = new List<ISentryIntegration>();

  public class Recommended extends SentryConfig {
    public List<ISentryIntegration> integrations = new List<ISentryIntegration>{
      new SentryUserIntegration(false), // do not capture user PII
      new SentryStacktraceIntegration(
        new SentryStacktraceIntegration.Options(5)
      )
    };
  }
}
