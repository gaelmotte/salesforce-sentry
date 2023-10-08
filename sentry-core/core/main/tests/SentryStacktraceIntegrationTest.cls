@isTest
public with sharing class SentryStacktraceIntegrationTest {
  @IsTest
  public static void addsStacktraceDetailsByDefaultOnEvent() {
    SentryScope scope = SentryHub.getCurrentHub().getCurrentScope();
    SentryStacktraceIntegration integration = new SentryStacktraceIntegration();
    integration.applyToScope(scope);
    SentryEvent event = new SentryEvent(new SentryException());
    event = scope.applyToEvent(scope.applyToEvent(event, true), false);

    Assert.isNotNull(
      event.ex,
      'exception (ex because of reserved keywork) should be added'
    );
    Assert.areEqual(1, event.ex.size());
    Assert.areEqual(
      (new SentryMechanismExceptionStrategy()).getExceptionType().getName(),
      event.ex.get(0).mechanism.type,
      'should provide exception mechanism'
    );
    Assert.areEqual(
      '    SentryEvent event = new SentryEvent(new SentryException());',
      event.ex.get(0).stacktrace.frames.get(0).context_line,
      'should provide code line'
    );
    Assert.areEqual(
      5,
      event.ex.get(0).stacktrace.frames.get(0).pre_context.size(),
      'should provide 5 code context line by default'
    );
    Assert.isTrue(
      event.ex.get(0).stacktrace.frames.get(0).in_app,
      'should consider everything in app by default'
    );
  }
}
