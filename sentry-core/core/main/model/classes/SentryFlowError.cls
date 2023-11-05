public class SentryFlowError {
  public String flowIntervieuwGuid;
  public String flowFaultMessage;

  public SentryFlowError(String flowIntervieuwGuid, String flowFaultMessage) {
    this.flowIntervieuwGuid = flowIntervieuwGuid;
    this.flowFaultMessage = flowFaultMessage;
  }
}