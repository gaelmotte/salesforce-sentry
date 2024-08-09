@isTest
public with sharing class SentryDebugLogsIntegrationTest {
  @IsTest
  public static void addsRequestIdAndQuiddityOnlyByDefaultOnEvent() {
    SentryScope scope = new SentryScope();
    SentryDebugLogsIntegration integration = new SentryDebugLogsIntegration();
    integration.applyToScope(scope);
    SentryEvent event = SentryEvent.fromApexException(new SentryException());
    event = scope.applyToEvent(scope.applyToEvent(event, true), false);

    Assert.isTrue(
      new List<String>{ 'RUNTEST_SYNC', 'RUNTEST_ASYNC' }
        .contains(event.tags.get('Quiddity')),
      'must provide the quiddity'
    );
    Assert.isNotNull(
      event.tags.get('RequestId'),
      'must provide the request id'
    );
  }
}
