public with sharing class SentryDebugLogMethodStrategy implements SentryDebugLogParser.IDebugLogEntryStrategy {
  private static final Pattern LOGLINE_METHOD_STACK_PATTERN = Pattern.compile(
    '\\[(\\d+)\\]\\|[^|]*\\|(.*)?$'
  );

  public SentryDebugLogMethodStrategy() {
  }

  public void process(
    SentryDebugLogParser.DebugLogEntry entry,
    List<String> callStack,
    List<SentryBreadcrumb> breadcrumbs
  ) {
    if (entry.type != 'METHOD_EXIT' && entry.type != 'METHOD_ENTRY') {
      return;
    }

    Matcher matcher = LOGLINE_METHOD_STACK_PATTERN.matcher(entry.content);
    if (!matcher.find()) {
      System.debug(LoggingLevel.ERROR, 'Failed to match');
      return;
    }

    if (entry.type == 'METHOD_EXIT') {
      callStack.remove(callStack.size() - 1);
      return;
    }

    callStack.add(matcher.group(2));
  }
}
