public with sharing class SentryConfigNoop implements ISentryConfig {
  public Boolean isEnabled() {
    return false;
  }

  public SentryDSN getDSN() {
    return null;
  }

  public List<ISentryIntegration> getIntegrations() {
    return new List<ISentryIntegration>();
  }
}
