/**
 * Developed by Doug Ayers, douglascayers.com https://github.com/douglascayers/sfdc-auto-convert-leads-process
 */
@isTest
private class ConvertLeadsInvocableTest {
  @isTest
  static void test_convert_lead_yes_opportunity() {
    Lead ld = new Lead(
      firstName = 'Marc',
      lastName = 'Benioff',
      company = 'Salesforce'
    );

    insert ld;

    Test.startTest();

    ConvertLeadsInvocable.LeadConvertRequest request = new ConvertLeadsInvocable.LeadConvertRequest();
    request.leadId = ld.id;
    request.convertedStatus = [
      SELECT id, masterLabel
      FROM LeadStatus
      WHERE isConverted = TRUE
      LIMIT 1
    ]
    .masterLabel;
    request.createOpportunity = true;
    request.opportunityName = 'Test Opportunity';
    request.ownerId = UserInfo.getUserId();
    request.sendEmailToOwner = true;

    List<ConvertLeadsInvocable.LeadConvertResult> results = ConvertLeadsInvocable.convertLeads(
      new List<ConvertLeadsInvocable.LeadConvertRequest>{ request }
    );

    Test.stopTest();

    System.assert(results != null);
    System.assertEquals(1, results.size());

    ConvertLeadsInvocable.LeadConvertResult result = results[0];

    System.assertEquals(
      1,
      [SELECT COUNT() FROM Account WHERE id = :result.accountId]
    );
    System.assertEquals(
      1,
      [SELECT COUNT() FROM Contact WHERE id = :result.contactId]
    );
    System.assertEquals(
      1,
      [SELECT COUNT() FROM Opportunity WHERE id = :result.opportunityId]
    );
  }

  @isTest
  static void test_convert_lead_no_opportunity() {
    Account acct = new Account(name = 'Salesforce');

    insert acct;

    Contact cont = new Contact(
      accountId = acct.id,
      firstName = 'Marc',
      lastName = 'Benioff'
    );

    insert cont;

    Lead ld = new Lead(
      firstName = 'Marc',
      lastName = 'Benioff',
      company = 'Salesforce'
    );

    insert ld;

    Test.startTest();

    ConvertLeadsInvocable.LeadConvertRequest request = new ConvertLeadsInvocable.LeadConvertRequest();
    request.leadId = ld.id;
    request.convertedStatus = [
      SELECT id, masterLabel
      FROM LeadStatus
      WHERE isConverted = TRUE
      LIMIT 1
    ]
    .masterLabel;
    request.createOpportunity = false;
    request.accountId = acct.id;
    request.contactId = cont.id;
    request.overwriteLeadSource = true;

    List<ConvertLeadsInvocable.LeadConvertResult> results = ConvertLeadsInvocable.convertLeads(
      new List<ConvertLeadsInvocable.LeadConvertRequest>{ request }
    );

    Test.stopTest();

    System.assert(results != null);
    System.assertEquals(1, results.size());

    ConvertLeadsInvocable.LeadConvertResult result = results[0];

    System.assertEquals(
      1,
      [
        SELECT COUNT()
        FROM Account
        WHERE id = :result.accountId AND id = :acct.id
      ]
    );
    System.assertEquals(
      1,
      [
        SELECT COUNT()
        FROM Contact
        WHERE id = :result.contactId AND id = :cont.id
      ]
    );
    System.assertEquals(
      0,
      [SELECT COUNT() FROM Opportunity WHERE id = :result.opportunityId]
    );
  }

  @isTest
  static void test_convert_lead_toexisting_records() {
    Lead ld = new Lead(
      firstName = 'M',
      lastName = 'B',
      company = 'Salesforce'
    );
    insert ld;

    Account account = new Account(Name = 'Salesforce');
    insert account;
    Contact contact = new Contact(
      FirstName = 'Marc',
      LastName = 'Benioff',
      AccountId = Account.Id
    );
    insert contact;
    Schema.DescribeFieldResult fieldResult = Opportunity.stagename.getDescribe();
    List<Schema.picklistEntry> stageNameValues = fieldResult.getPicklistValues();

    Opportunity opportunity = new Opportunity(
      AccountId = Account.Id,
      Name = 'Some Opportunity',
      StageName = stageNameValues[0].getValue(),
      CloseDate = Date.today()
    );
    insert Opportunity;

    ld = [select id, Name, Status, ConvertedContactId from Lead where Id = :ld.Id];

    Test.startTest();

    ConvertLeadsInvocable.LeadConvertRequest request = new ConvertLeadsInvocable.LeadConvertRequest();
    request.leadId = ld.id;
    request.convertedStatus = [
      SELECT id, masterLabel
      FROM LeadStatus
      WHERE isConverted = TRUE
      LIMIT 1
    ]
    .masterLabel;
    request.accountId = account.Id;
    request.contactId = contact.Id;
    request.opportunityId = opportunity.Id;
    request.ownerId = UserInfo.getUserId();
    request.sendEmailToOwner = true;

    List<ConvertLeadsInvocable.LeadConvertResult> results = ConvertLeadsInvocable.convertLeads(
      new List<ConvertLeadsInvocable.LeadConvertRequest>{ request }
    );

    Test.stopTest();

    System.assert(results != null);
    System.assertEquals(1, results.size());

    ConvertLeadsInvocable.LeadConvertResult result = results[0];
    ld = [
      SELECT Id, ConvertedAccountId, ConvertedContactId, ConvertedOpportunityId
      FROM Lead
      WHERE id = :ld.id
    ];

    System.assertEquals(ld.ConvertedAccountId, result.accountId);
    System.assertEquals(ld.ConvertedContactId, result.contactId);
    System.assertEquals(ld.ConvertedOpportunityId, result.opportunityId);
  }
}