/**
 * https://develop.sentry.dev/sdk/unified-api/#hub
 * Will not support multiple hub, at least for now
 * This could be usefull should we add Sentry logging on Sentry SDK issues in a managed package
 */
public with sharing class SentryHub {
  private static SentryHub mainHub;
  private List<SentryScope> scopes;
  private SentryClient client;
  private SentryConfig config = SentryConfigFactory.getConfig(); // consider passing a hub name to allow for different config per hubs
  private SentryTransport transport;

  private SentryHub() {
    scopes = new List<SentryScope>{ new SentryScope() };
    transport = new SentryTransport(config);
    client = new SentryClient(transport);
    configureDefaultScope();
  }

  private void configureDefaultScope() {
    SentryScope scope = scopes.get(0);
    for (ISentryIntegration integration : config.integrations) {
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

  /**
   * We currently support a unique hub
   * It could make sense to check if caller is Sentry SDK itself, give it a separate hub and config to bring exception in sendtry SDK to our own sentry project
   */
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
    client.transportEvents(events, scopes.get(scopes.size() - 1));
  }

  // public void addBreadcrumb(SentryBreadcrumb crumb) {
  // }

  // public String getLastEventId() {
  //   // TODO implement this
  //   return 'todo';
  // }

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
