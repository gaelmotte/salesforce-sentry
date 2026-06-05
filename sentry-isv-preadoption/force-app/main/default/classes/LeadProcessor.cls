public with sharing class LeadProcessor {
  @InvocableMethod(
    label='Process Lead'
    description='Scores and routes a lead based on company size'
  )
  public static List<LeadResult> processLeads(List<LeadInput> inputs) {
    List<LeadResult> results = new List<LeadResult>();
    System.debug('Processing ' + inputs.size() + ' lead(s)');
    for (LeadInput input : inputs) {
      LeadResult result = new LeadResult();
      result.score = input.annualRevenue > 1000000 ? 'Hot' : 'Cold';
      result.queue = result.score == 'Hot' ? 'Enterprise' : 'SMB';
      System.debug(
        LoggingLevel.DEBUG,
        'Lead scored: ' + result.score + ' → queue: ' + result.queue
      );
      results.add(result);
    }
    return results;
  }

  public class LeadInput {
    @InvocableVariable(required=true)
    public Decimal annualRevenue;
  }

  public class LeadResult {
    @InvocableVariable
    public String score;
    @InvocableVariable
    public String queue;
  }
}
