public class SentryStacktraceParser {
  public static final Pattern CLASS_PATTERN = Pattern.compile(
    '^Class\\.(?:([^\\.]*)__)?([^\\.]*)\\.(?:([^\\.:]*)\\.)?([^:]*)?: line ([0-9]+), column ([0-9]+)$'
  );
  public static final Pattern TRIGGER_PATTERN = Pattern.compile(
    '^Trigger\\.(?:([^\\.]*)__)?([^\\.]*): line ([0-9]+), column ([0-9]+)$'
  );
  public static final Pattern DEFAULT_PATTERN = Pattern.compile(
    '^([^:]*): line ([0-9]+), column ([0-9]+)$'
  );

  private SentryStacktraceParser() {
  }

  public static List<ApexFrame> parse(String stacktraceString) {
    List<ApexFrame> frames = new List<ApexFrame>();

    List<String> frameStrings = stacktraceString.split('\n');
    for (String frameString : frameStrings) {
      Matcher matcher = CLASS_PATTERN.matcher(frameString);
      if (matcher.find()) {
        ApexFrame frame = new ApexFrame();
        frame.namespace = matcher.group(1);
        frame.classname = matcher.group(2);
        frame.subclassname = matcher.group(3) != null
          ? matcher.group(2) + '.' + matcher.group(3)
          : null;
        frame.function = matcher.group(4);
        frame.linenumber = Integer.valueOf(matcher.group(5));
        frame.colnumber = Integer.valueOf(matcher.group(6));
        frames.add(frame);
        continue;
      }
      matcher = TRIGGER_PATTERN.matcher(frameString);
      if (matcher.find()) {
        ApexFrame frame = new ApexFrame();
        frame.namespace = matcher.group(1);
        frame.classname = matcher.group(2);
        frame.subclassname = null;
        frame.function = null;
        frame.linenumber = Integer.valueOf(matcher.group(3));
        frame.colnumber = Integer.valueOf(matcher.group(4));
        frames.add(frame);
        continue;
      }
      matcher = DEFAULT_PATTERN.matcher(frameString);
      if (matcher.find()) {
        ApexFrame frame = new ApexFrame();
        frame.namespace = null;
        frame.classname = matcher.group(1);
        frame.subclassname = null;
        frame.function = null;
        frame.linenumber = Integer.valueOf(matcher.group(2));
        frame.colnumber = Integer.valueOf(matcher.group(3));
        frames.add(frame);
        continue;
      }
      ApexFrame frame = new ApexFrame();
      frame.defaultPresentation = frameString;
      frames.add(frame);
    }
    return frames;
  }

  public class ApexFrame {
    public String namespace;
    public String classname;
    public String subclassname;
    public String function;
    public Integer linenumber;
    public Integer colnumber;
    public String defaultPresentation;
  }

  public class FlowFrame {
    public String namespace;
    public String flowDeveloperName;
  }
}
