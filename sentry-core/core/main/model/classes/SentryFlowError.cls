public class SentryFlowError {
  public String flowIntervieuwGuid;
  public String flowFaultMessage;
  public string flowElementApiName;
  public string flowDefinitionId;

  public SentryFlowError(
    String flowIntervieuwGuid,
    String flowFaultMessage,
    string flowElementApiName,
    string flowDefinitionId
  ) {
    this.flowIntervieuwGuid = flowIntervieuwGuid;
    this.flowFaultMessage = flowFaultMessage;
    this.flowElementApiName = flowElementApiName;
    this.flowDefinitionId = flowDefinitionId;
  }
}
