public class SomeClass {
  public Double throwsMathException() {
    return 1 / 0;
  }
  public void throwsNestedException() {
    try {
      throwsMathException();
    } catch (Exception e) {
      throw new HandledException('No Way ! it threw ?!', e);
    }
  }
  public Account throwsDmlException() {
    Account acc = new Account();
    insert acc;
    return acc;
  }
}

try {
  (new SomeClass()).throwsNestedException();
} catch (Exception e) {
  System.debug(e.getStacktraceString());
  System.debug(
    JSON.serialize(SentryStacktraceParser.parse(e.getStacktraceString()))
  );
  Sentry.captureException(e);
}

HttpRequest request = new HttpRequest();
request.setEndpoint(
  Url.getSalesforceBaseUrl().toExternalForm() +
  '/services/data/v35.0/tooling/sobjects/ApexLog/07L7Y00000Tr4J9UAJ/Body'
);
request.setMethod('GET');
request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());

Http http = new Http();
HttpResponse response = http.send(request);
System.debug('RESPONSE = '+response.getBody());
