public with sharing class SentryRuntimeContext extends SentryContext {
  public static final String TYPE = 'runtime';
  public static final String APEX = 'apex';
  public static final String FLOW = 'flow';
  public static final String LWC = 'lwc';
  private string name;

  public SentryRuntimeContext(String name) {
    this.type = TYPE;
    this.name = name;
  }

  public override Map<String, Object> getData() {
    return new Map<String, object>{ 'name' => this.name };
  }
}
