public class SentryFlowDetails {
  public String label { get; protected set; }
  public String developerName { get; protected set; }
  public String interviewGuid { get; protected set; }
  public Integer versionNumber { get; protected set; }
  public String namespace { get; protected set; }

  public SentryFlowDetails(
    String interviewGuid,
    String label,
    String developerName,
    Integer versionNumber,
    String namespace
  ) {
    this.label = label;
    this.developerName = developerName;
    this.interviewGuid = interviewGuid;
    this.versionNumber = versionNumber;
    this.namespace = namespace;
  }
}
