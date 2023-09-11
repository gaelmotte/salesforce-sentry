/**
 * https://develop.sentry.dev/sdk/event-payloads/types/#valueclass
 */
public with sharing class SentryValueClass {
  public Mechanism mechanism;
  //   public String module;
  public Stacktrace stacktrace;
  public String type; // exception.getTypeName()
  public String value; // exception.getMessage()

  private SentryValueClass(Exception ex) {
    this.type = ex.getTypeName();
    this.value = ex.getMessage();
  }

  public static List<SentryValueClass> fromException(Exception ex) {
    List<SentryValueClass> values = new List<SentryValueClass>{
      new SentryValueClass(ex)
    };
    Exception cause = ex.getCause();
    while (cause != null) {
      values.add(new SentryValueClass(cause));
      cause = cause.getCause();
    }
    return values;
  }

  public class Mechanism {
    public String type;
    public Map<String, Object> data;
  }

  public class Stacktrace {
    public List<Frame> frames;
  }

  public class Frame {
    public String context_line;
    public String filename;
    public String function;
    public Boolean in_app;
    public Integer lineno;
    // public String package; // namespace
    public List<String> post_context;
    public List<String> pre_context;
  }
}
