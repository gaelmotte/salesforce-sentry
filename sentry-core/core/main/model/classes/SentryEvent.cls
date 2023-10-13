/**
 * This is the sdk internal representation of an Event Payload.
 * It is :
 * 1. populated by the client from scope
 * 2. Sent as a platform event
 * 3. Parsed from platform event
 * 4. Enriched with more data that take time to retrieve
 * 5. Transformed to a payload sentry api does recognize
 *
 * To prevent issues with deserialization when it involves polymorphic members (contexts for instance),
 * we will stick to plain old datatypes when polymorphism is used.
 */
public with sharing class SentryEvent {
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

  public SentryEvent() {
    this.eventId = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
    this.contexts = new Map<String, Object>();
    this.tags = new Map<String, String>();
    this.extra = new Map<String, Object>();
    this.breadcrumbs = new List<SentryBreadcrumb>();
    this.errors = new List<SentryEventProcessingError>();
  }

  public SentryEvent(Exception ex) {
    this();
    this.originException = ex;
  }

  public SentryEvent(String message) {
    this();
    this.originMessage = message;
  }

  public SentryEvent(Sentry_Event__e event) {
    this.eventId = event.Event_Id__c;
    this.logentry = event.Formatted_LogEntry__c != null
      ? new SentryLogEntry(event.Formatted_LogEntry__c)
      : null;
    this.release = event.Release__c;
    this.transac = event.Transaction__c;
    this.breadcrumbs = (List<SentryBreadcrumb>) JSON.deserialize(
      event.Breadcrumbs_Json__c,
      List<SentryBreadcrumb>.class
    );
    this.contexts = (Map<String, Object>) JSON.deserializeUntyped(
      event.Contexts_Json__c
    );
    this.ex = (List<SentryValueClass>) JSONDeserializer.deserialize(
      event.Exception_Json__c,
      List<SentryValueClass>.class
    );
    this.extra = (Map<String, Object>) JSON.deserialize(
      event.Extra_Json__c,
      Map<String, Object>.class
    );
    this.request = (Map<String, Object>) JSON.deserialize(
      event.Request_Json__c,
      Map<String, Object>.class
    );
    this.tags = (Map<String, String>) JSON.deserialize(
      event.Tags_Json__c,
      Map<String, String>.class
    );
    this.user = (SentryUser) JSON.deserialize(
      event.User_Json__c,
      SentryUser.class
    );
    this.errors = new List<SentryEventProcessingError>();
  }

  public Exception getOriginException() {
    return this.originException;
  }

  public String getOriginMessage() {
    return this.originMessage;
  }

  public Sentry_Event__e toPlatformEvent() {
    Sentry_Event__e event = new Sentry_Event__e();
    event.Event_Id__c = this.eventId;
    event.Formatted_LogEntry__c = this.logentry?.message.formatted;
    event.Release__c = this.release;
    event.Transaction__c = this.transac;
    event.Breadcrumbs_Json__c = JSON.serialize(this.breadcrumbs);
    event.Contexts_Json__c = JSON.serialize(this.contexts);
    event.Exception_Json__c = JSON.serialize(this.ex);
    event.Extra_Json__c = JSON.serialize(this.extra);
    event.Request_Json__c = JSON.serialize(this.request);
    event.Tags_Json__c = JSON.serialize(this.tags);
    event.User_Json__c = JSON.serialize(this.user);

    return event;
  }

  public String toJsonPayload() {
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
