/**
 * https://develop.sentry.dev/sdk/unified-api/#hub
 * Will not support multiple hub, at least for now
 */
public with sharing class SentryHub {
  private static SentryHub mainHub;
  private List<SentryScope> scopes;
  private SentryClient client;

  private List<SentryExceptionMechanismFormatter> mechanismFormatters = new List<SentryExceptionMechanismFormatter>{
    new SentryDMLExceptionMechanismFormatter(),
    new SentryExceptionMechanismFormatter()
  };

  private SentryHub() {
    scopes = new List<SentryScope>{ SentryScope.getDefaultScope() };
    client = new SentryClient();
  }

  public static SentryHub getMainHub() {
    if (mainHub == null) {
      mainhub = new SentryHub();
    }
    return mainHub;
  }

  public static SentryHub getCurrentHub() {
    return getMainHub();
  }

  public void captureException(Exception ex) {
    client.captureEvent(new SentryEvent(ex), scopes.get(scopes.size() - 1));
  }

  public void captureMessage(String message) {
    client.captureEvent(
      new SentryEvent(message),
      scopes.get(scopes.size() - 1)
    );
  }

  public void addBreadcrumb(SentryBreadcrumb crumb) {
  }

  public String getLastEventId() {
    return 'todo';
  }

  public void pushScope(
    System.Type scopeType,
    SentryConfigureScopeCallback callback
  ) {
    SentryScope scope = SentryScope.fromScope(scopeType, getCurrentScope());
    callback.configure(scope);
    scopes.add(scope);
  }

  public void popScope() {
    scopes.remove(scopes.size() - 1);
  }

  public SentryClient getClient() {
    return client;
  }

  private SentryScope getCurrentScope() {
    return scopes.get(scopes.size() - 1);
  }

  // binding another client won't be supported for now
}
