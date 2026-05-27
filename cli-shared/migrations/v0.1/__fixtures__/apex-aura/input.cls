public with sharing class SampleController {
  @AuraEnabled
  public static String getRecord(Id recordId) {
    return [SELECT Name FROM Account WHERE Id = :recordId].Name;
  }
}
