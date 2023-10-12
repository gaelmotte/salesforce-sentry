public with sharing class SentryDebugLogsEventProcessor extends SentryEventProcessor {
  private static final String REQUEST_ID_TAG = 'RequestId';
  private static final String QUIDITTY_TAG = 'Quiddity';
  private static final Pattern LOGLINE_START_PATTERN = Pattern.compile(
    '^(\\d{2}):(\\d{2}):(\\d{2})\\.(\\d+) \\(\\d+\\)\\|([^|]*)\\|(.*)$'
  );

  // the more EventTypes we handle the finer these levels should get
  /* use this payload to upsert the debug log level */
  private static final Map<String, Object> DEBUG_LEVEL = new Map<String, Object>{
    'ApexCode' => 'FINEST',
    'ApexProfiling' => 'FINEST',
    'Database' => 'FINEST',
    'System' => 'FINE',
    'Validation' => 'INFO',
    'DeveloperName' => 'Sentry_Debug_Level',
    'MasterLabel' => 'Sentry_Debug_Level'
  };

  private SentryToolingApiClient toolingApiClient;
  private Boolean autoAddUserDebugFlag;

  public SentryDebugLogsEventProcessor(
    Boolean autoAddUserDebugFlag,
    String namedCredDevName
  ) {
    this.toolingApiClient = new SentryToolingApiClient(namedCredDevName);
    this.autoAddUserDebugFlag = autoAddUserDebugFlag;
  }

  public override SentryEvent processAtCapture(SentryEvent event) {
    // Request id must me present since we use it to retrieve the debug logs
    event.tags.put(REQUEST_ID_TAG, Request.getCurrent().getRequestId());
    event.tags.put(QUIDITTY_TAG, Request.getCurrent().getQuiddity().name());

    return event;
  }

  public override SentryEvent processAtTransport(SentryEvent event) {
    setTraceFlag(event);

    List<String> debugLogBodies = getDebugLogBody(event);
    if (debugLogBodies.size() == 0) {
      return event;
    }
    for (String debugLogBody : debugLogBodies) {
      List<SentryBreadcrumb> logBreadcrumbs = parseLogBody(debugLogBody);
      event.breadcrumbs.addAll(logBreadcrumbs);
    }
    return event;
  }

  private void setTraceFlag(SentryEvent event) {
    if (!autoAddUserDebugFlag) {
      return;
    }

    Id userId = (Id) event.user.userId;

    Id debugLevelId = toolingApiClient.ensure(
      'DebugLevel',
      new Map<String, String>{
        'DeveloperName' => (String) DEBUG_LEVEL.get('DeveloperName')
      },
      DEBUG_LEVEL
    );

    Map<String, Object> TRACE_FLAG_PATCH = new Map<String, Object>{
      'StartDate' => null,
      'ExpirationDate' => Datetime.now().addDays(1)
    };

    Map<String, Object> TRACE_FLAG_POST = new Map<String, Object>{
      'TracedEntityId' => userId,
      'StartDate' => null,
      'ExpirationDate' => Datetime.now().addDays(1),
      'LogType' => 'USER_DEBUG',
      'DebugLevelId' => debugLevelId
    };

    toolingApiClient.ensure(
      'TraceFlag',
      new Map<String, String>{
        'TracedEntityId' => userId,
        'DebugLevelId' => debugLevelId
      },
      TRACE_FLAG_POST,
      TRACE_FLAG_PATCH
    );
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
      // actually does a callout, but does not require the complex setup
      PageReference pageRef = new PageReference(
        '/servlet/servlet.FileDownload?file=' + log.Id
      );

      bodies.add(pageRef.getContent().toString());
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
    DebugLogEntry currentDebugLogEntry = null;
    for (String logLine : logLines) {
      matcher = LOGLINE_START_PATTERN.matcher(logLine);
      if (logLine.length() == 0) {
        continue;
      }
      if (!matcher.find()) {
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
