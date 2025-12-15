trigger LeadTrigger on Lead(before insert, before update) {
  try {
    LeadManagement.spreadAnnualRevenueAmmongLeads(Trigger.new);
  } catch (Exception e) {
    sentrysdk.Sentry.captureException(e);
    throw (e);
  }
}
