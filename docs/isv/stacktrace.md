# Stacktrace Integration

Parses Apex stack traces into structured frames for display in Sentry.

```apex
new SentryStacktraceIntegration()                             // 5 context lines, all frames in-app
new SentryStacktraceIntegration(10)                           // 10 context lines
new SentryStacktraceIntegration(5, myStrategies)              // custom exception strategies
new SentryStacktraceIntegration(5, myStrategies, myCallback)  // + custom in-app filter
```

## Custom in-app filter

By default all frames are marked as in-app. Implement `IInAppCallback` to mark only your namespace:

```apex
public class MyInAppCallback implements SentryStacktraceIntegration.IInAppCallback {
  public Boolean isInApp(SentryValueClass.Frame frame) {
    return 'myns'.equals(frame.namespace);
  }
}
```

## Custom exception strategies

Extend `SentryMechanismExceptionStrategy` to handle custom exception types:

```apex
public class MyExceptionStrategy extends SentryMechanismExceptionStrategy {
  public override System.Type getExceptionType() {
    return MyCustomException.class;
  }
}
```

::: warning
Surrounding source context lines require Tooling API access. This feature behavior with managed packages (where `ApexClass.Body` may be null) is still being verified — treat source context as best-effort in ISV mode.
:::
