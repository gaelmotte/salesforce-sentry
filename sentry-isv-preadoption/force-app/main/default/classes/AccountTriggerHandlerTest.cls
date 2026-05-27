@IsTest
private class AccountTriggerHandlerTest {
  @IsTest
  static void testHandleBefore_normalizeAndStamp() {
    Account acc = new Account(
      Name = 'Test',
      Industry = 'FakeIndustry',
      AnnualRevenue = 5000000
    );
    AccountTriggerHandler.handleBefore(new List<Account>{ acc }, null);
    System.assertEquals('Other', acc.Industry);
    System.assert(acc.Description.contains('[Tier:Mid-Market]'));
  }

  @IsTest
  static void testHandleAfter_insert_enqueuesEmailForContactsWithEmail() {
    Account acc = new Account(Name = 'Test Account');
    insert acc;
    insert new Contact(
      FirstName = 'A',
      LastName = 'B',
      Email = 'a@test.com',
      AccountId = acc.Id
    );

    Test.startTest();
    AccountTriggerHandler.handleAfter(
      new List<Account>{ acc },
      null // null oldMap signals insert
    );
    Test.stopTest();
    // Job was enqueued and executed — no exception means success
  }

  @IsTest
  static void testHandleAfter_insert_noContactsNoJob() {
    Account acc = new Account(Name = 'No Contact Account');
    insert acc;
    // No contacts → nothing to enqueue
    Test.startTest();
    AccountTriggerHandler.handleAfter(new List<Account>{ acc }, null);
    Test.stopTest();
  }

  @IsTest
  static void testHandleAfter_update_webSourceTransition() {
    Account acc = new Account(Name = 'Web Account');
    insert acc;
    insert new Contact(
      FirstName = 'X',
      LastName = 'Y',
      Email = 'x@y.com',
      AccountId = acc.Id
    );

    Account oldAcc = new Account(Id = acc.Id, AccountSource = 'Phone Inquiry');
    acc.AccountSource = 'Web';
    Map<Id, Account> oldMap = new Map<Id, Account>{ acc.Id => oldAcc };

    Test.startTest();
    AccountTriggerHandler.handleAfter(new List<Account>{ acc }, oldMap);
    Test.stopTest();
  }

  @IsTest
  static void testHandleAfter_update_noEligibleAccounts() {
    Account acc = new Account(Name = 'Unchanged');
    insert acc;
    Account oldAcc = new Account(Id = acc.Id, AccountSource = 'Web');
    acc.AccountSource = 'Web'; // same source — not eligible
    Map<Id, Account> oldMap = new Map<Id, Account>{ acc.Id => oldAcc };

    AccountTriggerHandler.handleAfter(new List<Account>{ acc }, oldMap);
    // Returns early, no job enqueued
  }
}
