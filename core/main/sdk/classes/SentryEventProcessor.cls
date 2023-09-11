public abstract class SentryEventProcessor {
  public SentryEventProcessor() {
  }

  public abstract SentryEvent process(SentryEvent event);
}
