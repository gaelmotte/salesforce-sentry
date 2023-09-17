/**
 * https://develop.sentry.dev/sdk/unified-api/#scope
 * User is excluded from scope and reworked as an SentryUserEventProcessor
 */
public virtual class SentryScope {
  protected Map<String, Object> extras = new Map<String, Object>();
  protected Map<String, String> tags = new Map<String, String>();
  protected Map<String, SentryContext> contexts = new Map<String, SentryContext>();
  protected List<SentryEventProcessor> processors = new List<SentryEventProcessor>();
  protected List<SentryBreadcrumb> breadcrumbs = new List<SentryBreadcrumb>();

  /*
   * Methods for scope copy
   */

  public static SentryScope fromScope(
    System.type scopeType,
    SentryScope parentScope
  ) {
    SentryScope scope = (SentryScope) scopeType.newInstance();
    scope.fromScope(parentScope);
    return scope;
  }

  private virtual void fromScope(SentryScope parentScope) {
    // copy over everything
    this.tags.putAll(parentScope.tags);
    this.extras.putAll(parentScope.extras);
    for (String key : parentScope.contexts.keySet()) {
      this.contexts.put(key, parentScope.contexts.get(key).clone());
    }
    this.processors.addAll(parentScope.processors);
    this.breadcrumbs.addAll(parentScope.breadcrumbs);
  }

  /*
   * Methods that can be used by orther scopes
   */

  public void setTag(String key, String value) {
    tags.put(key, value);
  }

  public void setTags(Map<String, String> tags) {
    this.tags.putAll(tags);
  }
  public void setExtra(String key, Object value) {
    extras.put(key, value);
  }

  public void setExtras(Map<String, Object> extras) {
    this.extras.putAll(extras);
  }

  public void putContext(SentryContext context) {
    putContext(context.type, context);
  }
  public void putContext(String key, SentryContext context) {
    contexts.put(key, context);
  }

  public void addBreadcrumb(SentryBreadcrumb crumb) {
    this.breadcrumbs.add(crumb);
  }

  public void addProcessor(SentryEventProcessor processor) {
    processors.add(processor);
  }

  public SentryEvent applyToEvent(SentryEvent event, Boolean atCapture) {
    for (String key : this.contexts.keySet()) {
      event.contexts.put(contexts.get(key).type, contexts.get(key).getData());
    }
    event.extra.putAll(this.extras);
    event.tags.putAll(this.tags);
    event.breadcrumbs.addAll(this.breadcrumbs);

    Integer i = 0;
    while (event != null && i < processors.size()) {
      event = atCapture
        ? processors.get(i).processAtCapture(event)
        : processors.get(i).processAtTransport(event);
      i++;
    }
    return event;
  }

  /*
   * thse do not make sense
   * scope.set_level(level): Sets the level of all events sent within this scope.
   * scope.set_transaction(transaction_name): Sets the name of the current transaction.
   * scope.set_fingerprint(fingerprint[]): Sets the fingerprint to group specific events together
   */
}
