public with sharing class SentryTransport {
  private static Http http = new Http();
  private static SentryConfigInterface config = SentryConfigFactory.getConfig();

  public static void send(List<SentryEvent> events) {
    // save the payloads
    Set<Id> payloadIds = savePayloads(events);
    send(payloadIds);
  }

  private static Set<Id> savePayloads(List<SentryEvent> events) {
    List<Sentry_Payload__c> payloads = new List<Sentry_Payload__c>();
    for (SentryEvent event : events) {
      Sentry_Payload__c payload = new Sentry_Payload__c();
      payload.Name = event.eventId;
      payload.Payload__c = event.toJsonPayload();
      payloads.add(payload);
    }
    insert payloads;
    return (new Map<Id, Sentry_Payload__c>(payloads)).keySet();
  }

  @Future(Callout=true)
  private static void send(Set<id> payloadIds) {
    List<Sentry_Payload__c> payloads = [
      SELECT Id, name, Payload__c
      FROM Sentry_Payload__c
      WHERE id IN :payloadIds
    ];
    for (Sentry_Payload__c payload : payloads) {
      try {
        HttpResponse response = http.send(getStoreRequest(payload.Payload__c));
        if (response.getStatusCode() != 200) {
          throw new CalloutException(
            'Sentry rejected the event [' +
              response.getStatusCode() +
              ']: ' +
              response.getBody()
          );
        }
        payload.Stored_By_Sentry__c = true;
      } catch (Exception e) {
        payload.Error__c = e.getMessage();
      }
    }
    update payloads;
  }

  private static HttpRequest getStoreRequest(String payload) {
    if (config.getDSN() == null) {
      throw new SentryException('Sentry DSN is not Configured');
    }
    HttpRequest request = new HttpRequest();
    request.setEndpoint(config.getDSN().storeEndpoint.toExternalForm());
    request.setMethod('POST');
    request.setHeader('Content-Type', 'application/json');
    request.setHeader('User-Agent', SentryClientSDKInfo.getFullName());
    request.setHeader(
      'X-Sentry-Auth',
      'Sentry ' +
      String.join(
        new List<String>{
          'sentry_version=7', // Sentry api version
          'sentry_key=' + config.getDSN().publicKey,
          'sentry_client=' + SentryClientSDKInfo.getFullName()
        },
        ', '
      )
    );
    request.setBody(payload);

    return request;
  }
}
