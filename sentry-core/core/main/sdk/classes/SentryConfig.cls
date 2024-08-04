public virtual with sharing class SentryConfig {
  public SentryDSN dsn;
  public Double sampling;
  public Boolean enabled;
  public Boolean ready {
    get {
      return enabled && dsn.valid;
    }
  }

  /**
   * Override this method to provide all the integrations you need
   */
  public virtual List<ISentryIntegration> getIntegrations() {
    return new List<ISentryIntegration>();
  }

  /**
   * Override this method to filter out events before they are sent.
   * Returning null discards the event (ie : it won't be stored in SentryPayloads__c either)
   * TODO : Add a DoNotSend flag on SentryEvent so it may be stored but not sent ?
   */
  public virtual ISentryBeforeSendCallback getBeforeSendCallback() {
    return null;
  }

  /**
   * Override this method to filter out breadcrumbs before they are sent.
   * Returning null discards the breadcrumb (ie : it won't be stored in SentryPayloads__c either)
   */
  public virtual ISentryBeforeBreadcrumbCallback getBeforeBreadcrumbCallback() {
    return null;
  }

  public class Recommended extends SentryConfig {
    public override List<ISentryIntegration> getIntegrations() {
      return new List<ISentryIntegration>{
        new SentryUserIntegration(), // do not capture user PII is default
        new SentryStacktraceIntegration(),
        new SentryFlowFaultIntegration()
      };
    }
  }
}
