trigger AccountTrigger on Account(
  before insert,
  before update,
  after insert,
  after update
) {
  try {
    if (Trigger.isBefore) {
      AccountTriggerHandler.handleBefore(Trigger.new, Trigger.oldMap);
    }
    if (Trigger.isAfter) {
      AccountTriggerHandler.handleAfter(Trigger.new, Trigger.oldMap);
    }
  } catch (Exception e) {
    Sentry.captureException(e);
    throw e;
  }
}
