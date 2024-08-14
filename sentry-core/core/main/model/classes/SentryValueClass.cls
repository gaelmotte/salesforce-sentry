/**
 * https://develop.sentry.dev/sdk/event-payloads/types/#valueclass
 */
public with sharing class SentryValueClass implements JSONDeserializer.Deserializable {
  public SentryValueClassMechanism mechanism;
  //   public String module;
  public Stacktrace stacktrace;
  public String type; // exception.getTypeName()
  public String value; // exception.getMessage()

  public void setDeserializedField(String key, Object value) {
    switch on key {
      when 'mechanism' {
        this.mechanism = (SentryValueClassMechanism) value;
      }
      when 'stacktrace' {
        this.stacktrace = (Stacktrace) value;
      }
      when 'type' {
        this.type = (String) value;
      }
      when 'value' {
        this.value = (String) value;
      }
      when else {
        throw new IllegalArgumentException(
          'Key [' + key + '] is not supported'
        );
      }
    }
  }
  public Map<String, System.Type> getDeserializableFields() {
    return new Map<String, System.Type>{
      'mechanism' => SentryValueClassMechanism.class,
      'stacktrace' => Stacktrace.class,
      'type' => String.class,
      'value' => String.class
    };
  }

  public class Stacktrace {
    public List<Frame> frames;
    public Stacktrace() {
      this.frames = new List<Frame>();
    }
  }

  public class Frame {
    public Frame() {
    }

    // Constructor for APEX Exception
    public Frame(SentryStacktraceParser.ApexFrame apexFrame) {
      this.filename = apexFrame.classname;
      this.module = apexFrame.subclassname != null
        ? apexFrame.classname + '.' + apexFrame.subclassname
        : apexFrame.classname;
      this.function = apexFrame.function;
      this.lineno = apexFrame.linenumber;
      this.namespace = apexFrame.namespace;
    }

    // Construction for Flow Synthetic Exception
    public Frame(SentryStacktraceParser.FlowFrame flowFrame) {
      this.filename = flowFrame.flowDeveloperName;
      this.namespace = flowFrame.namespace;
    }

    public String context_line;
    public String filename; // classname
    public String module; // classname or classname.subclassname
    public String function;
    public Boolean in_app;
    public Integer lineno;
    public String namespace; // namespace TODO SERIALIZE THIS AS `PACKAGE`
    public List<String> post_context;
    public List<String> pre_context;
    public String platform; // the api version the class is ran
  }

  //^([^(]*) \((.*):(\d*):(\d*)\)$
  public static final Pattern FRAME_PATTERN = Pattern.compile(
    '^([^(]*) \\((.*):(\\d*):(\\d*)\\)$'
  );

  // Contructor for LWC Error
  public static Frame fromLWCStack(String stackTraceLine) {
    Matcher matcher = FRAME_PATTERN.matcher(stackTraceLine);
    if (!matcher.find()) {
      Frame frame = new Frame();
      frame.function = stackTraceLine;
      return frame;
    }

    Frame frame = new Frame();
    frame.module = matcher.group(2);
    frame.function = matcher.group(1);
    frame.lineno = Integer.valueOf(matcher.group(3));
    // NO colno

    return frame;
  }

  // Constructor for LWC Error CMP stack
  // Just set the module property
}
