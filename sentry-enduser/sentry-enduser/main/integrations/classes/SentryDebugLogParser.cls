public with sharing class SentryDebugLogParser {
  private static final Pattern LOGLINE_START_PATTERN = Pattern.compile(
    '^(\\d{2}):(\\d{2}):(\\d{2})\\.(\\d+) \\(\\d+\\)\\|([^|]*)\\|(.*)$'
  );

  private List<IDebugLogEntryStrategy> logEntryStrategies;

  public SentryDebugLogParser() {
    logEntryStrategies = new List<IDebugLogEntryStrategy>();
    // find all the calleses that implement the correct strategy interface
    for (ApexTypeImplementor implementor : [
      SELECT id, ClassName
      FROM ApexTypeImplementor
      WHERE InterfaceName = :IDebugLogEntryStrategy.class.getName()
    ]) {
      logEntryStrategies.add(
        (IDebugLogEntryStrategy) Type.forName(implementor.ClassName)
          .newInstance()
      );
    }
  }

  public List<SentryBreadcrumb> parseLogBody(String debugLogBody) {
    List<String> logLines = debugLogBody.split('\n');
    logLines.remove(0); //first line is a summary of log levels

    List<String> callStack = new List<String>();
    List<SentryBreadcrumb> breadcrumbs = new List<SentryBreadcrumb>();

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
