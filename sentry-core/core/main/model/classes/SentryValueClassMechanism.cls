public with sharing class SentryValueClassMechanism implements JSONDeserializer.Deserializable {
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
