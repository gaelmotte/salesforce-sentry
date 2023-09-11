/**
 * https://develop.sentry.dev/sdk/unified-api/#client
 */
public with sharing class SentryClient {
  public void captureEvent(SentryEvent event, SentryScope scope) {
    // TODO Prepare it for transport
    SentryEvent preparedEvent = scope.applyToEvent(event);
    if (preparedEvent == null) {
      // the event was filtered by a processor;
      return;
    }

    // publish a platform event with the event processed.
    Sentry_Event__e pe = event.toPlatformEvent();

    System.debug('publishing:' + JSON.serialize(pe));
    EventBus.publish(pe);
  }

  /* These do not make sense here
    Client::close(timeout): Flushes out the queue for up to timeout seconds. If the client can guarantee delivery of events only up to the current point in time this is preferred. This might block for timeout seconds. The client should be disabled or disposed after close is called
    Client::flush(timeout): Same as close difference is that the client is NOT disposed after calling flush
    */
}
