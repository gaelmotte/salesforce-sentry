Http http = new Http();
HttpRequest request = new HttpRequest();
request.setEndpoint(
  Url.getSalesforceBaseUrl().toExternalForm() +
  '/services/data/v58.0/tooling/sobjects/PlatformEventSubscriberConfig/3JK7Y0000004EWlWAM'
);
request.setMethod('GET');
request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());

HttpResponse response = http.send(request);

System.debug(response.getBody());
