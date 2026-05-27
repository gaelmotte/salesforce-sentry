public with sharing class OpportunityTriggerHandler {
  public static void run(
    List<Opportunity> newList,
    List<Opportunity> oldList,
    Map<Id, Opportunity> oldMap,
    System.TriggerOperation operationType
  ) {
    switch on operationType {
      when BEFORE_INSERT {
        setDefaultCloseDate(newList);
        validateStageProbability(newList, null);
      }
      when BEFORE_UPDATE {
        validateStageProbability(newList, oldMap);
        preventDowngradeAfterClose(newList, oldMap);
      }
      when AFTER_UPDATE {
        handleStageChange(newList, oldMap);
      }
    }
  }

  // Ensures every new opportunity has a close date at least 7 days out.
  static void setDefaultCloseDate(List<Opportunity> opps) {
    Date minClose = Date.today().addDays(7);
    for (Opportunity opp : opps) {
      if (opp.CloseDate == null || opp.CloseDate < minClose) {
        opp.CloseDate = minClose;
      }
    }
  }

  // Keeps Probability aligned with the Stage picklist value.
  // Throws if a stage name has no mapping — surfaced by the trigger try/catch.
  static void validateStageProbability(
    List<Opportunity> newList,
    Map<Id, Opportunity> oldMap
  ) {
    Map<String, Integer> stageProbability = new Map<String, Integer>{
      'Prospecting' => 10,
      'Qualification' => 20,
      'Needs Analysis' => 30,
      'Value Proposition' => 40,
      'Id. Decision Makers' => 50,
      'Perception Analysis' => 60,
      'Proposal/Price Quote' => 70,
      'Negotiation/Review' => 80,
      'Closed Won' => 100,
      'Closed Lost' => 0
    };

    for (Opportunity opp : newList) {
      Boolean stageChanged =
        oldMap == null ||
        opp.StageName != oldMap.get(opp.Id).StageName;
      if (!stageChanged)
        continue;

      if (!stageProbability.containsKey(opp.StageName)) {
        // Unknown stage — will be caught and sent to Sentry by the trigger wrapper
        throw new IllegalArgumentException(
          'Unknown Opportunity stage: ' + opp.StageName
        );
      }
      opp.Probability = stageProbability.get(opp.StageName);
    }
  }

  // Blocks re-opening a Closed Lost deal without an explicit override flag.
  static void preventDowngradeAfterClose(
    List<Opportunity> newList,
    Map<Id, Opportunity> oldMap
  ) {
    for (Opportunity opp : newList) {
      Opportunity old = oldMap.get(opp.Id);
      if (
        old.StageName == 'Closed Lost' &&
        opp.StageName != 'Closed Lost' &&
        opp.Description?.contains('[reopen]') != true
      ) {
        opp.addError(
          'Cannot reopen a Closed Lost opportunity without [reopen] in the description.'
        );
      }
    }
  }

  // Creates a follow-up Task when an opportunity moves to Closed Won.
  static void handleStageChange(
    List<Opportunity> newList,
    Map<Id, Opportunity> oldMap
  ) {
    List<Task> tasks = new List<Task>();
    for (Opportunity opp : newList) {
      if (
        opp.StageName == 'Closed Won' &&
        oldMap.get(opp.Id).StageName != 'Closed Won'
      ) {
        tasks.add(
          new Task(
            WhatId = opp.Id,
            OwnerId = opp.OwnerId,
            Subject = 'Send onboarding materials — ' + opp.Name,
            ActivityDate = Date.today().addDays(3),
            Priority = 'High',
            Status = 'Not Started'
          )
        );
      }
    }
    if (!tasks.isEmpty()) {
      insert tasks;
    }
  }
}
