@isTest
public with sharing class SentryEventProcessorTest {
  private class NoopEventProcessor extends SentryEventProcessor {
  }

  @isTest
  public static void handlesEvent() {
    SentryEvent event = new SentryEvent();
    NoopEventProcessor processor = new NoopEventProcessor();
    Assert.areEqual(
      processor.processAtTransport(processor.processAtCapture(event)),
      event,
      'the event should not have been touched'
    );
  }
}
