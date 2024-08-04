global with sharing class SentryStacktraceIntegration implements ISentryIntegration {
  private Integer frameContextLines;
  private IInAppCallback inAppCallback;
  private List<SentryMechanismExceptionStrategy> mechanismExceptionStrategies;

  public static final String STACKTRACE_AS_STRING_KEY = 'stacktraceString';
  private static final List<SentryMechanismExceptionStrategy> STANDARD_MECANISM_STRATEGIES = new List<SentryMechanismExceptionStrategy>{
    new SentryMechanismExceptionStrategy(),
    new SentryMechanismDMLExceptionStrategy(),
    new SentryMechanismQueryExceptionStrategy(),
    new SentryMechanismSyntheticFlowExStrategy()
  };

  public SentryStacktraceIntegration() {
    this(5);
  }

  public SentryStacktraceIntegration(Integer frameContextLines) {
    this(frameContextLines, new List<SentryMechanismExceptionStrategy>());
  }
  public SentryStacktraceIntegration(
    Integer frameContextLines,
    List<SentryMechanismExceptionStrategy> mechanismExceptionStrategies
  ) {
    this(
      frameContextLines,
      mechanismExceptionStrategies,
      new AllFramesInAppCallback()
    );
  }
  public SentryStacktraceIntegration(
    Integer frameContextLines,
    List<SentryMechanismExceptionStrategy> mechanismExceptionStrategies,
    IInAppCallback inAppCallback
  ) {
    this.frameContextLines = frameContextLines;
    this.inAppCallback = inAppCallback;
    this.mechanismExceptionStrategies = mechanismExceptionStrategies;
  }

  public void applyToScope(SentryScope scope) {
    List<SentryMechanismExceptionStrategy> mechs = mechanismExceptionStrategies.clone();
    mechs.addAll(STANDARD_MECANISM_STRATEGIES);
    mechs.sort();
    scope.addProcessor(
      new SentryStacktraceEventProcessor(
        frameContextLines,
        inAppCallback,
        mechs
      )
    );
  }

  public interface IInAppCallback {
    boolean isInApp(SentryValueClass.Frame frame);
  }

  private class AllFramesInAppCallback implements IInAppCallback {
    public boolean isInApp(SentryValueClass.Frame frame) {
      return true;
    }
  }
}
