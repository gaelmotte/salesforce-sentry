public with sharing class SentryDebugLogCalloutStrategy implements SentryDebugLogsEventProcessor.IDebugLogEntryStrategy {
  private static final Pattern LOGLINE_CALLOUT_RESPONSE_PATTERN = Pattern.compile(
    '\\[(\\d+)\\]\\|System.HttpResponse\\[Status=([^,]*), StatusCode=([^\\]]*)\\]$'
  );
  private static final Pattern LOGLINE_CALLOUT_REQUEST_PATTERN = Pattern.compile(
    '\\[(\\d+)\\]\\|System.HttpRequest\\[Endpoint=([^,]*), Method=([^\\]]*)\\]$'
  );
  public SentryDebugLogCalloutStrategy() {
  }

  private HttpBreadcrumb currentBreadCrumb;

  public void process(
    SentryDebugLogsEventProcessor.DebugLogEntry entry,
    List<String> callStack,
    List<SentryBreadcrumb> breadcrumbs
  ) {
    if (entry.type != 'CALLOUT_REQUEST' && entry.type != 'CALLOUT_RESPONSE') {
      return;
    }

    if (entry.type == 'CALLOUT_REQUEST') {
      Matcher matcher = LOGLINE_CALLOUT_REQUEST_PATTERN.matcher(entry.content);
      if (!matcher.find()) {
        System.debug(LoggingLevel.ERROR, 'Failed to match');
        return;
      }

      currentBreadCrumb = new HttpBreadcrumb(
        callStack.get(callStack.size() - 1),
        entry.timestamp,
        matcher.group(1),
        matcher.group(2),
        matcher.group(3)
      );

      return;
    }

    if (entry.type == 'CALLOUT_RESPONSE') {
      if (currentBreadCrumb == null) {
        System.debug(LoggingLevel.ERROR, 'No previous callout request');
        return;
      }

      Matcher matcher = LOGLINE_CALLOUT_RESPONSE_PATTERN.matcher(entry.content);
      if (!matcher.find()) {
        System.debug(LoggingLevel.ERROR, 'Failed to match');
        return;
      }

      currentBreadCrumb.data.putAll(
        new Map<String, Object>{
          'reason' => matcher.group(2),
          'status_code' => matcher.group(3)
        }
      );
      breadcrumbs.add(currentBreadCrumb);
      this.currentBreadCrumb = null;
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
