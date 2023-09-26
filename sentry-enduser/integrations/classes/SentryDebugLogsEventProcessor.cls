public with sharing class SentryDebugLogsEventProcessor extends SentryEventProcessor {
  private static final String REQUEST_ID_TAG = 'RequestId';
  private static final String QUIDITTY_TAG = 'Quiddity';
  private static final Pattern LOGLINE_START_PATTERN = Pattern.compile(
    '^(\\d{2}):(\\d{2}):(\\d{2})\\.(\\d+) \\(\\d+\\)\\|([^|]*)\\|(.*)$'
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
    List<String> logLines = debugLogBody.split('\n');
    logLines.remove(0); //first line is a summary of log levels

    List<String> callStack = new List<String>();
    List<SentryBreadcrumb> breadcrumbs = new List<SentryBreadcrumb>();
    // TODO find all the strategies
    List<IDebugLogEntryStrategy> logEntryStrategies = new List<IDebugLogEntryStrategy>{
      new SentryDebugLogUserDebugStrategy(),
      new SentryDebugLogMethodStrategy(),
      new SentryDebugLogCalloutStrategy()
    };

    Matcher matcher;
    // HttpBreadcrumb httpBreadcrumb = null;
    DebugLogEntry currentDebugLogEntry = null;
    for (String logLine : logLines) {
      matcher = LOGLINE_START_PATTERN.matcher(logLine);
      System.debug('LOGLINE:' + logLine);
      if (logLine.length() == 0) {
        continue;
      }
      if (!matcher.find()) {
        System.debug('no match');
        if (currentDebugLogEntry == null) {
          continue; // start of log file gibberish
        }
        currentDebugLogEntry.content += '\n' + logLine; // multiline content
        continue;
      }

      // starting an new entryType, so let the strategies handle the current one;
      if (currentDebugLogEntry != null) {
        for (IDebugLogEntryStrategy currentStrategy : logEntryStrategies) {
          currentStrategy.process(currentDebugLogEntry, callStack, breadcrumbs);
        }
      }

      System.debug('match');
      // new entry
      currentDebugLogEntry = new DebugLogEntry(
        Datetime.newInstance(
          Date.today(),
          Time.newInstance(
            Integer.valueOf(matcher.group(1)),
            Integer.valueOf(matcher.group(2)),
            Integer.valueOf(matcher.group(3)),
            Integer.valueOf(matcher.group(4))
          )
        ),
        matcher.group(5),
        matcher.group(6)
      );
    }

    return breadcrumbs;
  }

  public class DebugLogEntry {
    public DebugLogEntry(Datetime timestamp, String type, String content) {
      this.timestamp = timestamp;
      this.type = type;
      this.content = content;
    }
    public Datetime timestamp;
    public String type;
    public String content;
  }

  public interface IDebugLogEntryStrategy {
    void process(
      DebugLogEntry entry,
      List<String> callStack,
      List<SentryBreadcrumb> breadcrumbs
    );
  }
}
