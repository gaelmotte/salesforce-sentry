public with sharing class SentryFlowFaultEventProcessor extends SentryEventProcessor {
  private List<FlowInterviewLog> interviewLogList;
  private String flowInterviewGUID;

  public SentryFlowFaultEventProcessor() {
    interviewLogList = new List<FlowInterviewLog>();
  }

  public override SentryEvent processAtCapture(SentryEvent event) {
    this.flowInterviewGUID = event.getFlowInterviewGUID();
    // save the flow interview GUID as extra
    event.extra = new Map<String, Object>();
    event.extra.put('FlowInterviewGUID', flowInterviewGUID);
    // extract the fault message
    event.ex = fromFaultMessage(event.getOriginMessage());
    return event;
  }

  private List<SentryValueClass> fromFaultMessage(String faultMessage) {
    List<SentryValueClass> values = new List<SentryValueClass>{ extract(faultMessage) };
    return values;
  }
  
  private SentryValueClass extract(String faultMessage) {
    SentryValueClass valueClass = new SentryValueClass();

    valueClass.type = 'Flow Exception';
    valueClass.value = faultMessage;
    //valueClass.mechanism = getStrategy(ex).getMechanism(ex);

    return valueClass;
  }
  
  /**
   * Add flow context
   */
  public override SentryEvent processAtTransport(SentryEvent event) {
    fetchFlowInterviewLogs(event);
    return addFlowDetails(event);
  }

  private SentryEvent addFlowDetails(SentryEvent event) {
    // check if flow logs exist
    if(!interviewLogList.isEmpty()) {
      SentryValueClassMechanism mechanismValues = new SentryValueClassMechanism();
      for (SentryValueClass ex : event.ex) {
        for (FlowInterviewLog log : interviewLogList) {          
          // add flow detail as mechanism of the exception
          Map<String, Object> data = new Map<String, Object>{
            'flowDeveloperName' => log.FlowDeveloperName,
            'flowInterviewGuid' => log.FlowInterviewGuid,
            'flowLabel' => log.FlowLabel,
            'flowVersionNumber' => log.FlowVersionNumber,
            'interviewStatus' => log.InterviewStatus,
            'interviewDurationInMinutes' => log.InterviewDurationInMinutes
          };
          mechanismValues.data = data;
          mechanismValues.type = 'generic';
          mechanismValues.synthetic = true;
          ex.mechanism = mechanismValues;
        }
      }
    }
    return event;
  }

  private void fetchFlowInterviewLogs(SentryEvent event) {   
    // read FlowInterViewId from the event
    String flowInterviewGUID = (String) event.extra.get('FlowInterviewGUID');
    if(String.isNotBlank(flowInterviewGUID)) {
      for (FlowInterviewLog log : [SELECT
                                  FlowDeveloperName,
                                  FlowInterviewGuid,
                                  FlowLabel,
                                  FlowNamespace,
                                  FlowVersionNumber,
                                  InterviewDurationInMinutes,
                                  InterviewEndTimestamp,
                                  InterviewStartTimestamp,
                                  InterviewStatus
                                FROM FlowInterviewLog
                                WHERE FlowInterviewGuid = :flowInterviewGUID
      ]) {
        interviewLogList.add(log);
      }
    }
  }
}
