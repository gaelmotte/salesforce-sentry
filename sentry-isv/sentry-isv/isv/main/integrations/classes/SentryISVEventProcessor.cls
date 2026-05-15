public class SentryISVEventProcessor extends SentryEventProcessor {
  private final String release;
  private static Boolean cachedIsSandbox;

  public SentryISVEventProcessor() {
    this(null);
  }

  public SentryISVEventProcessor(String release) {
    this.release = release != null
      ? release
      : versionString(System.requestVersion());
  }

  private static String versionString(System.Version v) {
    if (v == null)
      return null;
    return v.major() + '.' + v.minor() + '.x';
  }

  public override SentryEvent processAtCapture(SentryEvent event) {
    if (release != null) {
      event.release = release;
    }
    event.tags.put('subscriber_org', UserInfo.getOrganizationName());
    return event;
  }

  public override SentryEvent processAtTransport(SentryEvent event) {
    if (cachedIsSandbox == null) {
      cachedIsSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    event.environment = cachedIsSandbox ? 'sandbox' : 'production';
    return event;
  }
}
