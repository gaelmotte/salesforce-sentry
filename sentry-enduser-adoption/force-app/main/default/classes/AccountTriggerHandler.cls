public with sharing class AccountTriggerHandler {
  public static void handleBefore(
    List<Account> newAccounts,
    Map<Id, Account> oldMap
  ) {
    AccountService.normalizeIndustry(newAccounts);
    AccountService.stampRevenueTier(newAccounts, oldMap);
  }

  public static void handleAfter(
    List<Account> newAccounts,
    Map<Id, Account> oldMap
  ) {
    // Only send welcome emails on insert (oldMap is null) or when the account
    // transitions to Active status for the first time.
    Boolean isInsert = oldMap == null;
    Set<Id> eligibleIds = new Set<Id>();

    for (Account acc : newAccounts) {
      if (isInsert) {
        eligibleIds.add(acc.Id);
      } else if (
        acc.AccountSource == 'Web' &&
        oldMap.get(acc.Id).AccountSource != 'Web'
      ) {
        eligibleIds.add(acc.Id);
      }
    }

    if (eligibleIds.isEmpty())
      return;

    List<Id> contactIds = AccountService.getPendingWelcomeContactIds(
      eligibleIds
    );
    if (!contactIds.isEmpty()) {
      System.enqueueJob(new EmailQueueable(contactIds));
    }
  }
}
