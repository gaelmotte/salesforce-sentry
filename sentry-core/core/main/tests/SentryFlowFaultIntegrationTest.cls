@isTest
public with sharing class SentryFlowFaultIntegrationTest {
  @IsTest
  public static void addsFlowDetailsByDefaultOnEvent() {
    SentryScope scope = new SentryScope();
    SentryFlowFaultIntegration integration = new SentryFlowFaultIntegration();
    integration.applyToScope(scope);

    SentryEvent event = SentryEvent.fromFlowFault(
      'flowInterviewGUID',
      'TEST ERROR'
    );
    event = scope.applyToEvent(scope.applyToEvent(event, true), false);

    Assert.isNotNull(
      event.ex,
      'exception (ex because of reserved keywork) should be added'
    );
    Assert.areEqual(1, event.ex.size());
    Assert.areEqual(
      (new SentryMechanismSyntheticFlowExStrategy())
        .getExceptionType()
        .getName(),
      event.ex.get(0).mechanism.type,
      'should provide exception mechanism'
    );
  }
}
