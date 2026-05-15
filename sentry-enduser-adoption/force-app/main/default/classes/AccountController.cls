public with sharing class AccountController {
  // Plain @AuraEnabled method — codemod should wrap and use AuraHandledException
  @AuraEnabled(cacheable=true)
  public static Account getAccountDetails(Id accountId) {
    return [
      SELECT Id, Name, Industry, AnnualRevenue, NumberOfEmployees, OwnerId
      FROM Account
      WHERE Id = :accountId
      LIMIT 1
    ];
  }

  // Another @AuraEnabled — DML, non-cacheable
  @AuraEnabled
  public static void updateAccountStatus(Id accountId, String status) {
    Account acc = new Account(Id = accountId, Description = status);
    update acc;
  }

  // Already has try-catch but no Sentry — codemod should SKIP this one
  @AuraEnabled
  public static List<Account> searchAccounts(String searchTerm) {
    try {
      String query = '%' + searchTerm + '%';
      return [
        SELECT Id, Name, Industry
        FROM Account
        WHERE Name LIKE :query
        LIMIT 50
      ];
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
