global with sharing class SentryStacktraceIntegration implements ISentryIntegration {
  private Options options;

  public static final String STACKTRACE_AS_STRING_KEY = 'stacktraceString';
  private static final List<SentryMechanismExceptionStrategy> STANDARD_MECANISM_STRATEGIES = new List<SentryMechanismExceptionStrategy>{
    new SentryMechanismExceptionStrategy(),
    new SentryMechanismDMLExceptionStrategy(),
    new SentryMechanismQueryExceptionStrategy()
  };

  public SentryStacktraceIntegration(Options options) {
    this.options = options;
  }

  public void applyToScope(SentryScope scope) {
    options.mechanismExceptionStrategies.addAll(STANDARD_MECANISM_STRATEGIES);
    options.mechanismExceptionStrategies.sort();
    scope.addProcessor(
      new SentryStacktraceEventProcessor(
        options.frameContextLines,
        options.inAppCallback,
        options.mechanismExceptionStrategies
      )
    );
  }

  public class Options {
    public Integer frameContextLines;
    public IInAppCallback inAppCallback;
    public List<SentryMechanismExceptionStrategy> mechanismExceptionStrategies;

    public Options() {
      this(5);
    }

    public Options(Integer frameContextLines) {
      this(frameContextLines, STANDARD_MECANISM_STRATEGIES);
    }
    public Options(
      Integer frameContextLines,
      List<SentryMechanismExceptionStrategy> mechanismExceptionStrategies
    ) {
      this(
        frameContextLines,
        mechanismExceptionStrategies,
        new FakeInAppCallback()
      );
    }
    public Options(
      Integer frameContextLines,
      List<SentryMechanismExceptionStrategy> mechanismExceptionStrategies,
      IInAppCallback inAppCallback
    ) {
      this.frameContextLines = frameContextLines;
      this.inAppCallback = inAppCallback;
      this.mechanismExceptionStrategies = mechanismExceptionStrategies;
    }
  }

  public interface IInAppCallback {
    boolean isInApp(SentryValueClass.Frame frame);
  }

  private class FakeInAppCallback implements IInAppCallback {
    public boolean isInApp(SentryValueClass.Frame frame) {
      return true;
    }
  }
}
