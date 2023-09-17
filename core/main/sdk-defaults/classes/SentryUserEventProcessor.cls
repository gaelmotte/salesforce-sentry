public with sharing class SentryUserEventProcessor extends SentryEventProcessor {
  public SentryUserEventProcessor() {
    // TODO take a Send PII option
  }

  public override SentryEvent processAtCapture(SentryEvent event) {
    event.user = new SentryUser();
    event.user.id = UserInfo.getOrganizationId() + '/' + UserInfo.getUserId(); // user id is likely not unique across all orgs.
    return event;
  }

  public override SentryEvent processAtTransport(SentryEvent event) {
    // TODO enrich with a context showing :
    // * Profile
    // * PermissionSets
    // * PermissionSetGroups
    // * Role
    return event;
  }
}
