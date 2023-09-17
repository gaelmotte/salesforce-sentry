global with sharing class SentryStacktraceIntegration implements ISentryIntegration {
  private Options options;

  public static final String STACKTRACE_AS_STRING_KEY = 'stacktraceString';
  private static final List<SentryMechanismExceptionStrategy> STANDARD_MECANISM_STRATEGIES = new List<SentryMechanismExceptionStrategy>{
    new SentryMechanismExceptionStrategy(STACKTRACE_AS_STRING_KEY),
    new SentryMechanismDMLExceptionStrategy()
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
    public Options() {
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

    public Options(
      Integer frameContextLines,
      List<SentryMechanismExceptionStrategy> mechanismExceptionStrategies
    ) {
      this.frameContextLines = frameContextLines;
      this.inAppCallback = new FakeInAppCallback();
      this.mechanismExceptionStrategies = mechanismExceptionStrategies;
    }

    public Options(Integer frameContextLines) {
      this.frameContextLines = frameContextLines;
      this.inAppCallback = new FakeInAppCallback();
      this.mechanismExceptionStrategies = new List<SentryMechanismExceptionStrategy>();
    }

    public Integer frameContextLines = 5;
    public IInAppCallback inAppCallback = new FakeInAppCallback();
    public List<SentryMechanismExceptionStrategy> mechanismExceptionStrategies = new List<SentryMechanismExceptionStrategy>();
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
