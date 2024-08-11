/**
 * This is the sdk internal representation of an Event Payload.
 * It is :
 * 1. populated by the client from scope
 * 2. Sent as a platform event
 * 3. Parsed from platform event
 * 4. Enriched with more data that take time to retrieve
 * 5. Transformed to a payload sentry api does recognize
 *
 */
public with sharing class SentryEvent implements JSONDeserializer.Deserializable {
  /**
   * exception that caused the event
   * Some processors might need it
   */
  private Exception originException;
  /**
   * message that caused the event
   * Some processors might need it
   */
  private String originMessage;
  /**
   * flowInterviewGUID that caused the event
   * Some processors might need it
   */
  private SentryFlowError originFlowError;

  // Fields that are part of the Sentry Payload

  /**
   * 32 chars, a Uuid without dash = Crypto AES 128
   */
  public string eventId { get; private set; }
  public SentryLogEntry logentry;
  public String release;
  public String transac; // naming trouble
  public List<SentryBreadcrumb> breadcrumbs;
  public Map<String, Object> contexts;
  public List<SentryValueClass> ex; // naming trouble & type trouble.
  public Map<String, Object> extra;
  public Map<String, String> tags;
  public Map<String, Object> request;
  public SentryUser user;
  public List<SentryEventProcessingError> errors;

  public void setDeserializedField(String key, Object value) {
    switch on key {
      when 'event_id' {
        this.eventId = (String) value;
      }
      when 'logentry' {
        this.logentry = (SentryLogEntry) value;
      }
      when 'transaction' {
        this.transac = (String) value;
      }
      when 'breadcrumbs' {
        this.breadcrumbs = (List<SentryBreadcrumb>) value;
      }
      when 'contexts' {
        this.contexts = (Map<String, Object>) value;
      }
      when 'exception' {
        this.ex = (List<SentryValueClass>) value;
      }
      when 'extra' {
        this.extra = (Map<String, Object>) value;
      }
      when 'tags' {
        this.tags = (Map<String, String>) value;
      }
      when 'request' {
        this.request = (Map<String, Object>) value;
      }
      when 'user' {
        this.user = (SentryUser) value;
      }
      when 'errors' {
        this.errors = (List<SentryEventProcessingError>) value;
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
      'eventId' => String.class,
      'logentry' => SentryLogEntry.class,
      'release' => String.class,
      'transaction' => String.class,
      'breadcrumbs' => List<SentryBreadcrumb>.class,
      'contexts' => Map<String, Object>.class,
      'exception' => List<SentryValueClass>.class,
      'extra' => Map<String, Object>.class,
      'tags' => Map<String, String>.class,
      'request' => Map<String, Object>.class,
      'user' => SentryUser.class,
      'errors' => List<SentryEventProcessingError>.class
    };
  }

  /**
   * Do not instanciate SentryEvent from this constructor. It is required for deserialization but should not be used.
   */
  public SentryEvent() {
    this.eventId = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
    this.contexts = new Map<String, Object>();
    this.tags = new Map<String, String>();
    this.extra = new Map<String, Object>();
    this.breadcrumbs = new List<SentryBreadcrumb>();
    this.errors = new List<SentryEventProcessingError>();
  }

  public static SentryEvent fromApexException(Exception ex) {
    SentryEvent event = new SentryEvent();
    event.originException = ex;
    return event;
  }

  // public SentryEvent(String message) {
  //   this();
  //   this.originMessage = message;
  // }

  public static SentryEvent fromFlowFault(
    String flowInterviewGUID,
    String flowFaultMessage
  ) {
    SentryEvent event = new SentryEvent();
    event.originFlowError = new SentryFlowError(
      flowInterviewGUID,
      flowFaultMessage
    );
    return event;
  }

  public static SentryEvent fromLWCError(
    Sentry.SentryLWCErrorInputParameters eventInput
  ) {
    SentryEvent event = new SentryEvent();
    //TODO
    return event;
  }

  public static SentryEvent fromPlatformEvent(Sentry_Event__e event) {
    return deserialize(event.SentryEventJson__c);
  }

  public Exception getOriginException() {
    return this.originException;
  }

  public String getOriginMessage() {
    return this.originMessage;
  }

  public SentryFlowError getOriginFlowError() {
    return this.originFlowError;
  }

  public Sentry_Event__e toPlatformEvent() {
    return new Sentry_Event__e(
      SentryEventJson__c = serialize(),
      Event_Id__c = eventId
    );
  }

  public static SentryEvent deserialize(String jsonString) {
    return (SentryEvent) JSONDeserializer.deserialize(
      jsonString,
      SentryEvent.class
    );
  }

  public String serialize() {
    Map<String, Object> payloadMap = new Map<String, Object>{
      'event_id' => eventId,
      'logentry' => logentry,
      'release' => release,
      'transaction' => transac, // namming trouble
      'exception' => ex, // namming trouble
      'breadcrumbs' => breadcrumbs,
      'contexts' => contexts,
      'extra' => extra,
      'tags' => tags,
      'request' => request,
      'user' => user,
      'platform' => 'other',
      'errors' => errors
    };
    // clear null fields
    for (String key : payloadMap.keySet()) {
      if (payloadMap.get(key) == null) {
        payloadMap.remove(key);
      }
    }
    return JSON.serialize(payloadMap, true); // do not serialize empty fields
  }
}
