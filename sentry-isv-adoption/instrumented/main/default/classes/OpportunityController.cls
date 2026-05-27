public with sharing class OpportunityController {
  @AuraEnabled(cacheable=true)
  public static List<Opportunity> getOpportunities() {
    return [
      SELECT Id, Name, StageName, Amount, CloseDate, AccountId, Account.Name
      FROM Opportunity
      WHERE IsClosed = FALSE
      ORDER BY CloseDate ASC
      LIMIT 100
    ];
  }
}
