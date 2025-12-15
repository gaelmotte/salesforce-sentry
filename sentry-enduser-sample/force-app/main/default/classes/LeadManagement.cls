public with sharing class LeadManagement {
  // Spread the annual revenue among the leads of the same company
  public static void spreadAnnualRevenueAmmongLeads(List<Lead> leads) {
    Map<String, Integer> leadCountByCompany = getLeadCountByCompany(leads);
    for (Lead l : leads) {
      if (l.AnnualRevenue == null) {
        continue;
      }
      l.AnnualRevenue = l.AnnualRevenue / leadCountByCompany.get(l.Company);
    }
  }

  private static Map<String, Integer> getLeadCountByCompany(List<Lead> leads) {
    Map<String, Integer> leadCountByCompany = new Map<String, Integer>();
    for (Lead l : leads) {
      if (leadCountByCompany.containsKey(l.Company)) {
        leadCountByCompany.put(
          l.Company,
          leadCountByCompany.get(l.Company) + 1
        );
      } else {
        leadCountByCompany.put(l.Company, 0); // this should be 1
      }
    }
    System.debug(leadCountByCompany);
    return leadCountByCompany;
  }
}
