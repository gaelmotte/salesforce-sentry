trigger OpportunityTrigger on Opportunity(
  before insert,
  before update,
  after update
) {
  OpportunityTriggerHandler.run(
    Trigger.new,
    Trigger.old,
    Trigger.oldMap,
    Trigger.operationType
  );
}
