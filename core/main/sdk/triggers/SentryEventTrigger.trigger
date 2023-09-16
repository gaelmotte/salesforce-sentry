trigger SentryEventTrigger on Sentry_Event__e(after insert) {
  List<SentryEvent> events = new List<SentryEvent>();
  for (Sentry_Event__e pe : Trigger.new) {
    events.add(new SentryEvent(pe));
  }
  SentryHub.getCurrentHub().transportEvents(events);
}
