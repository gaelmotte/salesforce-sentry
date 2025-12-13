global class SentryLWCErrorInputParameters {
  @AuraEnabled
  public String error { get; set; }
  @AuraEnabled
  public List<String> stack { get; set; }
  @AuraEnabled
  public List<String> cmpStack { get; set; }
  @AuraEnabled
  public List<SentryLWCLog> logs { get; set; }
  @AuraEnabled
  public Datetime timestamp { get; set; }
  @AuraEnabled
  public String mechanism { get; set; }

  global class SentryLWCLog {
    @AuraEnabled
    public String message { get; set; }
    @AuraEnabled
    public String componentName { get; set; }
    @AuraEnabled
    public Datetime timestamp { get; set; }
  }
}
