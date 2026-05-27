trigger AccountTrigger on Account(before insert, after insert) {
  AccountTriggerHandler.handle(Trigger.new, Trigger.oldMap);
}
