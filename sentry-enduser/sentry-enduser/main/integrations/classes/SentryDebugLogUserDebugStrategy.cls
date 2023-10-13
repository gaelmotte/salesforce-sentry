public with sharing class SentryDebugLogUserDebugStrategy implements SentryDebugLogParser.IDebugLogEntryStrategy {
  private static final Pattern LOGLINE_DEBUG_PATTERN = Pattern.compile(
    '\\[(\\d+)\\]\\|([^|]*)\\|(.*)?$'
  );
  public SentryDebugLogUserDebugStrategy() {
  }

  public void process(
    SentryDebugLogParser.DebugLogEntry entry,
    List<String> callStack,
    List<SentryBreadcrumb> breadcrumbs
  ) {
    if (entry.type != 'USER_DEBUG') {
      return;
    }

    Matcher matcher = LOGLINE_DEBUG_PATTERN.matcher(entry.content);
    if (!matcher.find()) {
      System.debug(LoggingLevel.ERROR, 'Failed to match');
      return;
    }

    LogBreadcrumb logBreadCrumb = new LogBreadcrumb(
      callStack.get(callStack.size() - 1),
      entry.timestamp,
      matcher.group(1),
      matcher.group(2),
      matcher.group(3)
    );

    breadcrumbs.add(logBreadCrumb);
  }

  private class LogBreadcrumb extends SentryBreadcrumb {
    public LogBreadcrumb(
      String category,
      Datetime timestamp,
      String lineNumber,
      String level,
      String message
    ) {
      super(level);
      this.type = 'debug';
      this.category = category + '.lineno' + lineNumber;
      this.message = message;
      this.timestamp = timestamp;
    }
  }
}
