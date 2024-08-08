public with sharing class SentryDebugLogFlowElementStrategy implements SentryDebugLogParser.IDebugLogEntryStrategy {
  private static final Pattern FLOWELEMENT_PATTERN = Pattern.compile(
    '.*\\|(\\w+)\\|(.*)$'
  );
  public SentryDebugLogFlowElementStrategy() {
  }

  public void process(
    SentryDebugLogParser.DebugLogEntry entry,
    List<String> callStack,
    List<SentryBreadcrumb> breadcrumbs
  ) {
    if (
      entry.type != 'FLOW_ELEMENT_END' &&
      entry.type != 'FLOW_ELEMENT_FAULT'
    ) {
      return;
    }

    Matcher matcher = FLOWELEMENT_PATTERN.matcher(entry.content);
    if (!matcher.find()) {
      System.debug(LoggingLevel.ERROR, 'Failed to match');
      return;
    }

    FlowElementBreadcrumb flowElementBreadcrumb = new FlowElementBreadcrumb(
      entry.type == 'FLOW_ELEMENT_FAULT',
      matcher.group(1),
      entry.timestamp,
      matcher.group(2)
    );

    breadcrumbs.add(flowElementBreadcrumb);
  }

  private class FlowElementBreadcrumb extends SentryBreadcrumb {
    public FlowElementBreadcrumb(
      Boolean error,
      String category,
      Datetime timestamp,
      String message
    ) {
      super(error ? 'error' : 'debug');
      this.type = error ? 'error' : 'default';
      this.category = category;
      this.message = message;
      this.timestamp = timestamp;
    }
  }
}
