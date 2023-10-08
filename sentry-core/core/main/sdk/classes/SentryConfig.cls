public virtual with sharing class SentryConfig {
  public SentryDSN dsn;
  public Boolean enabled;
  public Boolean ready {
    get {
      return enabled && dsn.valid;
    }
  }

  public virtual List<ISentryIntegration> getIntegrations() {
    return new List<ISentryIntegration>();
  }

  public class Recommended extends SentryConfig {
    public override List<ISentryIntegration> getIntegrations() {
      return new List<ISentryIntegration>{
        new SentryUserIntegration(false), // do not capture user PII
        new SentryStacktraceIntegration(
          new SentryStacktraceIntegration.Options(5)
        )
      };
    }
  }
}
