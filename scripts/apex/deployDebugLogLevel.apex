Map<String, Object> DEBUG_LEVEL = new Map<String, Object>{
  'ApexCode' => 'FINEST',
  'ApexProfiling' => 'FINEST',
  'Database' => 'FINEST',
  'System' => 'FINE',
  'Validation' => 'INFO',
  'DeveloperName' => 'Sentry_Debug_Level',
  'MasterLabel' => 'Sentry_Debug_Level'
};

Id debugLevelId = SentryToolingCallout.ensure(
  'DebugLevel',
  new Map<String, String>{ 'DeveloperName' => 'Sentry_Debug_Level' },
  DEBUG_LEVEL
);

Map<String, Object> TRACE_FLAG_PATCH = new Map<String, Object>{
  'StartDate' => null,
  'ExpirationDate' => Datetime.now().addDays(1)
};

Map<String, Object> TRACE_FLAG_POST = new Map<String, Object>{
  'TracedEntityId' => UserInfo.getUserId(),
  'StartDate' => null,
  'ExpirationDate' => Datetime.now().addDays(1),
  'LogType' => 'USER_DEBUG',
  'DebugLevelId' => debugLevelId
};

SentryToolingCallout.ensure(
  'TraceFlag',
  new Map<String, String>{ 'TracedEntityId' => UserInfo.getUserId() },
  TRACE_FLAG_POST,
  TRACE_FLAG_PATCH
);
