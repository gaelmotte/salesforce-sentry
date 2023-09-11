public class SentryOrgContext extends SentryContext {
  public static final String TYPE = 'organization';
  public SentryOrgContext() {
    this.type = TYPE;
  }

  public override SentryContext.ContextData getData() {
    return new ContextData();
  }

  private class ContextData implements SentryContext.ContextData{
    public String organizationId = UserInfo.getOrganizationId();
  }
}
