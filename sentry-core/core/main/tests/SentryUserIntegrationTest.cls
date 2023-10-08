@isTest
public with sharing class SentryUserIntegrationTest {
  @IsTest
  public static void addsUserIdAndNoPiiByDefaultOnEvent() {
    SentryScope scope = SentryHub.getCurrentHub().getCurrentScope();
    SentryUserIntegration integration = new SentryUserIntegration();
    integration.applyToScope(scope);
    SentryEvent event = new SentryEvent(new SentryException());
    event = scope.applyToEvent(scope.applyToEvent(event, true), false);

    SentryUser user = new SentryUser();
    user.userId = UserInfo.getUserId();
    user.id = UserInfo.getOrganizationId() + '/' + UserInfo.getUserId();

    Assert.areEqual(
      JSON.serialize(user),
      JSON.serialize(event.user),
      'only non PII info should be present'
    );
  }

  @IsTest
  public static void addsUserIdAndPermissionsByDefaultOnEvent() {
    SentryScope scope = SentryHub.getCurrentHub().getCurrentScope();
    SentryUserIntegration integration = new SentryUserIntegration();
    integration.applyToScope(scope);
    SentryEvent event = new SentryEvent(new SentryException());
    event = scope.applyToEvent(scope.applyToEvent(event, true), false);

    SentryUser user = new SentryUser();
    user.userId = UserInfo.getUserId();
    user.id = UserInfo.getOrganizationId() + '/' + UserInfo.getUserId();

    Assert.areEqual(
      JSON.serialize(user),
      JSON.serialize(event.user),
      'only non PII info should be present'
    );

    Assert.isNotNull(
      event.contexts.get(SentryPermissionsContext.TYPE),
      'must add info on permissions'
    );
  }

  @IsTest
  public static void addsUserIdAndPiiGatedOnEvent() {
    SentryScope scope = SentryHub.getCurrentHub().getCurrentScope();
    SentryUserIntegration integration = new SentryUserIntegration(false, true);
    integration.applyToScope(scope);
    SentryEvent event = new SentryEvent(new SentryException());
    event = scope.applyToEvent(scope.applyToEvent(event, true), false);

    SentryUser user = new SentryUser();
    user.userId = UserInfo.getUserId();
    user.id = UserInfo.getOrganizationId() + '/' + UserInfo.getUserId();

    Assert.areEqual(user.userId, event.user.userId, 'userId must match');
    Assert.areEqual(user.id, event.user.id, 'id must match');
    Assert.isNotNull(event.user.email, 'email must be provided');
    Assert.isNotNull(event.user.username, 'username must be provided');
    Assert.isNotNull(
      event.user.languageLocaleKey,
      'languageLocaleKey must be provided'
    );
  }
}
