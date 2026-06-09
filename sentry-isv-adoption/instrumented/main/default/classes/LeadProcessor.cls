public with sharing class LeadProcessor {
  @InvocableMethod(
    label='Process Lead'
    description='Scores and routes a lead based on company size'
  )
  public static List<LeadResult> processLeads(List<LeadInput> inputs) {
    try {
      List<LeadResult> results = new List<LeadResult>();
      Sentry.log('Processing ' + inputs.size() + ' lead(s)');
      for (LeadInput input : inputs) {
        LeadResult result = new LeadResult();
        result.score = input.annualRevenue > 1000000 ? 'Hot' : 'Cold';
        result.queue = result.score == 'Hot' ? 'Enterprise' : 'SMB';
        Sentry.log(
          LoggingLevel.DEBUG,
          'Lead scored: ' + result.score + ' → queue: ' + result.queue
        );
        results.add(result);
      }
      return results;
    } catch (Exception e) {
      Sentry.captureException(e);
      throw e;
    }
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
