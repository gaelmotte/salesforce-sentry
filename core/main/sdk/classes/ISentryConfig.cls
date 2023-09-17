/** Only 1 Class should implement this. Having 0 or more than 1 defaults to NoOp  */
public interface ISentryConfig {
  /** Simply use the DSN value from your sentry project */
  SentryDSN getDSN();
  /** Should Sentry handle events */
  Boolean isEnabled();

  List<ISentryIntegration> getIntegrations();
}
