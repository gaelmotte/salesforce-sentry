public abstract class SentryContext {
  public String type { get; protected set; }

  /**
   * Sentry does not handle nested maps. You need to flatten your data.
   */
  public abstract Map<String, Object> getData();
}
