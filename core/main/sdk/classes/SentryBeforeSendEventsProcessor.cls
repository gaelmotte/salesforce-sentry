public abstract class SentryBeforeSendEventsProcessor {
  public SentryBeforeSendEventsProcessor() {
  }
  public abstract List<SentryEvent> process(List<SentryEvent> events);
}
