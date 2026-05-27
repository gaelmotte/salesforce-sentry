@IsTest
private class OpportunityControllerTest {
  @IsTest
  static void testGetOpportunities() {
    Account acc = new Account(Name = 'Opp Account');
    insert acc;
    Opportunity opp = new Opportunity(
      Name = 'Open Deal',
      StageName = 'Prospecting',
      Amount = 25000,
      CloseDate = Date.today().addDays(30),
      AccountId = acc.Id
    );
    insert opp;

    List<Opportunity> result = OpportunityController.getOpportunities();
    System.assert(!result.isEmpty());
    System.assertEquals('Opp Account', result[0].Account.Name);
  }

  @IsTest
  static void testGetOpportunities_excludesClosed() {
    Account acc = new Account(Name = 'Closed Opp Account');
    insert acc;
    Opportunity closed = new Opportunity(
      Name = 'Closed Deal',
      StageName = 'Closed Won',
      Amount = 10000,
      CloseDate = Date.today(),
      AccountId = acc.Id
    );
    insert closed;

    List<Opportunity> result = OpportunityController.getOpportunities();
    for (Opportunity o : result) {
      System.assert(
        !o.StageName.startsWith('Closed'),
        'Closed opportunities should be excluded'
      );
    }
  }
}
