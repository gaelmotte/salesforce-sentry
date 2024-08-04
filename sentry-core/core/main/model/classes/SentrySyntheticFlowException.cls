public with sharing class SentrySyntheticFlowException extends SentrySyntheticException {
  private List<SentryFlowDetails> interviewLogs;

  public SentrySyntheticFlowException(String guid, String faultMessage){    
    setMessage(faultMessage); // Define the exception message with the flow fault message
    setGuid(guid); 
    this.interviewLogs = new List<SentryFlowDetails>();
  }

  public void setInterviewLogs(List<SentryFlowDetails> value) {
    this.interviewLogs = value;
  }

  public List<SentryFlowDetails> getInterviewLogs() {
    return this.interviewLogs;
  }

}