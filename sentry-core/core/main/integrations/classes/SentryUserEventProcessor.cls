public with sharing class SentryUserEventProcessor extends SentryEventProcessor {
  private Boolean captureUserPII;

  public SentryUserEventProcessor(Boolean captureUserPII) {
    this.captureUserPII = captureUserPII;
    // TODO take an optional namespace to filter permissions
  }

  public override SentryEvent processAtCapture(SentryEvent event) {
    event.user = new SentryUser();
    event.user.id = UserInfo.getOrganizationId() + '/' + UserInfo.getUserId(); // user id is likely not unique across all orgs.
    event.user.userId = UserInfo.getUserId();
    return event;
  }

  public override SentryEvent processAtTransport(SentryEvent event) {
    // read userId from the event
    String userId = event.user.userId;
    User user = [
      SELECT
        Country,
        Email,
        IsActive,
        LanguageLocaleKey,
        LastLoginDate,
        LastName,
        FirstName,
        Profile.Name,
        Username,
        UserRole.Name,
        UserType,
        (
          SELECT id, PermissionSet.Name, PermissionSet.NamespacePrefix
          FROM PermissionSetAssignments
        )
      FROM user
      WHERE id = :userId
      LIMIT 1
    ];

    if (captureUserPII) {
      event.user.country = user.Country;
      event.user.email = user.Email;
      event.user.isActive = user.IsActive;
      event.user.languageLocaleKey = user.LanguageLocaleKey;
      event.user.lastName = user.LastName;
      event.user.firstName = user.FirstName;
      event.user.username = user.Username;
    }
    event.contexts.put(
      SentryPermissionsContext.TYPE,
      new SentryPermissionsContext(user).getData()
    );
    return event;
  }
}
