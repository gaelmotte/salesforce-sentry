Http http = new Http();
// HttpRequest request = new HttpRequest();
// request.setEndpoint(
//   Url.getSalesforceBaseUrl().toExternalForm() +
//   '/services/data/v58.0/tooling/sobjects/PlatformEventSubscriberConfig'
// );
// request.setMethod('GET');
// request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());

// HttpResponse response = http.send(request);

// String configXml =
//   '<?xml version="1.0" encoding="UTF-8"?>\n' +
//   '<PlatformEventSubscriberConfig xmlns="http://soap.sforce.com/2006/04/metadata">\n' +
//   '<platformEventConsumer>ChangeEvent</platformEventConsumer>\n' +
//   '<batchSize>200</batchSize>\n' +
//   '<masterLabel>ChangeEvent</masterLabel>\n' +
//   '<user>' +
//   UserInfo.getUserName() +
//   '</user>\n' +
//   '<isProtected>false</isProtected>\n' +
//   '</PlatformEventSubscriberConfig>\n';

Map<String, Object> configMap = new Map<String, Object>{
  'platformEventConsumerId' => [
      SELECT id
      FROM ApexTrigger
      WHERE name = 'SentryEventTrigger'
      LIMIT 1
    ]
    .get(0)
    .Id,
  'DeveloperName' => 'SentryEventSubscriberConfig',
  'batchSize' => 10,
  'masterLabel' => 'Sentry Event Subsriber Config',
  'userId' => UserInfo.getUserId()
};

HttpRequest request = new HttpRequest();
request.setEndpoint(
  Url.getSalesforceBaseUrl().toExternalForm() +
  '/services/data/v58.0/tooling/sobjects/PlatformEventSubscriberConfig'
);
request.setMethod('POST');
System.debug(JSON.serialize(configMap));
request.setBody(JSON.serialize(configMap));
request.setHeader('Content-Type', 'application/json');
request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());

HttpResponse response = http.send(request);

System.debug(response.getBody());
