@isTest
public with sharing class SentryConfigFactoryTest {
  @isTest
  public static void generatesADefaultDisabledConfigIfNoCMDT() {
    Test.startTest();
    SentryConfig config = SentryConfigFactory.getConfig();
    Test.stopTest();

    Assert.isInstanceOfType(
      config,
      SentryConfig.class,
      'should be of type SentryConfig, the virtual class'
    );
    Assert.isFalse(config.enabled, 'should not be enabled');
  }

  @isTest
  public static void generatesADefaultDisabledConfigIfTooManyCMDT() {
    Sentry_Config__mdt mdt = new Sentry_Config__mdt();
    mdt.Enabled__c = true;
    mdt.DSN__c = 'https://public@sentry.example.com/1';
    mdt.ApexClass__c = String.class.getName();
    SentryConfigFactory.getInstance()
      .mdtProvider = new SentryConfigFactory.SentryConfigMdtProvider(
      new List<Sentry_Config__mdt>{ mdt, mdt }
    );

    Test.startTest();
    SentryConfig config = SentryConfigFactory.getConfig();
    Test.stopTest();

    Assert.isInstanceOfType(
      config,
      SentryConfig.class,
      'should be of type SentryConfig, the virtual class'
    );
    Assert.isFalse(config.enabled, 'should not be enabled');
  }

  @isTest
  public static void generatesADefaultConfigIfApexClassOfWrongType() {
    Sentry_Config__mdt mdt = new Sentry_Config__mdt();
    mdt.Enabled__c = true;
    mdt.DSN__c = 'https://public@sentry.example.com/1';
    mdt.ApexClass__c = String.class.getName();
    SentryConfigFactory.getInstance()
      .mdtProvider = new SentryConfigFactory.SentryConfigMdtProvider(
      new List<Sentry_Config__mdt>{ mdt }
    );

    Test.startTest();
    SentryConfig config = SentryConfigFactory.getConfig();
    Test.stopTest();

    Assert.isInstanceOfType(
      config,
      SentryConfig.class,
      'should be of type SentryConfig, the virtual class'
    );
    Assert.areEqual(
      mdt.Enabled__c,
      config.enabled,
      'should copy over the enabled flag'
    );
  }

  public class CustomSentryConfig extends SentryConfig {
  }

  @isTest
  public static void generatesAConfigFromCMDT() {
    Test.startTest();
    SentryConfig config = SentryConfigFactory.getConfig();
    Test.stopTest();

    Assert.isInstanceOfType(
      config,
      SentryConfig.class,
      'should be of type SentryConfig, the virtual class'
    );
    Assert.isFalse(
      config.enabled,
      'The packaged CMDT record is enabled but does not provide a DSN, so config is not enabled'
    );
  }
}
