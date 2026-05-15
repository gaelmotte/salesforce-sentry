global with sharing class SentryFlowInputParameters {
  @InvocableVariable(label='Flow Interview GUID' required=true)
  global String interviewGUID;
  @InvocableVariable(label='Flow Fault Message' required=true)
  global String faultMessage;
  @InvocableVariable(label='Element Api Name' required=true)
  global String elementApiName;
  @InvocableVariable(label='Flow defition id' required=true)
  global String flowDefinitionId;
}
