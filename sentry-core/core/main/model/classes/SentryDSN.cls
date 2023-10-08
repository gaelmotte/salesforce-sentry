public with sharing class SentryDSN {
  private Url dsn;
  /**
   * Note The secret part of the DSN is optional and effectively deprecated at this point.
   * While clients are still supposed to honor it if supplied future versions of Sentry will entirely ignore it.
   * The DSN parsing code must not require the secret key to be set.
   */
  //   public String privateKey { get; private set; }
  public String publicKey { get; private set; }
  public String projectId { get; private set; }
  public Url baseUri { get; private set; }

  /**
   * https://develop.sentry.dev/sdk/overview/#parsing-the-dsn
   */
  public SentryDSN(String dsn) {
    if (dsn == null) {
      return;
    }
    this.dsn = new Url(dsn);

    this.projectId = this.dsn.getFile().replace('/', '');

    List<String> userInfo = this.dsn.getUserInfo().split(':');
    this.publicKey = userInfo[0];
    // this.privateKey = userInfo.size() == 2 ? userInfo[1] : null;

    this.baseUri = new Url(
      this.dsn.getProtocol(),
      this.dsn.getHost(),
      this.dsn.getPort(),
      '/api/' + this.projectId
    );
  }
}
