trigger AccountTrigger on Account(before insert, after insert) {
  try {
    AccountTriggerHandler.handle(Trigger.new, Trigger.oldMap);
  } catch (Exception e) {
    sentrysdk.Sentry.captureException(e);
    throw e;
  }
}
