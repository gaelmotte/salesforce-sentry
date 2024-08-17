@isTest
public with sharing class SentryDebugLogsIntegrationTest {
  @IsTest
  public static void addsRequestIdAndQuiddityOnlyByDefaultOnEvent() {
    SentryScope scope = new SentryScope();
    scope.putContext(new SentryRuntimeContext(SentryRuntimeContext.APEX));
    SentryDebugLogsIntegration integration = new SentryDebugLogsIntegration();
    integration.applyToScope(scope);
    SentryEvent event = SentryEvent.fromApexException(new SentryException());
    event = scope.applyToEvent(scope.applyToEvent(event, true), false);

    Assert.isNotNull(event.tags.get('Quiddity'), 'must provide the quiddity');
    Assert.isNotNull(
      event.tags.get('RequestId'),
      'must provide the request id'
    );
  }
}
