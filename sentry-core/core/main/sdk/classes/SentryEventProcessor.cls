public abstract class SentryEventProcessor {
  public SentryEventProcessor() {
  }

  /**
   * Override this for any processor that should use runtime data.
   * This is called when the event is captured
   * Avoid costly operations here (no SOQL, no Callout, ...)
   */
  public virtual SentryEvent processAtCapture(SentryEvent event) {
    return event;
  }

  /**
   * Override this for any processor that should run costly operations.
   * This is called when the event is processed by transport.
   * You are encouraged to use this when SOQL is to be made
   */
  public virtual SentryEvent processAtTransport(SentryEvent event) {
    return event;
  }
}
