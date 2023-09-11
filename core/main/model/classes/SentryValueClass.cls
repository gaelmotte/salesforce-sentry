/**
 * https://develop.sentry.dev/sdk/event-payloads/types/#valueclass
 */
public with sharing class SentryValueClass {
  public Mechanism mechanism;
  //   public String module;
  public Stacktrace stacktrace;
  public String type; // exception.getTypeName()
  public String value; // exception.getMessage()

  public SentryValueClass() {
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
