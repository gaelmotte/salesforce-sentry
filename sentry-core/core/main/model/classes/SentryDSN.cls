public with sharing class SentryDSN {
  public string rawDsn;
  /**
   * Note The secret part of the DSN is optional and effectively deprecated at this point.
   * While clients are still supposed to honor it if supplied future versions of Sentry will entirely ignore it.
   * The DSN parsing code must not require the secret key to be set.
   */
  //   public String privateKey { get; private set; }
  public String publicKey { get; private set; }
  public String projectId { get; private set; }
  public Url baseUri { get; private set; }
  public Boolean valid { get; private set; }

  /**
   * https://develop.sentry.dev/sdk/overview/#parsing-the-dsn
   */
  public SentryDSN(String dsn) {
    rawDsn = dsn;
    valid = false;
    if (dsn == null) {
      return;
    }
    try {
      Url dsnUrl = new Url(dsn);

      this.projectId = dsnUrl.getFile().replace('/', '');

      List<String> userInfo = dsnUrl.getUserInfo().split(':');
      this.publicKey = userInfo[0];

      this.baseUri = new Url(
        dsnUrl.getProtocol(),
        dsnUrl.getHost(),
        dsnUrl.getPort(),
        '/api/' + this.projectId
      );
      valid = true;
    } catch (Exception e) {
      System.debug('Invalid DSN provided');
    }
  }
}
