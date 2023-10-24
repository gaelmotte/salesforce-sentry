public with sharing class SentryTransport {
  private SentryConfig config;

  public SentryTransport(SentryConfig config) {
    this.config = config;
  }

  public void send(List<SentryEvent> events) {
    SentryTestSafeQueueable.enqueueJob(
      new QueueableSendEvents(applyHooks(events), config)
    );
  }

  private List<SentryEvent> applyHooks(List<SentryEvent> events) {
    List<SentryEvent> preparedEvents = new List<SentryEvent>();
    for (SentryEvent event : events) {
      SentryEvent preparedEvent = config.getBeforeSendCallback() != null
        ? config.getBeforeSendCallback().process(event)
        : event;
      if (preparedEvent == null) {
        continue;
      }
      List<SentryBreadcrumb> preparedBreadcrumbs = new List<SentryBreadcrumb>();
      for (SentryBreadcrumb breadcrumb : preparedEvent.breadcrumbs) {
        SentryBreadcrumb preparedBreadcrumb = config.getBeforeBreadcrumbCallback() !=
          null
          ? config.getBeforeBreadcrumbCallback().process(breadcrumb)
          : breadcrumb;

        if (preparedBreadcrumb == null) {
          continue;
        }
        preparedBreadcrumbs.add(preparedBreadcrumb);
      }
      preparedEvent.breadcrumbs = preparedBreadcrumbs;
      preparedEvents.add(preparedEvent);
    }
    return preparedEvents;
  }

  private class QueueableSendEvents implements Queueable, Database.AllowsCallouts {
    private List<SentryEvent> events;
    private SentryConfig config;

    public QueueableSendEvents(List<SentryEvent> events, SentryConfig config) {
      this.events = events;
      this.config = config;
    }

    public void execute(QueueableContext context) {
      List<Sentry_Payload__c> payloads = new List<Sentry_Payload__c>();
      for (SentryEvent event : events) {
        if (shouldSampleEvent()) {
          payloads.add(doSend(event));
        } else {
          event.errors.add(
            new SentryEventProcessingError(
              'sentry',
              'sampling',
              'Event not sent to sentry due to Sampling rate'
            )
          );
          payloads.add(
            new Sentry_Payload__c(
              Payload__c = event.serialize(),
              Error__c = JSON.serialize(event.errors)
            )
          );
        }
      }
      insert payloads;
    }

    private Sentry_Payload__c doSend(SentryEvent event) {
      Http http = new Http();
      Sentry_Payload__c payload = new Sentry_Payload__c();
      payload.Name = event.eventId;
      if (!config.ready) {
        event.errors.add(
          new SentryEventProcessingError('sentry', 'sentry-not-enabled', config)
        );
      } else {
        try {
          HttpRequest request = getStoreRequest(event);
          if (request != null) {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() != 200) {
              throw new CalloutException(
                'Sentry rejected the event [' +
                  response.getStatusCode() +
                  ']: ' +
                  response.getBody()
              );
            }
            payload.Stored_By_Sentry__c = true;
          }
        } catch (Exception e) {
          event.errors.add(
            new SentryEventProcessingError(
              'ingest',
              e.getTypeName(),
              e.getMessage()
            )
          );
        }
      }
      payload.Error__c = JSON.serialize(event.errors);
      payload.Payload__c = event.serialize();
      return payload;
    }

    private Boolean shouldSampleEvent() {
      if (Math.random() < config.sampling) {
        return true;
      }
      return false;
    }

    private HttpRequest getStoreRequest(SentryEvent event) {
      HttpRequest request = new HttpRequest();
      request.setEndpoint(config.dsn.baseUri.toExternalForm() + '/store/');
      request.setMethod('POST');
      request.setHeader('Content-Type', 'application/json');
      request.setHeader('User-Agent', SentryClientSDKInfo.getFullName());
      request.setHeader(
        'X-Sentry-Auth',
        'Sentry ' +
        String.join(
          new List<String>{
            'sentry_version=7', // Sentry api version
            'sentry_key=' + config.dsn.publicKey,
            'sentry_client=' + SentryClientSDKInfo.getFullName()
          },
          ', '
        )
      );
      request.setBody(event.serialize());

      return request;
    }
  }
}
