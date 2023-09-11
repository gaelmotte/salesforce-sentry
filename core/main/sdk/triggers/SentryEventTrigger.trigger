trigger SentryEventTrigger on Sentry_Event__e(after insert) {
  SentryTransport.proccess((List<Sentry_Event__e>) Trigger.new);
}
