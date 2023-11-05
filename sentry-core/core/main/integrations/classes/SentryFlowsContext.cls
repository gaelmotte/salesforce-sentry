public with sharing class SentryFlowsContext extends SentryContext {
  public static final String TYPE = 'flow';
  private List<SentryFlowDetails> interviewLogList;

  public SentryFlowsContext(List<SentryFlowDetails> interviewLogList) {
    this.interviewLogList = interviewLogList;
    this.type = TYPE;
  }

  public override Map<String, Object> getData() {
    Map<String, object> data = new Map<String, object>();

    if (!interviewLogList.isEmpty()) {
      for (SentryFlowDetails log : interviewLogList) {
        // add flow detail as mechanism of the exception
        data.put('FlowDeveloperName', log.developerName);
        data.put('FlowInterviewGuid', log.interviewGuid);
        data.put('FlowLabel', log.label);
        data.put('FlowVersionNumber', log.versionNumber);
        data.put('FlowNamespace', log.namespace);
      }
    }
    return data;
  }
}
