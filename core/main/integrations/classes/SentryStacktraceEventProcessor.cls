public with sharing class SentryStacktraceEventProcessor extends SentryEventProcessor {
  private Integer frameContextLines;
  private SentryStacktraceIntegration.IInAppCallback inAppCallback;
  private List<SentryMechanismExceptionStrategy> mechanismExceptionStrategies;

  private Set<String> classnames;
  Map<ApexClass, List<String>> apexClassesAndBody;

  public SentryStacktraceEventProcessor(
    Integer frameContextLines,
    SentryStacktraceIntegration.IInAppCallback inAppCallback,
    List<SentryMechanismExceptionStrategy> mechanismExceptionStrategies
  ) {
    this.frameContextLines = frameContextLines;
    this.inAppCallback = inAppCallback;
    this.mechanismExceptionStrategies = mechanismExceptionStrategies;
  }

  public override SentryEvent processAtCapture(SentryEvent event) {
    event.ex = fromException(event.getOriginException());
    return event;
  }

  private List<SentryValueClass> fromException(Exception ex) {
    List<SentryValueClass> values = new List<SentryValueClass>{ extract(ex) };
    Exception cause = ex.getCause();
    while (cause != null) {
      values.add(extract(cause));
      cause = cause.getCause();
    }
    return values;
  }

  private SentryValueClass extract(Exception ex) {
    SentryValueClass valueClass = new SentryValueClass();

    valueClass.type = ex.getTypeName();
    valueClass.value = ex.getMessage();
    valueClass.mechanism = getStrategy(ex).getMechanism(ex);

    return valueClass;
  }

  private SentryMechanismExceptionStrategy getStrategy(Exception ex) {
    for (
      SentryMechanismExceptionStrategy strategy : mechanismExceptionStrategies
    ) {
      if (
        strategy.getExceptionType()
          .isAssignableFrom(Type.forName(ex.getTypeName()))
      ) {
        return strategy;
      }
    }
    return null;
  }

  /**
   * Add code context
   */
  public override SentryEvent processAtTransport(SentryEvent event) {
    parseStacktraceStrings(event);
    fetchApexClasses();
    return decorateFramesWithDetails(event);
  }

  private SentryEvent decorateFramesWithDetails(SentryEvent event) {
    for (SentryValueClass valueClass : event.ex) {
      for (SentryValueClass.Frame frame : valueClass.stacktrace.frames) {
        ApexClass apexClass = findMatchingClass(
          frame.filename,
          frame.namespace
        );
        if (apexClass == null) {
          continue;
        }
        frame.in_app = inAppCallback.isInApp(frame);
        frame.platform = apexclass.ApiVersion.format();
        Integer lineIndex = frame.lineno - 1;
        List<String> apexClassBodyLines = this.apexClassesAndBody.get(
          apexClass
        );
        if (
          apexClassBodyLines == null ||
          apexClassBodyLines.size() < lineIndex
        ) {
          continue;
        }
        frame.context_line = apexClassBodyLines.get(lineIndex);
        Slicer s = new Slicer(apexClassBodyLines);
        frame.pre_context = s.slice(lineIndex - frameContextLines, lineIndex);
        frame.post_context = s.slice(
          lineIndex + 1,
          lineIndex + frameContextLines + 1
        );
      }
    }
    return event;
  }

  private void parseStacktraceStrings(SentryEvent event) {
    this.classnames = new Set<String>();
    for (SentryValueClass valueClass : event.ex) {
      String stacktraceString = (string) valueClass.mechanism.data.get(
        SentryStacktraceIntegration.STACKTRACE_AS_STRING_KEY
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
        valueClass.stacktrace.frames.add(new SentryValueClass.Frame(apexFrame));
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
      Integer i = Math.max(x_begin, 0);
      while (i < olist.size() && i < x_end) {
        ret.add(olist[i]);
        i++;
      }
      return ret;
    }
  }
}
