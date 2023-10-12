public with sharing class SentryDebugLogsIntegration implements ISentryIntegration {
  public static final String DEFAULT_NAMED_CRED_DEV_NAME = 'Sentry_SDK_Tooling_Api_Credential';

  private Boolean autoAddUserDebugFlag;
  private String namedCredDevName;

  public SentryDebugLogsIntegration() {
    this(false, DEFAULT_NAMED_CRED_DEV_NAME);
  }

  public SentryDebugLogsIntegration(
    Boolean autoAddUserDebugFlag,
    String namedCredDevName
  ) {
    this.autoAddUserDebugFlag = autoAddUserDebugFlag;
    this.namedCredDevName = namedCredDevName;
  }

  public void applyToScope(SentryScope scope) {
    // we only need the userId and OrgID
    scope.addProcessor(new SentryUserEventProcessor(false, false));
    scope.addProcessor(
      new SentryDebugLogsEventProcessor(autoAddUserDebugFlag, namedCredDevName)
    );
  }
}
