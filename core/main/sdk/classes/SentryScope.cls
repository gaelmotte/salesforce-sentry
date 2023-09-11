/**
 * https://develop.sentry.dev/sdk/unified-api/#scope
 */
public virtual class SentryScope {
  protected SentryUser user;
  protected Map<String, Object> extras = new Map<String, Object>();
  protected Map<String, String> tags = new Map<String, String>();
  protected Map<String, SentryContext> contexts = new Map<String, SentryContext>();
  protected List<SentryEventProcessor> processors = new List<SentryEventProcessor>();
  protected List<SentryBreadcrumb> breadcrumbs = new List<SentryBreadcrumb>();

  private SentryScope() {
  }

  public static SentryScope getDefaultScope() {
    return new SentryScope();
  }

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
    this.user = parentScope.user.clone();
    this.tags.putAll(parentScope.tags);
    this.extras.putAll(parentScope.extras);
    for (String key : parentScope.contexts.keySet()) {
      this.contexts.put(key, parentScope.contexts.get(key).clone());
    }
    this.processors.addAll(parentScope.processors);
    this.breadcrumbs.addAll(parentScope.breadcrumbs);
  }

  public void setUser(SentryUser user) {
    this.user = user;
  }

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

  public SentryEvent applyToEvent(SentryEvent event) {
    // TODO, impelment the magic here
    return event;
  }

  /*
   * thse do not make sense
   * scope.set_level(level): Sets the level of all events sent within this scope.
   * scope.set_transaction(transaction_name): Sets the name of the current transaction.
   * scope.set_fingerprint(fingerprint[]): Sets the fingerprint to group specific events together
   */
}
