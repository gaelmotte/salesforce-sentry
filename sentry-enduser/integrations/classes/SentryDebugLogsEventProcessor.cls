public with sharing class SentryDebugLogsEventProcessor extends SentryEventProcessor {
  private static final String REQUEST_ID_TAG = 'RequestId';
  private static final String QUIDITTY_TAG = 'Quiddity';
  private static final Pattern LOGLINE_START_PATTERN = Pattern.compile(
    '^(\\d{2}):(\\d{2}):(\\d{2})\\.(\\d+) \\((\\d+)\\)\\|'
  );
  private static final Pattern LOGLINE_METHOD_STACK_PATTERN = Pattern.compile(
    '(METHOD_EXIT|METHOD_ENTRY)\\|\\[(\\d+)\\]\\|[^|]*\\|([^\\r\\n]*)?$'
  );
  private static final Pattern LOGLINE_DEBUG_PATTERN = Pattern.compile(
    'USER_DEBUG\\|\\[(\\d+)\\]\\|([^|]*)\\|([^\\r\\n]*)?$'
  );
  private static final Pattern LOGLINE_CALLOUT_RESPONSE_PATTERN = Pattern.compile(
    'CALLOUT_RESPONSE\\|\\[(\\d+)\\]\\|System.HttpResponse\\[Status=([^,]*), StatusCode=([^\\]]*)\\]$'
  );
  private static final Pattern LOGLINE_CALLOUT_REQUEST_PATTERN = Pattern.compile(
    'CALLOUT_REQUEST\\|\\[(\\d+)\\]\\|System.HttpRequest\\[Endpoint=([^,]*), Method=([^\\]]*)\\]$'
  );

  public SentryDebugLogsEventProcessor() {
  }

  public override SentryEvent processAtCapture(SentryEvent event) {
    event.tags.put(REQUEST_ID_TAG, Request.getCurrent().getRequestId());
    event.tags.put(QUIDITTY_TAG, Request.getCurrent().getQuiddity().name());

    return event;
  }

  public override SentryEvent processAtTransport(SentryEvent event) {
    List<String> debugLogBodies = getDebugLogBody(event);
    if (debugLogBodies.size() == 0) {
      // TODO set debugLog should the user retry the request
      // May be worth checking for debuglogs for the entity and the user.
      //Not retrieving a file can mean something else;

      return event;
    }
    for (String debugLogBody : debugLogBodies) {
      List<SentryBreadcrumb> logBreadcrumbs = parseLogBody(debugLogBody);
      event.breadcrumbs.addAll(logBreadcrumbs);
    }
    return event;
  }

  private List<String> getDebugLogBody(SentryEvent event) {
    String requestId = event.tags.get(REQUEST_ID_TAG);
    Http http = new Http();
    List<String> bodies = new List<String>();
    // there may be several logfiles for the same request.
    for (ApexLog log : [
      SELECT Id
      FROM ApexLog
      WHERE RequestIdentifier = :requestId
    ]) {
      HttpRequest request = new HttpRequest();
      request.setEndpoint(
        'callout:Sentry_SDK_Tooling_Api_Credential/services/data/v58.0/tooling/sobjects/ApexLog/' +
          log.id +
          '/Body'
      );
      request.setMethod('GET');

      HttpResponse response = http.send(request);
      if (response.getStatusCode() != 200) {
        System.debug(
          'Failed to retrieve debug log : [' +
            response.getStatusCode() +
            '] ' +
            response.getBody()
        );
        // TODO implement error fields on event to catch those cases
        continue;
      }
      bodies.add(response.getBody());
    }

    return bodies;
  }

  private List<SentryBreadcrumb> parseLogBody(String debugLogBody) {
    List<SentryBreadcrumb> breadcrumbs = new List<SentryBreadcrumb>();

    List<String> logLines = debugLogBody.split('\n');

    List<String> logStack = new List<String>();
    String multilineContent;
    Matcher matcher;
    HttpBreadcrumb httpBreadcrumb = null;
    LogBreadcrumb logBreadCrumb = null;
    for (String logLine : logLines) {
      matcher = LOGLINE_START_PATTERN.matcher(logLine);
      if (!matcher.find()) {
        if (logBreadCrumb == null) {
          continue;
        }
        logBreadCrumb.message = logBreadCrumb.message + '\n' + logLine;
        continue;
      } else if (logBreadCrumb != null) {
        breadcrumbs.add(logBreadCrumb);
        logBreadCrumb = null;
      }
      // parse Datetime
      Time timestampTime = Time.newInstance(
        Integer.valueOf(matcher.group(1)),
        Integer.valueOf(matcher.group(2)),
        Integer.valueOf(matcher.group(3)),
        Integer.valueOf(matcher.group(4))
      );
      Datetime timestamp = Datetime.newInstance(Date.today(), timestampTime);
      matcher = LOGLINE_METHOD_STACK_PATTERN.matcher(logLine);
      if (matcher.find()) {
        if (matcher.group(1) == 'METHOD_ENTRY') {
          logStack.add(matcher.group(3));
          continue;
        }
        if (matcher.group(1) == 'METHOD_EXIT') {
          logStack.remove(logStack.size() - 1);
          continue;
        }
      }
      matcher = LOGLINE_CALLOUT_REQUEST_PATTERN.matcher(logLine);
      if (matcher.find()) {
        httpBreadcrumb = new httpBreadcrumb(
          logStack.get(logStack.size() - 1),
          timestamp,
          matcher.group(1),
          matcher.group(2),
          matcher.group(3)
        );
        continue;
      }
      matcher = LOGLINE_CALLOUT_RESPONSE_PATTERN.matcher(logLine);
      if (matcher.find()) {
        if (httpBreadcrumb != null) {
          httpBreadcrumb.data.putAll(
            new Map<String, Object>{
              'status_code' => matcher.group(3),
              'reason' => matcher.group(2)
            }
          );
          breadcrumbs.add(httpBreadcrumb);
          httpBreadcrumb = null;
        }
        continue;
      }
      matcher = LOGLINE_DEBUG_PATTERN.matcher(logLine);
      if (matcher.find()) {
        logBreadCrumb = new LogBreadcrumb(
          logStack.get(logStack.size() - 1),
          timestamp,
          matcher.group(1),
          matcher.group(3),
          matcher.group(2)
        );
        continue;
      }
    }

    return breadcrumbs;
  }

  private class LogBreadcrumb extends SentryBreadcrumb {
    public LogBreadcrumb(
      String category,
      Datetime timestamp,
      String lineNumber,
      String message,
      String level
    ) {
      super(level);
      this.type = 'debug';
      this.category = category + '.lineno' + lineNumber;
      this.message = message;
      this.timestamp = timestamp;
    }
  }

  public class HttpBreadcrumb extends SentryBreadcrumb {
    public HttpBreadcrumb(
      String category,
      Datetime timestamp,
      String lineNumber,
      String url,
      String method
    ) {
      this.type = 'http';
      this.category = category + '.lineno' + lineNumber;
      this.message = message;
      this.timestamp = timestamp;

      this.data = new Map<String, Object>{ 'url' => url, 'method' => method };
    }
  }
}
