public with sharing class SentryFlowFaultEventProcessor extends SentryEventProcessor {
  private SentryFlowDetails flowDetailsObj;

  public SentryFlowFaultEventProcessor() {
  }

  public override SentryEvent processAtCapture(SentryEvent event) {
    // Ignore if no exception (avoir error)
    if (event.getOriginFlowError() != null) {
      SentryFlowError flowErrorObj = event.getOriginFlowError();

      event.extra.put('FlowInterviewGUID', flowErrorObj.flowIntervieuwGuid);
      event.extra.put('FlowDefinitionId', flowErrorObj.flowDefinitionId);
      // extract the flow exception
      event.ex = fromFlowErrorObj(flowErrorObj);
    }
    return event;
  }

  private List<SentryValueClass> fromFlowErrorObj(
    SentryFlowError flowErrorObj
  ) {
    List<SentryValueClass> values = new List<SentryValueClass>();
    SentryValueClass valueClass = new SentryValueClass();
    SentrySyntheticFlowException ex = new SentrySyntheticFlowException(
      flowErrorObj.flowFaultMessage,
      flowErrorObj.flowElementApiName
    );
    SentryValueClass valueClass2 = new SentryValueClass();
    valueClass2.type = ex.getTypeName();
    valueClass2.value = flowErrorObj.flowFaultMessage;
    values.add(valueClass2);
    valueClass.type = ex.getTypeName();
    valueClass.value = flowErrorObj.flowElementApiName;
    values.add(valueClass);

    return values;
  }

  public override SentryEvent processAtTransport(SentryEvent event) {
    if (event.ex != null && event.extra.containsKey('FlowDefinitionId')) {
      String flowDefinitionId = (String) event.extra.get('FlowDefinitionId');
      // Get Flow details
      fetchFlowDetails(event);
      // fetchFlowVariables(event);
      // Add contexts and mechanisms
      //addMechanismsDetails(event);
      // decorateFramesWithDetails(event);
      addFlowContexts(event);
    }
    return event;
  }

  private void fetchFlowVariables(SentryEvent event) {
  }

  /* this could help bring information to the user when dealing with screen flows. they do not exist for autolaunched flows
   */
  private void fetchFlowDetails(SentryEvent event) {
    // For Test, create fictive details
    if (Test.isRunningTest()) {
      flowDetailsObj = new SentryFlowDetails('TEST', 'TEST', 'TEST', 1, null);
    } else {
      String flowInterviewGUID = (String) event.extra.get('FlowInterviewGUID');
      String flowDefinitionId = (String) event.extra.get('FlowDefinitionId');
      // Get FlowInterviewLog details
      for (FlowDefinitionView fdv : [
        SELECT
          id,
          durableId,
          VersionNumber,
          ApiName,
          LatestVersionId,
          Label,
          NamespacePrefix
        FROM FlowDefinitionView
        WHERE durableId = :flowDefinitionId
        LIMIT 1
      ]) {
        flowDetailsObj = new SentryFlowDetails(
          flowInterviewGUID,
          fdv.label,
          fdv.ApiName,
          fdv.VersionNumber,
          fdv.NamespacePrefix
        );
      }
    }
    // flowException.setInterviewLogs(this.interviewLogList);
  }

  // private void addMechanismsDetails(SentryEvent event) {
  //   for (SentryValueClass valueClass : event.ex) {
  //     valueClass.mechanism = new SentryMechanismSyntheticFlowExStrategy()
  //       .getMechanism(flowException);
  //   }
  // }

  // private void decorateFramesWithDetails(SentryEvent event) {
  //   for (SentryValueClass valueClass : event.ex) {
  //     valueClass.stacktrace = new SentryValueClass.Stacktrace();
  //     for (SentryFlowDetails log : this.interviewLogList) {
  //       SentryStacktraceParser.FlowFrame frame = new SentryStacktraceParser.FlowFrame();
  //       frame.namespace = log.namespace;
  //       frame.flowDeveloperName = log.developerName;
  //       valueClass.stacktrace.frames.add(new SentryValueClass.Frame(frame));
  //     }
  //   }
  // }

  private void addFlowContexts(SentryEvent event) {
    event.contexts.put(
      SentryFlowsContext.TYPE,
      new SentryFlowsContext(this.flowDetailsObj).getData()
    );
  }
}
