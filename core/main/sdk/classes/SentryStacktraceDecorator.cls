public with sharing class SentryStacktraceDecorator {
  private static final Integer MAX_PRE_CONTEXT_LINES = 5;
  private static final Integer MAX_POST_CONTEXT_LINES = 5;
  private List<SentryEvent> events;
  private Set<String> classnames;
  Map<ApexClass, List<String>> apexClassesAndBody;

  public SentryStacktraceDecorator() {
  }

  public void decorate(List<SentryEvent> events) {
    this.events = events;
    parseStacktraceStrings();
    fetchApexClasses();
    decorateFramesWithDetails();
  }

  private void decorateFramesWithDetails() {
    for (SentryEvent event : events) {
      for (SentryValueClass valueClass : event.ex) {
        for (SentryValueClass.Frame frame : valueClass.stacktrace.frames) {
          ApexClass apexClass = findMatchingClass(
            frame.filename,
            frame.namespace
          );
          if (apexClass == null) {
            System.debug(
              'Failed to find the class ' +
                frame.namespace +
                '_' +
                frame.filename
            );
            continue;
          }
          frame.in_app = true; // TODO : Take a inAppDiscriminator in constructor from config
          frame.platform = apexclass.ApiVersion.format();
          Integer lineIndex = frame.lineno - 1;
          List<String> apexClassBodyLines = this.apexClassesAndBody.get(
            apexClass
          );
          if (
            apexClassBodyLines == null ||
            apexClassBodyLines.size() < lineIndex
          ) {
            System.debug(
              'Failed to get class ' +
                frame.namespace +
                '_' +
                frame.filename +
                ' body at line ' +
                frame.lineno
            );
            continue;
          }
          frame.context_line = apexClassBodyLines.get(lineIndex);
          Slicer s = new Slicer(apexClassBodyLines);
          frame.pre_context = s.slice(
            lineIndex - MAX_PRE_CONTEXT_LINES - 1,
            lineIndex - 1
          );
          frame.post_context = s.slice(
            lineIndex + 1,
            lineIndex + MAX_PRE_CONTEXT_LINES + 1
          );
        }
      }
    }
  }

  private void parseStacktraceStrings() {
    this.classnames = new Set<String>();

    for (SentryEvent event : events) {
      for (SentryValueClass valueClass : event.ex) {
        String stacktraceString = (string) valueClass.mechanism.data.get(
          SentryStacktraceFactory.STACKTRACE_AS_STRING_KEY
        );
        List<SentryStacktraceParser.ApexFrame> apexFrames = SentryStacktraceParser.parse(
          stacktraceString
        );
        valueClass.stacktrace = new SentryValueClass.Stacktrace();
        // Sentry needs it reversed
        // for (SentryStacktraceParser.ApexFrame apexFrame : apexFrames) {
        for (Integer i = apexFrames.size() - 1; i >= 0; i--) {
          SentryStacktraceParser.ApexFrame apexFrame = apexFrames.get(i);
          classnames.add(apexFrame.classname);
          valueClass.stacktrace.frames.add(
            new SentryValueClass.Frame(apexFrame)
          );
        }
      }
    }
  }

  private void fetchApexClasses() {
    this.apexClassesAndBody = new Map<ApexClass, List<String>>();
    for (ApexClass apexClass : [
      SELECT Id, Body, ApiVersion, Name, NamespacePrefix
      FROM ApexClass
      WHERE Name IN :classnames
    ]) {
      System.debug(JSON.serialize(apexClass));
      this.apexClassesAndBody.put(
        apexClass,
        apexClass.Body != null ? apexClass.Body.split('\n') : null
      );
    }
  }

  private ApexClass findMatchingClass(String classname, string namespace) {
    for (ApexClass apexClass : this.apexClassesAndBody.keySet()) {
      if (
        apexClass.Name == classname &&
        (namespace == null ||
        apexClass.NamespacePrefix == namespace)
      ) {
        return apexClass;
      }
    }
    return null;
  }

  private class Slicer {
    private list<String> olist;
    public Slicer(list<String> olist) {
      this.olist = olist;
    }

    public list<String> slice(Integer x_begin, Integer x_end) {
      list<String> ret = new List<String>();
      Integer maxIndex = olist.size();
      Integer i = Math.max(x_begin, 0);
      while (i < maxIndex && i < x_end) {
        ret.add(olist[i]);
        i++;
      }
      return ret;
    }
  }
}
