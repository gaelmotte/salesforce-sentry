public with sharing class SentryLWCErrorEventProcessor extends SentryEventProcessor {
  public SentryLWCErrorEventProcessor() {
  }

  public override SentryEvent processAtCapture(SentryEvent event) {
    Sentry.SentryLWCErrorInputParameters input = event.getOriginLWCError();
    if (input == null) {
      return event;
    }

    // add breadcrumbs from logs
    for (Sentry.SentryLWCLog log : input.logs) {
      event.breadcrumbs.add(
        new LWCLogBreadcrumb(log.componentName, log.timestamp, log.message)
      );
    }
    // build the stack
    SentryValueClass valueClass = new SentryValueClass();
    valueClass.mechanism = new SentryValueClassMechanism();
    valueClass.mechanism.data = new Map<String, Object>{};
    valueClass.mechanism.type = input.mechanism;
    valueClass.mechanism.synthetic = true;
    valueClass.value = input.error;

    valueClass.stacktrace = new SentryValueClass.Stacktrace();
    valueClass.stacktrace.frames.addAll(getFramesFromCmpStack(input.cmpStack));
    valueClass.stacktrace.frames.addAll(getFramesFromStack(input.stack));

    event.ex = new List<SentryValueClass>{ valueClass };

    return event;
  }

  private List<SentryValueClass.Frame> getFramesFromStack(List<String> stack) {
    List<SentryValueClass.Frame> frames = new List<SentryValueClass.Frame>();
    for (String stackTraceLine : stack) {
      frames.add(SentryValueClass.Frame.fromLWCStack(stackTraceLine));
    }

    return frames;
  }

  private List<SentryValueClass.Frame> getFramesFromCmpStack(
    List<String> cmpStack
  ) {
    List<SentryValueClass.Frame> frames = new List<SentryValueClass.Frame>();
    for (String stackTraceLine : cmpStack) {
      SentryValueClass.Frame frame = new SentryValueClass.Frame();
      frame.module = stackTraceLine;
      frames.add(frame);
    }
    return frames;
  }

  private class LWCLogBreadcrumb extends SentryBreadcrumb {
    public LWCLogBreadcrumb(
      String category,
      Datetime timestamp,
      String message
    ) {
      super('DEBUG');
      this.type = 'debug';
      this.category = category;
      this.message = message;
      this.timestamp = timestamp;
    }
  }
}
