public with sharing class SentryMechanismSyntheticFlowExStrategy extends SentryMechanismExceptionStrategy {
  public virtual override System.Type getExceptionType() {
    return SentrySyntheticFlowException.class;
  }

  public virtual override SentryValueClassMechanism getMechanism(
    SentrySyntheticFlowException ex
  ) {
    SentryValueClassMechanism mechanism = super.getMechanism(ex);
    List<SentryFlowDetails> interviewLogList = ex.getInterviewLogs();

    if (!interviewLogList.isEmpty()) {
      for (SentryFlowDetails log : interviewLogList) {
        // add flow detail as mechanism of the exception
        Map<String, Object> data = new Map<String, Object>{
          'flowDeveloperName' => log.developerName,
          'flowInterviewGuid' => log.interviewGuid,
          'flowLabel' => log.label,
          'flowVersionNumber' => log.versionNumber,
          'flowNamespace' => log.namespace
        };
        mechanism.data = data;
      }
    }

    mechanism.synthetic = true;
    mechanism.type = getExceptionType().getName();

    return mechanism;
  }
}
