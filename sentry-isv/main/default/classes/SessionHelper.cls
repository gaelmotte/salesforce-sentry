public inherited sharing class SessionHelper {
  public static String getSessionId() {
    return Test.isRunningTest()
      ? null
      : Page.session.getContent().toString().trim();
  }
}
