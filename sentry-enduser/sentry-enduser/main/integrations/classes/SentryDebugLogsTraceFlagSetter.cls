public with sharing class SentryDebugLogsTraceFlagSetter {
  private SentryToolingApiClient toolingApiClient;

  public SentryDebugLogsTraceFlagSetter(String namedCredDevName) {
    this.toolingApiClient = new SentryToolingApiClient(namedCredDevName);
  }

  // the more EventTypes we handle the finer these levels should get
  /* use this payload to upsert the debug log level */
  private static final Map<String, Object> DEBUG_LEVEL = new Map<String, Object>{
    'ApexCode' => 'FINEST',
    'ApexProfiling' => 'FINEST',
    'Database' => 'FINEST',
    'System' => 'FINE',
    'Validation' => 'INFO',
    'DeveloperName' => 'Sentry_Debug_Level',
    'MasterLabel' => 'Sentry_Debug_Level'
  };

  public void setTraceFlag(Id userId) {
    Id debugLevelId = toolingApiClient.ensure(
      'DebugLevel',
      new Map<String, String>{
        'DeveloperName' => (String) DEBUG_LEVEL.get('DeveloperName')
      },
      DEBUG_LEVEL
    );

    Map<String, Object> TRACE_FLAG_PATCH = new Map<String, Object>{
      'StartDate' => null,
      'ExpirationDate' => Datetime.now().addDays(1)
    };

    Map<String, Object> TRACE_FLAG_POST = new Map<String, Object>{
      'TracedEntityId' => userId,
      'StartDate' => null,
      'ExpirationDate' => Datetime.now().addDays(1),
      'LogType' => 'USER_DEBUG',
      'DebugLevelId' => debugLevelId
    };

    toolingApiClient.ensure(
      'TraceFlag',
      new Map<String, String>{
        'TracedEntityId' => userId,
        'DebugLevelId' => debugLevelId
      },
      TRACE_FLAG_POST,
      TRACE_FLAG_PATCH
    );
  }
}
