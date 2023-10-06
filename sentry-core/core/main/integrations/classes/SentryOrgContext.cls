public class SentryOrgContext extends SentryContext {
  public static final String TYPE = 'organization';
  public SentryOrgContext() {
    this.type = TYPE;
  }

  public override Map<String, Object> getData() {
    return new Map<String, Object>{
      'organizationId' => UserInfo.getOrganizationId()
    };
  }
}
