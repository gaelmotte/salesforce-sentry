public with sharing class OpportunityController {
  @AuraEnabled(cacheable=true)
  public static List<Opportunity> getOpportunities() {
    try {
      return [
        SELECT Id, Name, StageName, Amount, CloseDate, AccountId, Account.Name
        FROM Opportunity
        WHERE IsClosed = FALSE
        ORDER BY CloseDate ASC
        LIMIT 100
      ];
    } catch (Exception e) {
      Sentry.captureException(e);
      throw new AuraHandledException(e.getMessage());
    }
  }
}
