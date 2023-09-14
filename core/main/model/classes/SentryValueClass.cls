/**
 * https://develop.sentry.dev/sdk/event-payloads/types/#valueclass
 */
public with sharing class SentryValueClass implements JSONDeserializer.Deserializable {
  public Mechanism mechanism;
  //   public String module;
  public Stacktrace stacktrace;
  public String type; // exception.getTypeName()
  public String value; // exception.getMessage()

  public void setDeserializedField(String key, Object value) {
    switch on key {
      when 'mechanism' {
        this.mechanism = (Mechanism) value;
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
      'mechanism' => Mechanism.class,
      'stacktrace' => Stacktrace.class,
      'type' => String.class,
      'value' => String.class
    };
  }

  public class Mechanism  implements JSONDeserializer.Deserializable {
    public String type;
    public Map<String, Object> data;


  public void setDeserializedField(String key, Object value) {
    switch on key {
      when 'data' {
        this.data = (Map<String, Object>) value;
      }
      when 'type' {
        this.type = (String) value;
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
      'data' => Map<String, Object>.class,
      'type' => String.class
    };
  }

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
