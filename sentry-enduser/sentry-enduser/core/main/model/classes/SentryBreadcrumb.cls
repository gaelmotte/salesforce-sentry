public virtual with sharing class SentryBreadcrumb {
  public String type;
  public String category;
  public String message;
  public Map<String, Object> data;
  /**
   * This defines the severity level of the breadcrumb. Allowed values are, from highest to lowest:
   * * fatal,
   * * error,
   * * warning,
   * * info,
   * * and debug.
   * Levels are used in the UI to emphasize and deemphasize the crumb. The default is info.
   */
  public String level;
  public Datetime timestamp;
  public SentryBreadcrumb() {
  }
  public SentryBreadcrumb(String salesforceLogLevel) {
    switch on salesforceLogLevel {
      when 'ERROR' {
        this.level = 'error';
      }
      when 'WARN' {
        this.level = 'warning';
      }
      when 'INFO' {
        this.level = 'info';
      }
      when 'DEBUG' {
        this.level = 'debug';
      }
      when else {
        // let sentry decide the default level
        this.level = null;
      }
    }
  }
}
