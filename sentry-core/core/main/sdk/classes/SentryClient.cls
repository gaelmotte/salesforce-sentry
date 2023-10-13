/**
 * https://develop.sentry.dev/sdk/unified-api/#client
 */
public with sharing class SentryClient {
  SentryTransport transport;

  public SentryClient(SentryTransport transport) {
    this.transport = transport;
  }

  /**
   * This takes captured events, applies runtime transforms, and publishes to the event queue for later processing
   */
  public void captureEvent(SentryEvent event, SentryScope scope) {
    SentryEvent preparedEvent = scope.applyToEvent(event, true);
    if (preparedEvent == null) {
      // the event was filtered by a processor;
      return;
    }

    // publish a platform event with the event processed.
    Sentry_Event__e pe = event.toPlatformEvent();

    EventBus.publish(pe);
  }

  /**
   * this takes events from the event queues, applies costly transforms, then sends it to sentry
   */
  public void transportEvents(List<SentryEvent> events, SentryScope scope) {
    SentryTestSafeQueueable.enqueueJob(
      new QueueableTransportEvent(events, scope, transport)
    );
  }

  private class QueueableTransportEvent implements Queueable, Database.AllowsCallouts {
    List<SentryEvent> events;
    SentryScope scope;
    SentryTransport transport;
    public QueueableTransportEvent(
      List<SentryEvent> events,
      SentryScope scope,
      SentryTransport transport
    ) {
      this.events = events;
      this.scope = scope;
      this.transport = transport;
    }
    public void execute(QueueableContext context) {
      List<SentryEvent> preparedEvents = new List<SentryEvent>();

      for (SentryEvent event : events) {
        SentryEvent preparedEvent = scope.applyToEvent(event, false);
        if (preparedEvent == null) {
          // the event was filtered by a processor;
          continue;
        }
        preparedEvents.add(preparedEvent);
      }

      if (preparedEvents.size() == 0) {
        return;
      }

      transport.send(preparedEvents);
    }
  }

  /* These do not make sense here
    Client::close(timeout): Flushes out the queue for up to timeout seconds. If the client can guarantee delivery of events only up to the current point in time this is preferred. This might block for timeout seconds. The client should be disabled or disposed after close is called
    Client::flush(timeout): Same as close difference is that the client is NOT disposed after calling flush
    */
}
