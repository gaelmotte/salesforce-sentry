@isTest
public with sharing class SentryTransportTest {
  public class NoopConfig extends SentryConfig {
  }

  @isTest
  public static void savesPayloadsButDoesNotSendThemIfNoopConfig() {
    Sentry_Config__mdt mdt = new Sentry_Config__mdt();
    mdt.Enabled__c = false;
    mdt.ApexClass__c = NoopConfig.class.getName();
    mdt.Sampling__c = 1;
    SentryConfigFactory.getInstance()
      .mdtProvider = new SentryConfigFactory.SentryConfigMdtProvider(
      new List<Sentry_Config__mdt>{ mdt }
    );

    SentryTransport transport = new SentryTransport(
      SentryConfigFactory.getConfig()
    );

    Test.startTest();
    transport.send(new List<SentryEvent>{ new SentryEvent() });
    Test.stopTest();

    Assert.areEqual(
      1,
      [SELECT COUNT() FROM Sentry_Payload__c],
      'should have 1 payload'
    );
    Sentry_Payload__c payload = [
      SELECT Error__c
      FROM Sentry_Payload__c
      LIMIT 1
    ];
    Assert.isTrue(payload.Error__c.contains('sentry-not-enabled'));
  }

  private class SentryStoreMock implements HttpCalloutMock {
    private SentryEvent event;
    public SentryStoreMock(SentryEvent event) {
      this.event = event;
    }
    public HTTPResponse respond(HTTPRequest req) {
      Assert.areEqual(
        'https://sentry.example.com/api/1/store/',
        req.getEndpoint(),
        'should match endpoint from DSN'
      );
      Assert.areEqual('POST', req.getMethod(), 'should post an event');
      Assert.isTrue(req.getBody().contains(event.eventId));

      HttpResponse res = new HttpResponse();
      res.setStatusCode(200);
      return res;
    }
  }

  @isTest
  public static void savesPayloadsandSendsThemToSentry() {
    Sentry_Config__mdt mdt = new Sentry_Config__mdt();
    mdt.Enabled__c = true;
    mdt.ApexClass__c = SentryConfig.class.getName();
    mdt.Sampling__c = 1;
    // sample dsn from their documentation https://docs.sentry.io/product/sentry-basics/concepts/dsn-explainer/
    mdt.DSN__c = 'https://public@sentry.example.com/1';
    SentryConfigFactory.getInstance()
      .mdtProvider = new SentryConfigFactory.SentryConfigMdtProvider(
      new List<Sentry_Config__mdt>{ mdt }
    );

    SentryTransport transport = new SentryTransport(
      SentryConfigFactory.getConfig()
    );

    SentryEvent event = new SentryEvent();

    Test.setMock(HttpCalloutMock.class, new SentryStoreMock(event));
    Test.startTest();
    transport.send(new List<SentryEvent>{ event });
    Test.stopTest();

    List<Sentry_Payload__c> payloads = [
      SELECT id, Error__c, Stored_By_Sentry__c
      FROM Sentry_Payload__c
    ];
    Assert.areEqual(1, payloads.size(), 'should only persist one payoad');
    Assert.isTrue(
      payloads[0].Stored_By_Sentry__c,
      'Sentry should have been posted an event'
    );
  }

  private class SentryStoreNotFoundMock implements HttpCalloutMock {
    private SentryEvent event;
    public SentryStoreNotFoundMock(SentryEvent event) {
      this.event = event;
    }
    public HTTPResponse respond(HTTPRequest req) {
      Assert.areEqual(
        'https://sentry.example.com/api/1/store/',
        req.getEndpoint(),
        'should match endpoint from DSN'
      );
      Assert.areEqual('POST', req.getMethod(), 'should post an event');
      Assert.isTrue(req.getBody().contains(event.eventId));

      HttpResponse res = new HttpResponse();
      res.setStatusCode(404);
      return res;
    }
  }

  @isTest
  public static void savesPayloadsandSendsThemToSentryAndKeepsError() {
    Sentry_Config__mdt mdt = new Sentry_Config__mdt();
    mdt.Enabled__c = true;
    mdt.ApexClass__c = SentryConfig.class.getName();
    mdt.Sampling__c = 1;
    // sample dsn from their documentation https://docs.sentry.io/product/sentry-basics/concepts/dsn-explainer/
    mdt.DSN__c = 'https://public@sentry.example.com/1';
    SentryConfigFactory.getInstance()
      .mdtProvider = new SentryConfigFactory.SentryConfigMdtProvider(
      new List<Sentry_Config__mdt>{ mdt }
    );

    SentryTransport transport = new SentryTransport(
      SentryConfigFactory.getConfig()
    );

    SentryEvent event = new SentryEvent();

    Test.setMock(HttpCalloutMock.class, new SentryStoreNotFoundMock(event));
    Test.startTest();
    transport.send(new List<SentryEvent>{ event });
    Test.stopTest();

    List<Sentry_Payload__c> payloads = [
      SELECT id, Error__c, Stored_By_Sentry__c, Payload__c
      FROM Sentry_Payload__c
    ];
    Assert.areEqual(1, payloads.size(), 'should only persist one payoad');
    Assert.isFalse(
      payloads[0].Stored_By_Sentry__c,
      'Sentry should have been posted an event'
    );
    Assert.isTrue(
      payloads[0].Error__c.contains('404'),
      'error should list 404'
    );
    Assert.isTrue(
      payloads[0].Payload__c.contains('404'),
      'payload.errors should list 404'
    );
  }

  private class FilterHalfBeforeSendCallback implements ISentryBeforeSendCallback {
    private Integer processedEventsNumber = 0;
    public SentryEvent process(SentryEvent event) {
      if (Math.mod(processedEventsNumber++, 2) == 0) {
        return event;
      }
      return null;
    }
  }

  private class FilterHalfBeforeBreadcrumbCallback implements ISentryBeforeBreadcrumbCallback {
    private Integer processedBreadcrumbsNumber = 0;
    public SentryBreadcrumb process(SentryBreadcrumb breadcrumb) {
      if (Math.mod(processedBreadcrumbsNumber++, 2) == 0) {
        return breadcrumb;
      }
      return null;
    }
  }

  public class FilterHalfSentryConfig extends SentryConfig {
    private ISentryBeforeBreadcrumbCallback beforeBreadcrumb = new FilterHalfBeforeBreadcrumbCallback();
    private ISentryBeforeSendCallback beforeSend = new FilterHalfBeforeSendCallback();
    public override ISentryBeforeBreadcrumbCallback getBeforeBreadcrumbCallback() {
      return beforeBreadcrumb;
    }

    public override ISentryBeforeSendCallback getBeforeSendCallback() {
      return beforeSend;
    }
  }

  @isTest
  public static void appliesHooks() {
    Sentry_Config__mdt mdt = new Sentry_Config__mdt();
    mdt.Enabled__c = true;
    mdt.ApexClass__c = FilterHalfSentryConfig.class.getName();
    mdt.Sampling__c = 1;
    // sample dsn from their documentation https://docs.sentry.io/product/sentry-basics/concepts/dsn-explainer/
    mdt.DSN__c = 'https://public@sentry.example.com/1';
    SentryConfigFactory.getInstance()
      .mdtProvider = new SentryConfigFactory.SentryConfigMdtProvider(
      new List<Sentry_Config__mdt>{ mdt }
    );

    SentryTransport transport = new SentryTransport(
      SentryConfigFactory.getConfig()
    );

    SentryEvent event = new SentryEvent();
    for (Integer i = 0; i < 10; i++) {
      SentryBreadcrumb breadcrumb = new SentryBreadcrumb();
      breadcrumb.category = 'sample' + i;
      breadcrumb.type = 'debug';
      breadcrumb.timestamp = Datetime.now();
      event.breadcrumbs.add(breadcrumb);
    }

    Test.setMock(HttpCalloutMock.class, new SentryStoreMock(event));
    Test.startTest();
    transport.send(new List<SentryEvent>{ event, event });
    Test.stopTest();

    List<Sentry_Payload__c> payloads = [
      SELECT id, Error__c, Stored_By_Sentry__c, Payload__c
      FROM Sentry_Payload__c
    ];
    Assert.areEqual(1, payloads.size(), 'should only persist one payload');
    Assert.isTrue(
      payloads[0].Stored_By_Sentry__c,
      'Sentry should have been posted an event'
    );
    SentryEvent deserializedEvent = SentryEvent.deserialize(
      payloads[0].Payload__c
    );
    Assert.areEqual(
      5,
      deserializedEvent.breadcrumbs.size(),
      'should have half as many breadcrumbs'
    );
  }

  @isTest
  public static void appliesSampling() {
    Sentry_Config__mdt mdt = new Sentry_Config__mdt();
    mdt.Enabled__c = true;
    mdt.ApexClass__c = SentryConfig.class.getName();
    mdt.Sampling__c = 0;
    // sample dsn from their documentation https://docs.sentry.io/product/sentry-basics/concepts/dsn-explainer/
    mdt.DSN__c = 'https://public@sentry.example.com/1';
    SentryConfigFactory.getInstance()
      .mdtProvider = new SentryConfigFactory.SentryConfigMdtProvider(
      new List<Sentry_Config__mdt>{ mdt }
    );

    SentryTransport transport = new SentryTransport(
      SentryConfigFactory.getConfig()
    );

    SentryEvent event = new SentryEvent();

    Test.setMock(HttpCalloutMock.class, new SentryStoreMock(event));
    Test.startTest();
    transport.send(new List<SentryEvent>{ event });
    Test.stopTest();

    List<Sentry_Payload__c> payloads = [
      SELECT id, Error__c, Stored_By_Sentry__c, Payload__c
      FROM Sentry_Payload__c
    ];
    Assert.areEqual(1, payloads.size(), 'should only persist one payload');
    Assert.isFalse(
      payloads[0].Stored_By_Sentry__c,
      'Event should not have been sampled'
    );
    Assert.isTrue(payloads[0].Error__c.contains('sampling'));
  }

  private class SentryStoreNoCallMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      Assert.fail('Must not send anything to Sentry');
      return null;
    }
  }

  @isTest
  public static void appliesRateLimiting() {
    Sentry_Config__mdt mdt = new Sentry_Config__mdt();
    mdt.Enabled__c = true;
    mdt.ApexClass__c = SentryConfig.class.getName();
    mdt.Sampling__c = 1;
    // sample dsn from their documentation https://docs.sentry.io/product/sentry-basics/concepts/dsn-explainer/
    mdt.DSN__c = 'https://public@sentry.example.com/1';
    SentryConfigFactory.getInstance()
      .mdtProvider = new SentryConfigFactory.SentryConfigMdtProvider(
      new List<Sentry_Config__mdt>{ mdt }
    );

    SentryTransport transport = new SentryTransport(
      SentryConfigFactory.getConfig()
    );

    SentryEvent event = new SentryEvent();

    insert new Sentry_Rate_Limits__c(
      Name = 'whatever',
      Category__c = 'all',
      DSN__c = mdt.DSN__c,
      Until__c = Datetime.now().addMinutes(10)
    );

    Test.setMock(HttpCalloutMock.class, new SentryStoreNoCallMock());
    Test.startTest();
    transport.send(new List<SentryEvent>{ event });
    Test.stopTest();

    List<Sentry_Payload__c> payloads = [
      SELECT id, Error__c, Stored_By_Sentry__c, Payload__c
      FROM Sentry_Payload__c
    ];
    Assert.areEqual(1, payloads.size(), 'should only persist one payload');
    Assert.isFalse(
      payloads[0].Stored_By_Sentry__c,
      'Event should not have been sampled'
    );
    Assert.isTrue(payloads[0].Error__c.contains('rateLimiting'));
  }

  @isTest
  public static void savesPayloadsandSendsThemToSentryIfNotRateLimited() {
    Sentry_Config__mdt mdt = new Sentry_Config__mdt();
    mdt.Enabled__c = true;
    mdt.ApexClass__c = SentryConfig.class.getName();
    mdt.Sampling__c = 1;
    // sample dsn from their documentation https://docs.sentry.io/product/sentry-basics/concepts/dsn-explainer/
    mdt.DSN__c = 'https://public@sentry.example.com/1';
    SentryConfigFactory.getInstance()
      .mdtProvider = new SentryConfigFactory.SentryConfigMdtProvider(
      new List<Sentry_Config__mdt>{ mdt }
    );

    SentryTransport transport = new SentryTransport(
      SentryConfigFactory.getConfig()
    );

    SentryEvent event = new SentryEvent();

    insert new Sentry_Rate_Limits__c(
      Name = 'whatever',
      Category__c = 'all',
      DSN__c = mdt.DSN__c,
      Until__c = Datetime.now().addMinutes(-10)
    );

    Test.setMock(HttpCalloutMock.class, new SentryStoreMock(event));
    Test.startTest();
    transport.send(new List<SentryEvent>{ event });
    Test.stopTest();

    List<Sentry_Payload__c> payloads = [
      SELECT id, Error__c, Stored_By_Sentry__c
      FROM Sentry_Payload__c
    ];
    Assert.areEqual(1, payloads.size(), 'should only persist one payload');
    Assert.isTrue(
      payloads[0].Stored_By_Sentry__c,
      'Sentry should have been posted an event'
    );
  }

  private class SentryStoreRateLimitMock implements HttpCalloutMock {
    private Integer responseCode;
    private List<SentryStoreRateLimitMockOption> options;
    public SentryStoreRateLimitMock(
      Integer responseCode,
      List<SentryStoreRateLimitMockOption> options
    ) {
      this.options = options;
      this.responseCode = responseCode;
    }

    private String getRateLimitsHeaderValue() {
      List<String> rateLimitStrings = new List<String>();
      for (SentryStoreRateLimitMockOption option : options) {
        rateLimitStrings.add(option.toString());
      }
      return String.join(rateLimitStrings, ', ');
    }
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setStatusCode(this.responseCode);
      res.setHeader('X-Sentry-Rate-Limits', getRateLimitsHeaderValue());
      return res;
    }
  }

  private class SentryStoreRateLimitMockOption {
    public String categories;
    public Integer retryAfter;
    public String scope = 'organization'; // we do not care about that
    public SentryStoreRateLimitMockOption(
      String categories,
      Integer retryAfter
    ) {
      this.categories = categories;
      this.retryAfter = retryAfter;
    }
    public override String toString() {
      return retryAfter + ':' + categories + ':' + scope;
    }
  }

  @isTest
  public static void remembersRateLimitIfPresentInResponse() {
    Sentry_Config__mdt mdt = new Sentry_Config__mdt();
    mdt.Enabled__c = true;
    mdt.ApexClass__c = SentryConfig.class.getName();
    mdt.Sampling__c = 1;
    // sample dsn from their documentation https://docs.sentry.io/product/sentry-basics/concepts/dsn-explainer/
    mdt.DSN__c = 'https://public@sentry.example.com/1';
    SentryConfigFactory.getInstance()
      .mdtProvider = new SentryConfigFactory.SentryConfigMdtProvider(
      new List<Sentry_Config__mdt>{ mdt }
    );

    SentryTransport transport = new SentryTransport(
      SentryConfigFactory.getConfig()
    );

    SentryEvent event = new SentryEvent();

    Test.setMock(
      HttpCalloutMock.class,
      new SentryStoreRateLimitMock(
        200,
        new List<SentryStoreRateLimitMockOption>{
          new SentryStoreRateLimitMockOption('', 60)
        }
      )
    );
    Test.startTest();
    transport.send(new List<SentryEvent>{ event });
    Test.stopTest();

    List<Sentry_Payload__c> payloads = [
      SELECT id, Error__c, Stored_By_Sentry__c
      FROM Sentry_Payload__c
    ];
    Assert.areEqual(1, payloads.size(), 'should only persist one payload');
    Assert.isTrue(
      payloads[0].Stored_By_Sentry__c,
      'Sentry should have been posted an event'
    );

    List<Sentry_Rate_Limits__c> rateLimits = [
      SELECT Name, Category__c, DSN__c, Until__c
      FROM Sentry_Rate_Limits__c
    ];
    Assert.areEqual(1, rateLimits.size(), 'must remember 1 rate limit');
    Assert.areEqual('all', rateLimits[0].Category__c, 'non category means all');
    Assert.areEqual(mdt.DSN__c, rateLimits[0].DSN__c, 'must match the DSN');
    Assert.isTrue(
      rateLimits[0].Until__c > Datetime.now(),
      'the rate limit is valid until a future date'
    );
  }

  @isTest
  public static void updatesRateLimitIfPresentInResponse() {
    Sentry_Config__mdt mdt = new Sentry_Config__mdt();
    mdt.Enabled__c = true;
    mdt.ApexClass__c = SentryConfig.class.getName();
    mdt.Sampling__c = 1;
    // sample dsn from their documentation https://docs.sentry.io/product/sentry-basics/concepts/dsn-explainer/
    mdt.DSN__c = 'https://public@sentry.example.com/1';
    SentryConfigFactory.getInstance()
      .mdtProvider = new SentryConfigFactory.SentryConfigMdtProvider(
      new List<Sentry_Config__mdt>{ mdt }
    );

    SentryConfig config = SentryConfigFactory.getConfig();
    SentryTransport transport = new SentryTransport(config);

    SentryEvent event = new SentryEvent();

    Sentry_Rate_Limits__c existingRateLimit = new Sentry_Rate_Limits__c(
      Name = EncodingUtil.convertToHex(
        Crypto.generateDigest('MD5', Blob.valueOf(config.dsn.rawDsn + 'all'))
      ),
      Category__c = 'all',
      DSN__c = config.dsn.rawDsn,
      Until__c = Datetime.now().addSeconds(-10)
    );

    insert existingRateLimit;

    Test.setMock(
      HttpCalloutMock.class,
      new SentryStoreRateLimitMock(
        200,
        new List<SentryStoreRateLimitMockOption>{
          new SentryStoreRateLimitMockOption('', 60)
        }
      )
    );
    Test.startTest();
    transport.send(new List<SentryEvent>{ event });
    Test.stopTest();

    List<Sentry_Payload__c> payloads = [
      SELECT id, Error__c, Stored_By_Sentry__c
      FROM Sentry_Payload__c
    ];
    Assert.areEqual(1, payloads.size(), 'should only persist one payload');
    Assert.isTrue(
      payloads[0].Stored_By_Sentry__c,
      'Sentry should have been posted an event'
    );

    List<Sentry_Rate_Limits__c> rateLimits = [
      SELECT Name, Category__c, DSN__c, Until__c
      FROM Sentry_Rate_Limits__c
    ];
    Assert.areEqual(1, rateLimits.size(), 'must remember 1 rate limit');
    Assert.areEqual('all', rateLimits[0].Category__c, 'non category means all');
    Assert.areEqual(mdt.DSN__c, rateLimits[0].DSN__c, 'must match the DSN');
    Assert.isTrue(
      rateLimits[0].Until__c > Datetime.now(),
      'the rate limit is valid until a future date'
    );
  }

  @isTest
  public static void rememversMultipleCategoriesRateLimitIfPresentInResponse() {
    Sentry_Config__mdt mdt = new Sentry_Config__mdt();
    mdt.Enabled__c = true;
    mdt.ApexClass__c = SentryConfig.class.getName();
    mdt.Sampling__c = 1;
    // sample dsn from their documentation https://docs.sentry.io/product/sentry-basics/concepts/dsn-explainer/
    mdt.DSN__c = 'https://public@sentry.example.com/1';
    SentryConfigFactory.getInstance()
      .mdtProvider = new SentryConfigFactory.SentryConfigMdtProvider(
      new List<Sentry_Config__mdt>{ mdt }
    );

    SentryConfig config = SentryConfigFactory.getConfig();
    SentryTransport transport = new SentryTransport(config);

    SentryEvent event = new SentryEvent();

    Sentry_Rate_Limits__c existingRateLimit = new Sentry_Rate_Limits__c(
      Name = EncodingUtil.convertToHex(
        Crypto.generateDigest(
          'MD5',
          Blob.valueOf(config.dsn.rawDsn + 'default')
        )
      ),
      Category__c = 'default',
      DSN__c = config.dsn.rawDsn,
      Until__c = Datetime.now().addSeconds(-10)
    );

    insert existingRateLimit;

    Test.setMock(
      HttpCalloutMock.class,
      new SentryStoreRateLimitMock(
        200,
        new List<SentryStoreRateLimitMockOption>{
          new SentryStoreRateLimitMockOption('default;error', 60)
        }
      )
    );
    Test.startTest();
    transport.send(new List<SentryEvent>{ event });
    Test.stopTest();

    List<Sentry_Payload__c> payloads = [
      SELECT id, Error__c, Stored_By_Sentry__c
      FROM Sentry_Payload__c
    ];
    Assert.areEqual(1, payloads.size(), 'should only persist one payload');
    Assert.isTrue(
      payloads[0].Stored_By_Sentry__c,
      'Sentry should have been posted an event'
    );

    List<Sentry_Rate_Limits__c> rateLimits = [
      SELECT Name, Category__c, DSN__c, Until__c
      FROM Sentry_Rate_Limits__c
    ];
    Assert.areEqual(2, rateLimits.size(), 'must remember 2 rate limit');
    Assert.areEqual(mdt.DSN__c, rateLimits[0].DSN__c, 'must match the DSN');
    Assert.areEqual(mdt.DSN__c, rateLimits[1].DSN__c, 'must match the DSN');
    Assert.isTrue(
      rateLimits[0].Until__c > Datetime.now(),
      'the rate limit is valid until a future date'
    );
    Assert.isTrue(
      rateLimits[1].Until__c > Datetime.now(),
      'the rate limit is valid until a future date'
    );
  }
}
