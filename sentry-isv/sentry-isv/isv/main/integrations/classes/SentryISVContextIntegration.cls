public class SentryISVContextIntegration implements ISentryIntegration {
  private final String release;

  public SentryISVContextIntegration() {
    this(versionString(System.requestVersion()));
  }

  public SentryISVContextIntegration(String release) {
    this.release = release;
  }

  private static String versionString(System.Version v) {
    if (v == null)
      return null;
    return v.major() + '.' + v.minor() + '.x';
  }

  public void applyToScope(SentryScope scope) {
    scope.addProcessor(new SentryISVEventProcessor(release));
  }
}
