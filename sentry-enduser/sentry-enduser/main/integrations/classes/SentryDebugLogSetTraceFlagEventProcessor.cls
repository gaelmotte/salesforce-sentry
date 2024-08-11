public with sharing class SentryDebugLogSetTraceFlagEventProcessor extends SentryEventProcessor {
  private static final Set<Id> PROCESSED_USER_IDS = new Set<Id>();

  private SentryDebugLogsTraceFlagSetter traceFlagSetter;

  public SentryDebugLogSetTraceFlagEventProcessor(String namedCredDevName) {
    this.traceFlagSetter = new SentryDebugLogsTraceFlagSetter(namedCredDevName);
  }

  public override SentryEvent processAtTransport(SentryEvent event) {
    String runtimeName = (String) event.getContextValue(
      SentryRuntimeContext.TYPE,
      'name'
    );

    if (
      runtimeName != SentryRuntimeContext.APEX &&
      runtimeName != SentryRuntimeContext.FLOW
    ) {
      return event;
    }
    if (event.user != null && !PROCESSED_USER_IDS.contains(event.user.userId)) {
      traceFlagSetter.setTraceFlag(event.user.userId);
      PROCESSED_USER_IDS.add(event.user.userId);
    }

    return event;
  }
}
