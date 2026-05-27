public with sharing class SampleController {
  @AuraEnabled
  public static String getRecord(Id recordId) {
    try {
      return [SELECT Name FROM Account WHERE Id = :recordId].Name;
    } catch (Exception e) {
      sentrysdk.Sentry.captureException(e);
      throw new AuraHandledException(e.getMessage());
    }
  }
}
