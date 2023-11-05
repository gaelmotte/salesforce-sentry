public with sharing class SentryFlowFaultEventProcessor extends SentryEventProcessor {
  private List<SentryFlowDetails> interviewLogList;
  private SentrySyntheticFlowException flowException;

  public SentryFlowFaultEventProcessor() {
    interviewLogList = new List<SentryFlowDetails>();
  }

  public override SentryEvent processAtCapture(SentryEvent event) {
    // Ignore if no exception (avoir error)
    if (event.getOriginFlowError() != null) {
      SentryFlowError flowErrorObj = event.getOriginFlowError();
      flowException = new SentrySyntheticFlowException(
        flowErrorObj.flowIntervieuwGuid,
        flowErrorObj.flowFaultMessage
      );
      // save the flow interview GUID as extra
      event.extra = new Map<String, Object>();
      event.extra.put('FlowInterviewGUID', flowException.getGuid());
      // extract the flow exception
      event.ex = fromException(flowException);
    }
    return event;
  }

  private List<SentryValueClass> fromException(
    SentrySyntheticFlowException ex
  ) {
    List<SentryValueClass> values = new List<SentryValueClass>{ extract(ex) };
    return values;
  }

  private SentryValueClass extract(SentrySyntheticFlowException ex) {
    SentryValueClass valueClass = new SentryValueClass();

    valueClass.type = ex.getTypeName();
    valueClass.value = ex.getMessage();

    return valueClass;
  }

  public override SentryEvent processAtTransport(SentryEvent event) {
    if (event.ex != null) {
      // Get Flow details
      String flowInterviewGUID = (String) event.extra.get('FlowInterviewGUID');
      flowException = new SentrySyntheticFlowException(flowInterviewGUID, null);
      fetchFlowInterviewLog(event);
      // Add contexts and mechanisms
      addMechanismsDetails(event);
      decorateFramesWithDetails(event);
      addFlowContexts(event);
    }
    return event;
  }

  private void fetchFlowInterviewLog(SentryEvent event) {
    // For Test, create fictive details
    if (Test.isRunningTest()) {
      SentryFlowDetails flowDetailsObj = new SentryFlowDetails(
        'TEST',
        'TEST',
        'TEST',
        1,
        null
      );
      this.interviewLogList.add(flowDetailsObj);
    } else {
      // Get FlowInterviewLog details
      for (FlowInterviewLog log : [
        SELECT
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
        WHERE FlowInterviewGuid = :flowException.getGuid()
        LIMIT 1
      ]) {
        SentryFlowDetails flowDetailsObj = new SentryFlowDetails(
          log.FlowInterviewGuid,
          log.FlowLabel,
          log.FlowDeveloperName,
          log.FlowVersionNumber,
          log.FlowNamespace
        );
        this.interviewLogList.add(flowDetailsObj);
      }
    }
    flowException.setInterviewLogs(this.interviewLogList);
  }

  private void addMechanismsDetails(SentryEvent event) {
    for (SentryValueClass valueClass : event.ex) {
      valueClass.mechanism = new SentryMechanismSyntheticFlowExStrategy()
        .getMechanism(flowException);
    }
  }

  private void decorateFramesWithDetails(SentryEvent event) {
    for (SentryValueClass valueClass : event.ex) {
      valueClass.stacktrace = new SentryValueClass.Stacktrace();
      for (SentryFlowDetails log : this.interviewLogList) {
        SentryStacktraceParser.FlowFrame frame = new SentryStacktraceParser.FlowFrame();
        frame.namespace = log.namespace;
        frame.flowDeveloperName = log.developerName;
        valueClass.stacktrace.frames.add(new SentryValueClass.Frame(frame));
      }
    }
  }

  private void addFlowContexts(SentryEvent event) {
    event.contexts.put(
      SentryFlowsContext.TYPE,
      new SentryFlowsContext(this.interviewLogList).getData()
    );
  }
}
