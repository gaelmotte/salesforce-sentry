// Seed data for sentry-isv-sample crash scenarios.
//
// Scenario 2 — VR on Account (RequireIndustry)
//   Creates an Account with no Industry. Any subsequent call to
//   AccountController.updateAccountStatus() on this record triggers the VR
//   → DmlException caught by the instrumented try/catch → Sentry.captureException().
//
// Scenario 3 — NightlyBatchJob → unknown stage 'Stalled'
//   Creates an open Opportunity. Run the batch manually to mark it Stalled,
//   which fires OpportunityTrigger BEFORE_UPDATE → IllegalArgumentException →
//   caught by both the trigger and batch try/catch → two distinct Sentry captures.
//   Command: Database.executeBatch(new myisv.NightlyBatchJob());
//
// Scenario 1 (Contact VR) and Scenario 4 (bad Contact ID) are triggered via REST calls
// and do not need seed records:
//   1. POST /services/apexrest/sentrysdk/contacts  (body without 'email')
//   4. GET  /services/apexrest/sentrysdk/contacts/000000000000000

Account noIndustryAccount = new Account(
    Name = 'Acme Corp'
    // Industry intentionally blank — RequireIndustry VR fires on any ISV package update
);
insert noIndustryAccount;
System.debug('Seeded Account: ' + noIndustryAccount.Id + ' — no Industry, ready for updateAccountStatus() crash');

Opportunity staleOpp = new Opportunity(
    Name = 'Acme — Legacy Deal',
    AccountId = noIndustryAccount.Id,
    StageName = 'Prospecting',
    CloseDate = Date.today().addDays(30),
    Amount = 50000
);
insert staleOpp;
System.debug('Seeded Opportunity: ' + staleOpp.Id + ' — run NightlyBatchJob to trigger Stalled crash');
System.debug('Batch command: Database.executeBatch(new myisv.NightlyBatchJob());');
