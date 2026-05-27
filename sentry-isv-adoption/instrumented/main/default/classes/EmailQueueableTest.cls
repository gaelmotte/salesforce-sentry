@IsTest
private class EmailQueueableTest {
  @IsTest
  static void testExecute_sendsEmailsToContactsWithEmail() {
    Account acc = new Account(Name = 'Email Test');
    insert acc;
    Contact c = new Contact(
      FirstName = 'Email',
      LastName = 'Recipient',
      Email = 'recipient@test.com',
      AccountId = acc.Id
    );
    insert c;

    Test.startTest();
    EmailQueueable q = new EmailQueueable(new List<Id>{ c.Id });
    q.execute(null);
    Test.stopTest();
  }

  @IsTest
  static void testExecute_noEmailsWhenNoContacts() {
    Test.startTest();
    EmailQueueable q = new EmailQueueable(new List<Id>());
    q.execute(null);
    Test.stopTest();
  }

  @IsTest
  static void testEnqueueJob() {
    Account acc = new Account(Name = 'Enqueue Test');
    insert acc;
    Contact c = new Contact(
      FirstName = 'Enqueue',
      LastName = 'Test',
      Email = 'enqueue@test.com',
      AccountId = acc.Id
    );
    insert c;

    Test.startTest();
    System.enqueueJob(new EmailQueueable(new List<Id>{ c.Id }));
    Test.stopTest();
  }
}
