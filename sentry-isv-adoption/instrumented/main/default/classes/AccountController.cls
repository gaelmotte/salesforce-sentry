public with sharing class AccountController {
  // Plain @AuraEnabled method — codemod should wrap and use AuraHandledException
  @AuraEnabled(cacheable=true)
  public static Account getAccountDetails(Id accountId) {
    try {
      return [
        SELECT Id, Name, Industry, AnnualRevenue, NumberOfEmployees, OwnerId
        FROM Account
        WHERE Id = :accountId
        LIMIT 1
      ];
    } catch (Exception e) {
      Sentry.captureException(e);
      throw new AuraHandledException(e.getMessage());
    }
  }

  // Another @AuraEnabled — DML, non-cacheable
  @AuraEnabled
  public static void updateAccountStatus(Id accountId, String status) {
    try {
      Sentry.log('Updating account ' + accountId + ' status to: ' + status);
      Account acc = new Account(Id = accountId, Description = status);
      update acc;
      Sentry.log(LoggingLevel.INFO, 'Account status updated successfully');
    } catch (Exception e) {
      Sentry.captureException(e);
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<Contact> getContactsByAccount(Id accountId) {
    try {
      return [
        SELECT Id, FirstName, LastName, Email, Phone
        FROM Contact
        WHERE AccountId = :accountId
        ORDER BY LastName, FirstName
      ];
    } catch (Exception e) {
      Sentry.captureException(e);
      throw new AuraHandledException(e.getMessage());
    }
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
