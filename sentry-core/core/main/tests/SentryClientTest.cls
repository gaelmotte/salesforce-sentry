@isTest
public with sharing class SentryClientTest {
  private class SkipCapturedEventProcessor extends SentryEventProcessor {
    public override SentryEvent processAtCapture(SentryEvent event) {
      return null;
    }

    /**
     * Override this for any processor that should run costly operations.
     * This is called when the event is processed by transport.
     * You are encouraged to use this when SOQL is to be made
     */
    public override SentryEvent processAtTransport(SentryEvent event) {
      return event;
    }
  }

  private class SkipTransportedEventProcessor extends SentryEventProcessor {
    public override SentryEvent processAtCapture(SentryEvent event) {
      return event;
    }

    /**
     * Override this for any processor that should run costly operations.
     * This is called when the event is processed by transport.
     * You are encouraged to use this when SOQL is to be made
     */
    public override SentryEvent processAtTransport(SentryEvent event) {
      return null;
    }
  }

  private class SentryTransportNoCallMock implements System.StubProvider {
    public Object handleMethodCall(
      Object stubbedObject,
      String stubbedMethodName,
      Type returnType,
      List<Type> listOfParamTypes,
      List<String> listOfParamNames,
      List<Object> listOfArgs
    ) {
      Assert.fail('We should never invoke any method ');
      return null;
    }
  }

  private class SentryTransportCallWithMock implements System.StubProvider {
    String stubbedMethodName;
    List<Object> listOfArgs;
    Object returns;
    public SentryTransportCallWithMock(
      String stubbedMethodName,
      List<Object> listOfArgs,
      Object returns
    ) {
      this.stubbedMethodName = stubbedMethodName;
      this.listOfArgs = listOfArgs;
      this.returns = returns;
    }
    public Object handleMethodCall(
      Object stubbedObject,
      String stubbedMethodName,
      Type returnType,
      List<Type> listOfParamTypes,
      List<String> listOfParamNames,
      List<Object> listOfArgs
    ) {
      Assert.areEqual(this.listOfArgs, listOfArgs);
      Assert.areEqual(this.stubbedMethodName, stubbedMethodName);
      return returns;
    }
  }

  @IsTest
  public static void capturesEventsButDoesNotPublishIfScopeSkipsThem() {
    SentryScope scope = new SentryScope();
    scope.addProcessor(new SkipCapturedEventProcessor());

    SentryClient client = new SentryClient(
      (SentryTransport) Test.createStub(
        SentryTransport.class,
        new SentryTransportNoCallMock()
      )
    );

    Test.startTest();
    client.captureEvent(new SentryEvent(new SentryException()), scope);
    Test.stopTest();

    Assert.areEqual(
      0,
      [SELECT COUNT() FROM AsyncApexJob],
      'no job should be started'
    );
  }

  @IsTest
  public static void capturesEventsAndPublishesPlatformEvent() {
    Sentry_Config__mdt mdt = new Sentry_Config__mdt();
    mdt.Enabled__c = true;
    mdt.ApexClass__c = SentryConfig.Recommended.class.getName();
    mdt.DSN__c = 'https://public@sentry.example.com/1';
    SentryConfigFactory.getInstance()
      .mdtProvider = new SentryConfigFactory.SentryConfigMdtProvider(
      new List<Sentry_Config__mdt>{ mdt }
    );

    SentryScope scope = SentryHub.getCurrentHub().getCurrentScope();
    SentryClient client = new SentryClient(
      (SentryTransport) Test.createStub(
        SentryTransport.class,
        new SentryTransportNoCallMock()
      )
    );

    Test.startTest();
    client.captureEvent(new SentryEvent(new SentryException()), scope);
    Test.stopTest();

    Assert.areEqual(
      1,
      [SELECT COUNT() FROM AsyncApexJob],
      'one job should be started'
    );
  }

  @IsTest
  public static void transportsEventsButDoesNotSendIfScopeSkipsThem() {
    SentryScope scope = new SentryScope();
    scope.addProcessor(new SkipTransportedEventProcessor());
    SentryClient client = new SentryClient(
      (SentryTransport) Test.createStub(
        SentryTransport.class,
        new SentryTransportNoCallMock()
      )
    );

    Test.startTest();
    client.transportEvents(
      new List<SentryEvent>{ new SentryEvent(new SentryException()) },
      scope
    );
    Test.stopTest();

    Assert.areEqual(
      1,
      [SELECT COUNT() FROM AsyncApexJob],
      'no future job should be started'
    );
  }

  @IsTest
  public static void transportsEvents() {
    List<SentryEvent> events = new List<SentryEvent>{
      new SentryEvent(new SentryException())
    };

    Sentry_Config__mdt mdt = new Sentry_Config__mdt();
    mdt.Enabled__c = true;
    mdt.ApexClass__c = SentryConfig.class.getName();
    mdt.DSN__c = 'https://public@sentry.example.com/1';
    SentryConfigFactory.getInstance()
      .mdtProvider = new SentryConfigFactory.SentryConfigMdtProvider(
      new List<Sentry_Config__mdt>{ mdt }
    );

    SentryScope scope = SentryHub.getCurrentHub().getCurrentScope();
    SentryClient client = new SentryClient(
      (SentryTransport) Test.createStub(
        SentryTransport.class,
        new SentryTransportCallWithMock(
          'send',
          new List<Object>{ events },
          null
        )
      )
    );
    Test.startTest();
    client.transportEvents(events, scope);
    Test.stopTest();

    Assert.areEqual(
      1,
      [SELECT COUNT() FROM AsyncApexJob],
      'no future job should be started'
    );
  }
}
