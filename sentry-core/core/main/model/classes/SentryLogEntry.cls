/**
 * https://develop.sentry.dev/sdk/event-payloads/types/#logentry
 */
public with sharing class SentryLogEntry {
  public Message message;
  public SentryLogEntry(String message) {
    this.message = new Message(message);
  }

  public class Message {
    public String formatted;
    // other members are not supported (yet ?) by this sdk
    public Message(String formatted) {
      this.formatted = formatted;
    }
  }
}
