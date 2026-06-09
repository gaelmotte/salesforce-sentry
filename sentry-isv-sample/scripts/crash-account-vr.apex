// Triggers the RequireIndustry validation rule via the ISV package's
// AccountController.updateAccountStatus(). The method only updates Description,
// leaving Industry blank on Acme Corp → DmlException → Sentry.captureException().
Account acme = [SELECT Id FROM Account WHERE Name = 'Acme Corp' LIMIT 1];
try {
    sentrysdk.AccountController.updateAccountStatus(acme.Id, 'crash-test');
} catch (Exception e) {
    System.debug('Expected (Sentry captured it): ' + e.getMessage());
}
