@isTest
public with sharing class SentryFlowFaultIntegrationTest {
  @IsTest
  public static void addsFlowDetailsByDefaultOnEvent() {
    SentryScope scope = new SentryScope();
    SentryFlowFaultIntegration integration = new SentryFlowFaultIntegration();
    integration.applyToScope(scope);

    SentryEvent event = SentryEvent.fromFlowFault(
      'flowInterviewGUID',
      'TEST ERROR',
      'flow_apiname',
      'someSFDCID'
    );
    event = scope.applyToEvent(scope.applyToEvent(event, true), false);

    Assert.isNotNull(
      event.ex,
      'exception (ex because of reserved keywork) should be added'
    );
    Assert.areEqual(2, event.ex.size()); // the capture messagge and the original flow error
  }
}
