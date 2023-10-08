public class SentryEventProcessingError {
  public String name;
  public String type;
  public Object value;

  /**
   * name is key in the event that encontered the issue
   */
  public SentryEventProcessingError(String name, String type, Object value) {
    this.name = name;
    this.type = type;
    this.value = value;
  }
}
