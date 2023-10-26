public with sharing class SentryTransport {
  // see https://develop.sentry.dev/sdk/rate-limiting/#definitions
  private static final List<String> SUPPORTED_RATE_LIMITS = new List<String>{
    'all', // we are not allowed to send anything to sentry
    'default', // messages of default type
    'error' // errors
  };

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
        if (!shouldSampleEvent()) {
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
          continue;
        }
        if (isRateLimited(event)) {
          event.errors.add(
            new SentryEventProcessingError(
              'sentry',
              'rateLimiting',
              'Event not sent to sentry due to rate limiting'
            )
          );
          payloads.add(
            new Sentry_Payload__c(
              Payload__c = event.serialize(),
              Error__c = JSON.serialize(event.errors)
            )
          );
          continue;
        }
        payloads.add(doSend(event));
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
            rememberRateLimit(response);
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

    private void rememberRateLimit(HttpResponse response) {
      String rateLimitsHeaderValue = response.getHeader('X-Sentry-Rate-Limits');
      if (rateLimitsHeaderValue == null) {
        return;
      }
      List<Sentry_Rate_Limits__c> rateLimits = new List<Sentry_Rate_Limits__c>();
      Pattern rateLimitPattern = Pattern.compile('(\\d+):([^:]*):.*');
      for (String rateLimit : rateLimitsHeaderValue.split(', ')) {
        Matcher matcher = rateLimitPattern.matcher(rateLimit);
        if (!matcher.find()) {
          continue;
        }
        if (matcher.group(2) == '') {
          rateLimits.add(
            getRateLimitRecord('all', Integer.valueOf(matcher.group(1)))
          );
        } else {
          for (String category : matcher.group(2).split(';')) {
            rateLimits.add(
              getRateLimitRecord(category, Integer.valueOf(matcher.group(1)))
            );
          }
        }
      }

      upsert rateLimits Name;
    }

    private Sentry_Rate_Limits__c getRateLimitRecord(
      String category,
      Integer delay
    ) {
      return new Sentry_Rate_Limits__c(
        Name = getRateLimitHash(category),
        Category__c = category,
        DSN__c = config.dsn.rawDsn,
        Until__c = Datetime.now().addSeconds(delay)
      );
    }

    private String getRateLimitHash(String category) {
      return EncodingUtil.convertToHex(
        Crypto.generateDigest('MD5', Blob.valueOf(config.dsn.rawDsn + category))
      );
    }

    private Boolean shouldSampleEvent() {
      if (Math.random() < config.sampling) {
        return true;
      }
      return false;
    }

    /**
     * Flags certain messages as not to be sent because sentry told us to wait
     * https://develop.sentry.dev/sdk/rate-limiting/
     */
    private Boolean isRateLimited(SentryEvent event) {
      Map<String, Sentry_Rate_Limits__c> rateLimits = Sentry_Rate_Limits__c.getAll();
      for (Sentry_Rate_Limits__c rateLimit : rateLimits.values()) {
        if (rateLimit.DSN__c != config.dsn.rawDsn) {
          continue;
        }
        if (!SUPPORTED_RATE_LIMITS.contains(rateLimit.Category__c)) {
          continue; // something went wrong here. we saved a rate limit we cannot handle
        }
        // Once we support other message types, we would need to suclass SentryEvent and pick the right limit.
        // for the moment, all 3 supported apply to the messages we send
        if (Datetime.now() < rateLimit.Until__c) {
          return true;
        }
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
