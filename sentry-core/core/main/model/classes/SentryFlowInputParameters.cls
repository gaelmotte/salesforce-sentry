public with sharing class SentryFlowInputParameters {
    @InvocableVariable(label='Flow Interview GUID' required = true )
    public String interviewGUID;
    @InvocableVariable(label='Flow Fault Message' required = true )
    public String faultMessage;
}