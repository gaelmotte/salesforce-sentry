@isTest
public with sharing class SentryLWCErrorIntegrationTest {
  @IsTest
  public static void addsFlowDetailsByDefaultOnEvent() {
    SentryScope scope = new SentryScope();
    SentryLWCErrorIntegration integration = new SentryLWCErrorIntegration();
    integration.applyToScope(scope);

    SentryLWCErrorInputParameters eventInput = new SentryLWCErrorInputParameters();
    eventInput.error = 'TEST ERROR';
    eventInput.stack = new List<String>{ 'test stack' };
    eventInput.cmpStack = new List<String>{ 'test stack' };
    eventInput.timestamp = Datetime.now();
    SentryLWCErrorInputParameters.SentryLWCLog log = new SentryLWCErrorInputParameters.SentryLWCLog();
    log.componentName = 'test';
    log.message = 'test message';
    log.timestamp = Datetime.now();
    eventInput.logs = new List<SentryLWCErrorInputParameters.SentryLWCLog>{
      log
    };

    SentryEvent event = SentryEvent.fromLWCError(eventInput);
    Test.startTest();
    event = scope.applyToEvent(scope.applyToEvent(event, true), false);
    Test.stopTest();

    System.Assert.areEqual(
      1,
      event.breadcrumbs.size(),
      'should have 1 breadcrumb'
    );
  }
}
