@IsTest
private class AccountServiceTest {
  @IsTest
  static void testNormalizeIndustry_validStaysUnchanged() {
    Account acc = new Account(Name = 'Test', Industry = 'Technology');
    AccountService.normalizeIndustry(new List<Account>{ acc });
    System.assertEquals('Technology', acc.Industry);
  }

  @IsTest
  static void testNormalizeIndustry_invalidBecomesOther() {
    Account acc = new Account(Name = 'Test', Industry = 'FakeIndustry');
    AccountService.normalizeIndustry(new List<Account>{ acc });
    System.assertEquals('Other', acc.Industry);
  }

  @IsTest
  static void testNormalizeIndustry_nullUnchanged() {
    Account acc = new Account(Name = 'Test');
    AccountService.normalizeIndustry(new List<Account>{ acc });
    System.assertEquals(null, acc.Industry);
  }

  @IsTest
  static void testStampRevenueTier_smb() {
    Account acc = new Account(Name = 'Test', AnnualRevenue = 50000);
    AccountService.stampRevenueTier(new List<Account>{ acc }, null);
    System.assert(acc.Description.contains('[Tier:SMB]'), 'Expected SMB tier');
  }

  @IsTest
  static void testStampRevenueTier_nullRevenue() {
    Account acc = new Account(Name = 'Test');
    AccountService.stampRevenueTier(new List<Account>{ acc }, null);
    System.assert(acc.Description.contains('[Tier:SMB]'), 'Null revenue → SMB');
  }

  @IsTest
  static void testStampRevenueTier_midMarket() {
    Account acc = new Account(Name = 'Test', AnnualRevenue = 5000000);
    AccountService.stampRevenueTier(new List<Account>{ acc }, null);
    System.assert(
      acc.Description.contains('[Tier:Mid-Market]'),
      'Expected Mid-Market tier'
    );
  }

  @IsTest
  static void testStampRevenueTier_enterprise() {
    Account acc = new Account(Name = 'Test', AnnualRevenue = 50000000);
    AccountService.stampRevenueTier(new List<Account>{ acc }, null);
    System.assert(
      acc.Description.contains('[Tier:Enterprise]'),
      'Expected Enterprise tier'
    );
  }

  @IsTest
  static void testStampRevenueTier_existingPrefixReplaced() {
    Account acc = new Account(
      Name = 'Test',
      AnnualRevenue = 50000000,
      Description = '[Tier:SMB] some note'
    );
    AccountService.stampRevenueTier(new List<Account>{ acc }, null);
    System.assert(
      acc.Description.contains('[Tier:Enterprise]'),
      'Old tier replaced'
    );
    System.assert(!acc.Description.contains('[Tier:SMB]'), 'Old tier removed');
  }

  @IsTest
  static void testStampRevenueTier_noChangeSkipped() {
    Account acc = new Account(Name = 'NoChange', AnnualRevenue = 5000000);
    insert acc;
    Account oldVersion = new Account(Id = acc.Id, AnnualRevenue = 5000000);
    Map<Id, Account> oldMap = new Map<Id, Account>{ acc.Id => oldVersion };
    AccountService.stampRevenueTier(new List<Account>{ acc }, oldMap);
    System.assertEquals(
      null,
      acc.Description,
      'No change — description should remain null'
    );
  }

  @IsTest
  static void testGetPendingWelcomeContactIds() {
    Account acc = new Account(Name = 'Test Account');
    insert acc;
    insert new Contact(
      FirstName = 'A',
      LastName = 'B',
      Email = 'a@b.com',
      AccountId = acc.Id
    );
    insert new Contact(FirstName = 'C', LastName = 'D', AccountId = acc.Id); // no email
    List<Id> ids = AccountService.getPendingWelcomeContactIds(
      new Set<Id>{ acc.Id }
    );
    System.assertEquals(1, ids.size());
  }
}
