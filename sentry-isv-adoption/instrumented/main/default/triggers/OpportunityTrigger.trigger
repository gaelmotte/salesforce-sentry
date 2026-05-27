trigger OpportunityTrigger on Opportunity(
  before insert,
  before update,
  after update
) {
  try {
    OpportunityTriggerHandler.run(
      Trigger.new,
      Trigger.old,
      Trigger.oldMap,
      Trigger.operationType
    );
  } catch (Exception e) {
    Sentry.captureException(e);
    throw e;
  }
}
