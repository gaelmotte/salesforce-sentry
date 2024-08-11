public with sharing class SentryLWCErrorEventProcessor extends SentryEventProcessor {
  public SentryLWCErrorEventProcessor() {
  }

  public override SentryEvent processAtCapture(SentryEvent event) {
    // Ignore if no exception (avoid error)
    if (event.getOriginLWCError() == null) {
      return event;
    }

    System.debug('Adding details to the LWC Error event at capture');
    System.debug(JSON.serialize(event.getOriginLWCError()));

    //TODO
    // Adapt the exception
    // add breadcrumbs from logs
    // build the stack

    return event;
  }
}
