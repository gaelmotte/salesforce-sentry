@IsTest
private class LeadProcessorTest {
  @IsTest
  static void testHighRevenue_hotEnterprise() {
    LeadProcessor.LeadInput input = new LeadProcessor.LeadInput();
    input.annualRevenue = 5000000;
    List<LeadProcessor.LeadResult> results = LeadProcessor.processLeads(
      new List<LeadProcessor.LeadInput>{ input }
    );
    System.assertEquals(1, results.size());
    System.assertEquals('Hot', results[0].score);
    System.assertEquals('Enterprise', results[0].queue);
  }

  @IsTest
  static void testLowRevenue_coldSMB() {
    LeadProcessor.LeadInput input = new LeadProcessor.LeadInput();
    input.annualRevenue = 500000;
    List<LeadProcessor.LeadResult> results = LeadProcessor.processLeads(
      new List<LeadProcessor.LeadInput>{ input }
    );
    System.assertEquals(1, results.size());
    System.assertEquals('Cold', results[0].score);
    System.assertEquals('SMB', results[0].queue);
  }

  @IsTest
  static void testMultipleInputs() {
    LeadProcessor.LeadInput hot = new LeadProcessor.LeadInput();
    hot.annualRevenue = 2000000;
    LeadProcessor.LeadInput cold = new LeadProcessor.LeadInput();
    cold.annualRevenue = 100;
    List<LeadProcessor.LeadResult> results = LeadProcessor.processLeads(
      new List<LeadProcessor.LeadInput>{ hot, cold }
    );
    System.assertEquals(2, results.size());
    System.assertEquals('Hot', results[0].score);
    System.assertEquals('Cold', results[1].score);
  }
}
