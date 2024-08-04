@isTest
public with sharing class SentryTest {
  @isTest
  public static void handlesExceptionAndEnqueuesTransportEventJob() {
    Sentry_Config__mdt mdt = new Sentry_Config__mdt();
    mdt.Enabled__c = true;
    mdt.ApexClass__c = SentryConfig.Recommended.class.getName();
    mdt.DSN__c = 'https://public@sentry.example.com/1';
    SentryConfigFactory.getInstance()
      .mdtProvider = new SentryConfigFactory.SentryConfigMdtProvider(
      new List<Sentry_Config__mdt>{ mdt }
    );

    Test.startTest();
    try {
      System.debug('How much makes 42 divived by 0 ? ' + (42 / 0));
    } catch (Exception e) {
      Sentry.captureException(e);
    }
    Test.stopTest();
    AsyncApexJob job = [SELECT id, ApexClass.Name FROM AsyncApexJob LIMIT 1];
    Assert.isNotNull(job, 'shoudl have enqued a QueueableTransportEvent');
    Assert.areEqual(SentryClient.class.getName(), job.ApexClass.Name);
  } 

  @isTest
  public static void handlesSyntheticFlowExceptionAndEnqueuesTransportEventJob() {
    Sentry_Config__mdt mdt = new Sentry_Config__mdt();
    mdt.Enabled__c = true;
    mdt.ApexClass__c = SentryConfig.Recommended.class.getName();
    mdt.DSN__c = 'https://public@sentry.example.com/1';
    SentryConfigFactory.getInstance()
      .mdtProvider = new SentryConfigFactory.SentryConfigMdtProvider(
      new List<Sentry_Config__mdt>{ mdt }
    );

    Test.startTest();

    Sentry.SentryFlowInputParameters input = new Sentry.SentryFlowInputParameters();
    input.interviewGUID = 'TEST';
    input.faultMessage = 'TEST';
    List<Sentry.SentryFlowInputParameters> inputParameters = new List<Sentry.SentryFlowInputParameters>{
      input
    };
    Sentry.captureFlowFault(inputParameters);

    Test.stopTest();
    AsyncApexJob job = [SELECT id, ApexClass.Name FROM AsyncApexJob LIMIT 1];
    Assert.isNotNull(job, 'shoudl have enqued a QueueableTransportEvent');
    Assert.areEqual(SentryClient.class.getName(), job.ApexClass.Name);
  }

  @isTest
  public static void throwsWhenInstanciated() {
    Boolean threw = false;
    try {
      new Sentry();
    } catch (Exception e) {
      System.Assert.isTrue(
        e.getMessage().contains('is not meant to be instanciated')
      );
      threw = true;
    } finally {
      System.Assert.isTrue(threw);
    }
  }
}
