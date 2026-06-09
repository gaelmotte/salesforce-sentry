global with sharing class AccountController {
  // Plain @AuraEnabled method — codemod should wrap and use AuraHandledException
  @AuraEnabled(cacheable=true)
  global static Account getAccountDetails(Id accountId) {
    return [
      SELECT Id, Name, Industry, AnnualRevenue, NumberOfEmployees, OwnerId
      FROM Account
      WHERE Id = :accountId
      LIMIT 1
    ];
  }

  // Another @AuraEnabled — DML, non-cacheable
  @AuraEnabled
  global static void updateAccountStatus(Id accountId, String status) {
    System.debug('Updating account ' + accountId + ' status to: ' + status);
    Account acc = new Account(Id = accountId, Description = status);
    update acc;
    System.debug(LoggingLevel.INFO, 'Account status updated successfully');
  }

  @AuraEnabled(cacheable=true)
  global static List<Contact> getContactsByAccount(Id accountId) {
    return [
      SELECT Id, FirstName, LastName, Email, Phone
      FROM Contact
      WHERE AccountId = :accountId
      ORDER BY LastName, FirstName
    ];
  }

  // Already has try-catch but no Sentry — codemod should SKIP this one
  @AuraEnabled
  global static List<Account> searchAccounts(String searchTerm) {
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
