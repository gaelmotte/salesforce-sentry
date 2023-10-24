public class SentryConfigFactory {
  private static SentryConfigFactory instance;
  private SentryConfig config;

  @testVisible
  private static SentryConfigFactory getInstance() {
    if (instance == null) {
      instance = new SentryConfigFactory();
    }
    return instance;
  }

  private SentryConfigFactory() {
    this.mdtProvider = new SentryConfigMdtProvider();
  }

  @testVisible
  private SentryConfigMdtProvider mdtProvider;

  Sentry_Config__mdt customMetadata {
    get {
      if (customMetadata == null) {
        try {
          customMetadata = mdtProvider.getActiveConfig();
        } catch (Exception e) {
          customMetadata = new Sentry_Config__mdt();
          customMetadata.Enabled__c = false;
          customMetadata.ApexClass__c = SentryConfig.class.getName();
          customMetadata.Sampling__c = 1;
          System.debug(e.getMessage());
        }
      }
      return customMetadata;
    }
    set;
  }

  public static SentryConfig getConfig() {
    SentryConfigFactory instance = getInstance();
    if (instance.config == null) {
      System.Type apexClass = System.Type.forName(
        instance.customMetadata.ApexClass__c
      );
      if (!SentryConfig.class.isAssignableFrom(apexClass)) {
        System.debug('The class must extend SentryConfig');
        instance.config = new SentryConfig();
      } else {
        instance.config = (SentryConfig) apexClass.newInstance();
      }
      instance.config.dsn = new SentryDSN(instance.customMetadata.DSN__c);
      instance.config.enabled = instance.customMetadata.Enabled__c;
      instance.config.sampling = instance.customMetadata.Sampling__c;
    }
    return instance.config;
  }

  private class NoActiveConfigException extends Exception {
  }
  private class TooManyActiveConfigException extends Exception {
  }

  public class SentryConfigMdtProvider {
    List<Sentry_Config__mdt> configs;

    public SentryConfigMdtProvider() {
      this(
        [
          SELECT ApexClass__c, DSN__c, Enabled__c
          FROM Sentry_Config__mdt
          WHERE Enabled__c = TRUE
        ]
      );
    }

    @testVisible
    private SentryConfigMdtProvider(List<Sentry_Config__mdt> configs) {
      this.configs = configs;
    }

    public Sentry_Config__mdt getActiveConfig() {
      if (configs.size() == 1) {
        return configs[0];
      }
      if (configs.size() == 0) {
        throw new NoActiveConfigException('No active Sentry config');
      }
      throw new TooManyActiveConfigException('Too many Sentry active config');
    }
  }
}
