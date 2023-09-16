/**
 * https://develop.sentry.dev/sdk/unified-api/#client
 */
public with sharing class SentryClient {
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

    System.debug('publishing:' + JSON.serialize(pe));
    EventBus.publish(pe);
  }

  /**
   * this takes events from the event queues, applies costly transforms, then sends it to sentry
   */
  public void transportEvent(List<SentryEvent> events, SentryScope scope) {
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

    System.debug('sending:' + JSON.serialize(preparedEvents));
    SentryTransport.send(preparedEvents);
  }

  /* These do not make sense here
    Client::close(timeout): Flushes out the queue for up to timeout seconds. If the client can guarantee delivery of events only up to the current point in time this is preferred. This might block for timeout seconds. The client should be disabled or disposed after close is called
    Client::flush(timeout): Same as close difference is that the client is NOT disposed after calling flush
    */
}
