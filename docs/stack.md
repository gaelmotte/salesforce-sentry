# StackTraceIntegration

It enriches events with detais about the APEX stacktrace.

## Parameters

| position |                   type                   |        default         | effect                                                                                                                              |
| :------: | :--------------------------------------: | :--------------------: | :---------------------------------------------------------------------------------------------------------------------------------- |
|    1     |                 Integer                  |           5            | Number of lines of code before and after the faulty line should be added as context                                                 |
|    2     | List< SentryMechanismExceptionStrategy > |           []           | List of Strategies to enrich the exception with. Should you implement your own custom exception, this can help capture usefull data |
|    3     |     class implements IInAppCallback      | AllFramesInAppCallback | Callback to define what frames are `inApp`                                                                                          |
