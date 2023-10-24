public interface ISentryBeforeSendCallback {
  SentryEvent process(SentryEvent event);
}
