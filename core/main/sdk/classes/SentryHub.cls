/**
 * https://develop.sentry.dev/sdk/unified-api/#hub
 * Will not support multiple hub, at least for now
 */
public with sharing class SentryHub {
  private static SentryHub mainHub;
  private List<SentryScope> scopes;
  private SentryClient client;
  private ISentryConfig config = SentryConfigFactory.getConfig();

  private SentryHub() {
    scopes = new List<SentryScope>{ new SentryScope() };
    client = new SentryClient();
    configureDefaultScope();
  }

  private void configureDefaultScope() {
    SentryScope scope = scopes.get(0);
    for (ISentryIntegration integration : config.getIntegrations()) {
      integration.applyToScope(scope);
    }
    // TODO add things we always want to add to scope and does not require config
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

  public void transportEvents(List<SentryEvent> events) {
    client.transportEvent(events, scopes.get(scopes.size() - 1));
  }

  public void addBreadcrumb(SentryBreadcrumb crumb) {
  }

  public String getLastEventId() {
    // TODO implement this
    return 'todo';
  }

  public void pushScope(
    System.Type scopeType,
    ISentryConfigureScopeCallback callback
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
