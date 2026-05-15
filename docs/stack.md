# StackTrace Integration

Parses raw Apex stack trace strings into structured frames that Sentry can display with file, line, and function information.

At send time (Phase 2), the Tooling API is used to retrieve surrounding source lines for each frame — giving you pre/post context around the line that threw.

## Usage

```apex
new sentrysdk.SentryStacktraceIntegration()                              // defaults
new sentrysdk.SentryStacktraceIntegration(10)                            // 10 context lines
new sentrysdk.SentryStacktraceIntegration(5, myStrategies)               // custom strategies
new sentrysdk.SentryStacktraceIntegration(5, myStrategies, myCallback)   // + custom in-app filter
```

## Parameters

| Position |                          Type                          |      Default      | Effect                                                                          |
| :------: | :----------------------------------------------------: | :---------------: | :------------------------------------------------------------------------------ |
|    1     |                        Integer                         |        `5`        | Number of source lines before and after the faulting line to include as context |
|    2     |   `List<sentrysdk.SentryMechanismExceptionStrategy>`   |       `[]`        | Additional strategies for enriching specific exception subtypes                 |
|    3     | `sentrysdk.SentryStacktraceIntegration.IInAppCallback` | All frames in-app | Callback to decide which frames belong to your application                      |

## Custom in-app filter

By default all frames are marked as in-app. Implement `IInAppCallback` to mark only your own namespace:

```apex
public class MyInAppCallback implements sentrysdk.SentryStacktraceIntegration.IInAppCallback {
  public Boolean isInApp(sentrysdk.SentryValueClass.Frame frame) {
    return 'myns'.equals(frame.namespace);
  }
}
```

Pass it as the third constructor argument:

```apex
new sentrysdk.SentryStacktraceIntegration(
  5,
  new List<sentrysdk.SentryMechanismExceptionStrategy>(),
  new MyInAppCallback()
)
```

## Custom exception strategies

Extend `sentrysdk.SentryMechanismExceptionStrategy` to control how a specific exception subtype is represented in the Sentry `mechanism` field — useful for custom exception classes that carry extra diagnostic data.

```apex
public class MyExceptionStrategy extends sentrysdk.SentryMechanismExceptionStrategy {
  public override System.Type getExceptionType() {
    return MyCustomException.class;
  }
}
```

Pass your strategies as the second constructor argument:

```apex
new sentrysdk.SentryStacktraceIntegration(5, new List<sentrysdk.SentryMechanismExceptionStrategy>{
  new MyExceptionStrategy()
})
```
