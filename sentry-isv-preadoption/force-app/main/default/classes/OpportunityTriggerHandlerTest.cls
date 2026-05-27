@IsTest
private class OpportunityTriggerHandlerTest {
  static Account getOrCreateAccount() {
    List<Account> existing = [SELECT Id FROM Account LIMIT 1];
    if (!existing.isEmpty()) {
      return existing[0];
    }
    Account acc = new Account(Name = 'Opp Test Account');
    insert acc;
    return acc;
  }

  @IsTest
  static void testBeforeInsert_closeDateBumped() {
    Opportunity opp = new Opportunity(
      Name = 'Test',
      StageName = 'Prospecting',
      CloseDate = Date.today() // too soon
    );
    OpportunityTriggerHandler.run(
      new List<Opportunity>{ opp },
      null,
      null,
      System.TriggerOperation.BEFORE_INSERT
    );
    System.assert(opp.CloseDate >= Date.today().addDays(7));
    System.assertEquals(10, opp.Probability);
  }

  @IsTest
  static void testBeforeInsert_probabilitySetByStage() {
    Opportunity opp = new Opportunity(
      Name = 'Test',
      StageName = 'Qualification',
      CloseDate = Date.today().addDays(30)
    );
    OpportunityTriggerHandler.run(
      new List<Opportunity>{ opp },
      null,
      null,
      System.TriggerOperation.BEFORE_INSERT
    );
    System.assertEquals(20, opp.Probability);
  }

  @IsTest
  static void testBeforeUpdate_preventDowngradeFromClosedLost() {
    Account acc = getOrCreateAccount();
    Opportunity opp = new Opportunity(
      Name = 'Closed Deal',
      StageName = 'Prospecting',
      CloseDate = Date.today().addDays(30),
      AccountId = acc.Id,
      Amount = 10000
    );
    insert opp;

    Opportunity oldOpp = new Opportunity(
      Id = opp.Id,
      StageName = 'Closed Lost'
    );
    opp.StageName = 'Prospecting';
    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{ opp.Id => oldOpp };

    OpportunityTriggerHandler.run(
      new List<Opportunity>{ opp },
      new List<Opportunity>{ oldOpp },
      oldMap,
      System.TriggerOperation.BEFORE_UPDATE
    );
    System.assert(
      opp.hasErrors(),
      'Downgrade without [reopen] should add an error'
    );
  }

  @IsTest
  static void testBeforeUpdate_allowReopenWithFlag() {
    Account acc = getOrCreateAccount();
    Opportunity opp = new Opportunity(
      Name = 'Reopen Deal',
      StageName = 'Prospecting',
      CloseDate = Date.today().addDays(30),
      AccountId = acc.Id,
      Amount = 10000,
      Description = '[reopen]'
    );
    insert opp;

    Opportunity oldOpp = new Opportunity(
      Id = opp.Id,
      StageName = 'Closed Lost'
    );
    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{ opp.Id => oldOpp };

    OpportunityTriggerHandler.run(
      new List<Opportunity>{ opp },
      new List<Opportunity>{ oldOpp },
      oldMap,
      System.TriggerOperation.BEFORE_UPDATE
    );
    System.assert(
      !opp.hasErrors(),
      'Reopen with [reopen] flag should be allowed'
    );
  }

  @IsTest
  static void testAfterUpdate_taskCreatedOnClosedWon() {
    Account acc = getOrCreateAccount();
    Opportunity opp = new Opportunity(
      Name = 'Won Deal',
      StageName = 'Closed Won',
      CloseDate = Date.today(),
      AccountId = acc.Id,
      Amount = 50000
    );
    insert opp;
    opp = [
      SELECT Id, Name, StageName, OwnerId
      FROM Opportunity
      WHERE Id = :opp.Id
    ];

    Opportunity oldOpp = new Opportunity(
      Id = opp.Id,
      StageName = 'Negotiation/Review'
    );
    Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>{ opp.Id => oldOpp };

    Test.startTest();
    OpportunityTriggerHandler.run(
      new List<Opportunity>{ opp },
      new List<Opportunity>{ oldOpp },
      oldMap,
      System.TriggerOperation.AFTER_UPDATE
    );
    Test.stopTest();

    System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :opp.Id]);
  }
}
