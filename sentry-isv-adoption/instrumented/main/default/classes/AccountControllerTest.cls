@IsTest
private class AccountControllerTest {
  @TestSetup
  static void setup() {
    Account acc = new Account(Name = 'Test Account', Industry = 'Technology');
    insert acc;
    Contact c = new Contact(
      FirstName = 'John',
      LastName = 'Doe',
      Email = 'john@test.com',
      AccountId = acc.Id
    );
    insert c;
  }

  @IsTest
  static void testGetAccountDetails() {
    Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
    Account result = AccountController.getAccountDetails(acc.Id);
    System.assertEquals('Test Account', result.Name);
    System.assertEquals('Technology', result.Industry);
  }

  @IsTest
  static void testUpdateAccountStatus() {
    Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
    AccountController.updateAccountStatus(acc.Id, 'Active');
    Account updated = [SELECT Description FROM Account WHERE Id = :acc.Id];
    System.assertEquals('Active', updated.Description);
  }

  @IsTest
  static void testGetContactsByAccount() {
    Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
    List<Contact> contacts = AccountController.getContactsByAccount(acc.Id);
    System.assertEquals(1, contacts.size());
    System.assertEquals('Doe', contacts[0].LastName);
  }

  @IsTest
  static void testSearchAccounts() {
    List<Account> results = AccountController.searchAccounts('Test');
    System.assertEquals(1, results.size());
    System.assertEquals('Test Account', results[0].Name);
  }
}
