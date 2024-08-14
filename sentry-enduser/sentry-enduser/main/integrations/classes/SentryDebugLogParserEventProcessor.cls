public with sharing class SentryDebugLogParserEventProcessor extends SentryEventProcessor {
  private static final String REQUEST_ID_TAG = 'RequestId';
  private static final String QUIDITTY_TAG = 'Quiddity';

  private SentryDebugLogParser logParser;
  public SentryDebugLogParserEventProcessor() {
    this.logParser = new SentryDebugLogParser();
  }

  public override SentryEvent processAtCapture(SentryEvent event) {
    // Request id must me present since we use it to retrieve the debug logs
    event.tags.put(REQUEST_ID_TAG, Request.getCurrent().getRequestId());
    event.tags.put(QUIDITTY_TAG, Request.getCurrent().getQuiddity().name());

    return event;
  }

  public override SentryEvent processAtTransport(SentryEvent event) {
    String runtimeName = (String) event.getContextValue(
      SentryRuntimeContext.TYPE,
      'name'
    );

    if (
      runtimeName != SentryRuntimeContext.APEX &&
      runtimeName != SentryRuntimeContext.FLOW
    ) {
      return event;
    }

    List<String> debugLogBodies = getDebugLogBody(event);
    if (debugLogBodies.size() == 0) {
      return event;
    }
    for (String debugLogBody : debugLogBodies) {
      event.breadcrumbs.addAll(logParser.parseLogBody(debugLogBody));
    }
    return event;
  }

  private List<String> getDebugLogBody(SentryEvent event) {
    String requestId = event.tags.get(REQUEST_ID_TAG);

    List<String> bodies = new List<String>();
    // there may be several logfiles for the same request.
    for (ApexLog log : [
      SELECT Id
      FROM ApexLog
      WHERE RequestIdentifier = :requestId
    ]) {
      // actually does a callout, but does not require the complex setup
      // untestable though
      PageReference pageRef = new PageReference(
        '/servlet/servlet.FileDownload?file=' + log.Id
      );

      bodies.add(pageRef.getContent().toString());
    }

    return bodies;
  }
}
