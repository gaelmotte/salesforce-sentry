public class SentryConfigFactory {
  private static SentryConfigInterface config;
  public static SentryConfigInterface getConfig() {
    if (config == null) {
      config = (SentryConfigInterface) getConfigType().newInstance();
    }
    return config;
  }

  private static System.Type getConfigType() {
    System.Type configType = SentryConfigNoop.class;
    Datetime lastModified = Datetime.newInstance(2000, 1, 1); // fake it for the SentryConfigNoop;
    for (ApexTypeImplementor implementor : [
      SELECT ClassName, ClassNamespacePrefix, ApexClass.LastModifiedDate
      FROM ApexTypeImplementor
      WHERE
        InterfaceName = :SentryConfigInterface.class.getName()
        AND IsConcrete = TRUE
        AND ClassName != :SentryConfigNoop.class.getName()
    ]) {
      if (lastModified < implementor.ApexClass.LastModifiedDate) {
        configType = System.Type.forName(
          implementor.ClassNamespacePrefix,
          implementor.ClassName
        );
        lastModified = implementor.ApexClass.LastModifiedDate;
      }
    }
    return configType;
  }
}
