@isTest
public with sharing class SentryISVContextIntegrationTest {
  @IsTest
  public static void setsReleaseFromExplicitVersion() {
    SentryScope scope = new SentryScope();
    SentryISVContextIntegration integration = new SentryISVContextIntegration(
      '1.2.x'
    );
    integration.applyToScope(scope);
    SentryEvent event = SentryEvent.fromApexException(new SentryException());
    event = scope.applyToEvent(scope.applyToEvent(event, true), false);

    Assert.areEqual(
      '1.2.x',
      event.release,
      'release must match explicit version'
    );
  }

  @IsTest
  public static void setsSubscriberOrgTag() {
    SentryScope scope = new SentryScope();
    SentryISVContextIntegration integration = new SentryISVContextIntegration(
      '1.0.x'
    );
    integration.applyToScope(scope);
    SentryEvent event = SentryEvent.fromApexException(new SentryException());
    event = scope.applyToEvent(scope.applyToEvent(event, true), false);

    Assert.areEqual(
      UserInfo.getOrganizationName(),
      event.tags.get('subscriber_org'),
      'subscriber_org tag must be set to org name'
    );
  }

  @IsTest
  public static void setsEnvironmentMatchingOrgType() {
    SentryScope scope = new SentryScope();
    SentryISVContextIntegration integration = new SentryISVContextIntegration(
      '1.0.x'
    );
    integration.applyToScope(scope);
    SentryEvent event = SentryEvent.fromApexException(new SentryException());
    event = scope.applyToEvent(scope.applyToEvent(event, true), false);

    Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    Assert.areEqual(
      isSandbox ? 'sandbox' : 'production',
      event.environment,
      'environment must match org type'
    );
  }
}
