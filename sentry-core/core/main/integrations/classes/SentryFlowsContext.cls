public with sharing class SentryFlowsContext extends SentryContext {
  public static final String TYPE = 'flow';
  private SentryFlowDetails details;

  public SentryFlowsContext(SentryFlowDetails details) {
    this.details = details;
    this.type = TYPE;
  }

  public override Map<String, Object> getData() {
    Map<String, object> data = new Map<String, object>();
    // add flow detail as mechanism of the exception
    data.put('FlowDeveloperName', details.developerName);
    // data.put('FlowInterviewGuid', details.interviewGuid);
    data.put('FlowLabel', details.label);
    data.put('FlowVersionNumber', details.versionNumber);
    // data.put('FlowNamespace', details.namespace);

    return data;
  }
}
