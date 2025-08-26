public with sharing class SentryEnvelope {
  private SentryEvent event;
  public SentryEnvelope(SentryEvent event) {
    this.event = event;
  }

  public String serialize() {
    String serialized = '';

    /* HEADER */
    Map<String, Object> headerMap = new Map<String, Object>{
      'event_id' => event.eventId
    };

    serialized += JSON.serialize(headerMap, true); // do not serialize empty fields
    serialized += '\n';

    /* ATTACHMENTS */
    // serialized +='{"type":"attachment","length":7,"content_type":"text/plain","filename":"hello.txt"}\n';
    // serialized +='Hello\r\n\n';
    //todo

    /* EVENT */
    string serializedEvent = event.serialize();
    Map<String, Object> eventHeaderMap = new Map<String, Object>{
      'type' => 'event',
      // 'length' => serializedEvent.length(),
      'content_type' => 'application/json'
    };
    serialized += JSON.serialize(eventHeaderMap, true); // do not serialize empty fields
    serialized += '\n';
    serialized += serializedEvent;

    return serialized;
  }
}
