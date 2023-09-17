public class SentryConfigFactory {
  private static ISentryConfig config;
  public static ISentryConfig getConfig() {
    if (config == null) {
      config = (ISentryConfig) getConfigType().newInstance();
    }
    return config;
  }

  private static System.Type getConfigType() {
    List<ApexTypeImplementor> implementors = [
      SELECT ClassName, ClassNamespacePrefix
      FROM ApexTypeImplementor
      WHERE
        InterfaceName = :ISentryConfig.class.getName()
        AND IsConcrete = TRUE
        AND ClassName != :SentryConfigNoop.class.getName()
    ];
    if (implementors.size() == 0) {
      return SentryConfigNoop.class;
    }
    if (implementors.size() > 1) {
      System.debug(
        'You should have only 1 class that implements ISentryConfig'
      );
      return SentryConfigNoop.class;
    }

    return System.Type.forName(
      implementors.get(0).ClassNamespacePrefix,
      implementors.get(0).ClassName
    );
  }
}
