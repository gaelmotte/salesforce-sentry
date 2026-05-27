public with sharing class AccountService {
  static final Set<String> VALID_INDUSTRIES = new Set<String>{
    'Agriculture',
    'Apparel',
    'Banking',
    'Chemicals',
    'Communications',
    'Construction',
    'Consulting',
    'Education',
    'Electronics',
    'Energy',
    'Engineering',
    'Entertainment',
    'Environmental',
    'Finance',
    'Food & Beverage',
    'Government',
    'Healthcare',
    'Hospitality',
    'Insurance',
    'Machinery',
    'Manufacturing',
    'Media',
    'Not For Profit',
    'Recreation',
    'Retail',
    'Shipping',
    'Technology',
    'Telecommunications',
    'Transportation',
    'Utilities',
    'Other'
  };

  // Clears invalid picklist values before insert/update so records don't fail
  // validation rules on the Industry field.
  public static void normalizeIndustry(List<Account> accounts) {
    for (Account acc : accounts) {
      if (acc.Industry != null && !VALID_INDUSTRIES.contains(acc.Industry)) {
        acc.Industry = 'Other';
      }
    }
  }

  // Derives a tier tag from AnnualRevenue and stores it in the Description
  // field as a structured prefix, e.g. "[Tier:Enterprise] Original notes…"
  public static void stampRevenueTier(
    List<Account> newAccounts,
    Map<Id, Account> oldMap
  ) {
    for (Account acc : newAccounts) {
      Boolean revenueChanged =
        oldMap == null ||
        acc.AnnualRevenue != oldMap.get(acc.Id)?.AnnualRevenue;
      if (!revenueChanged)
        continue;

      String tier;
      if (acc.AnnualRevenue == null || acc.AnnualRevenue < 100000) {
        tier = 'SMB';
      } else if (acc.AnnualRevenue < 10000000) {
        tier = 'Mid-Market';
      } else {
        tier = 'Enterprise';
      }

      String existing = acc.Description != null ? acc.Description : '';
      // Remove any previous tier prefix before writing the new one
      existing = existing.replaceAll('\\[Tier:[^\\]]+\\]\\s*', '').trim();
      acc.Description = '[Tier:' + tier + '] ' + existing;
    }
  }

  // Returns the Ids of contacts belonging to the given accounts that have an email address.
  public static List<Id> getPendingWelcomeContactIds(Set<Id> accountIds) {
    List<Id> ids = new List<Id>();
    for (Contact c : [
      SELECT Id
      FROM Contact
      WHERE AccountId IN :accountIds AND Email != NULL
    ]) {
      ids.add(c.Id);
    }
    return ids;
  }
}
