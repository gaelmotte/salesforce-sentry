public with sharing class SentryToolingCallout {
  private class ToolingApiCalloutException extends Exception {
  }
  private class ToolingQueryResult {
    public ToolingQueryResult(Object o) {
      Map<String, Object> m = (Map<String, Object>) o;
      this.size = (Integer) m.get('size');
      this.totalSize = (Integer) m.get('totalSize');
      this.records = (List<Object>) m.get('records');
    }
    public Integer size;
    public Integer totalSize;
    private List<Object> records;
    public Map<String, Object> getRecord(Integer index) {
      return (Map<String, Object>) records.get(index);
    }
  }

  private class ToolingCreateResult {
    public ToolingCreateResult(Object o) {
      Map<String, Object> m = (Map<String, Object>) o;
      this.id = (Id) m.get('id');
      this.success = (Boolean) m.get('success');
      this.errors = (List<Object>) m.get('errors');
      this.warnings = (List<Object>) m.get('warnings');
      this.infos = (List<Object>) m.get('infos');
    }
    public Id id;
    public Boolean success;
    public List<Object> errors;
    public List<Object> warnings;
    public List<Object> infos;
  }
  public SentryToolingCallout() {
  }

  private static final Http http = new Http();

  public static ToolingQueryResult query(String soql) {
    HttpRequest request = new HttpRequest();
    request.setEndpoint(
      'callout:Sentry_SDK_Tooling_Api_Credential/services/data/v58.0/tooling/query/?q=' +
      EncodingUtil.urlEncode(soql, 'UTF-8')
    );
    request.setMethod('GET');
    HttpResponse response = http.send(request);
    return new ToolingQueryResult(JSON.deserializeUntyped(response.getBody()));
  }

  public static void patch(
    String sobjectType,
    Id id,
    Map<String, Object> payload
  ) {
    HttpRequest request = new HttpRequest();

    request.setEndpoint(
      'callout:Sentry_SDK_Tooling_Api_Credential/services/data/v58.0/tooling/sobjects/' +
        sobjectType +
        '/' +
        id
    );
    request.setMethod('PATCH');

    request.setBody(JSON.serialize(payload));
    request.setHeader('Content-Type', 'application/json');

    HttpResponse response = http.send(request);
    if (response.getStatusCode() != 204) {
      throw new ToolingApiCalloutException(
        'Failed to patch record [' +
          response.getStatusCode() +
          ']' +
          response.getBody()
      );
    }
  }

  public static ToolingCreateResult post(
    String sobjectType,
    Map<String, Object> payload
  ) {
    HttpRequest request = new HttpRequest();

    request.setEndpoint(
      'callout:Sentry_SDK_Tooling_Api_Credential/services/data/v58.0/tooling/sobjects/' +
      sobjectType
    );
    request.setMethod('POST');

    request.setBody(JSON.serialize(payload));
    request.setHeader('Content-Type', 'application/json');

    HttpResponse response = http.send(request);
    return new ToolingCreateResult(JSON.deserializeUntyped(response.getBody()));
  }

  public static Id ensure(
    String sobjectType,
    Map<String, String> criteriaMap,
    Map<String, Object> postPayload
  ) {
    return ensure(sobjectType, criteriaMap, postPayload, postPayload);
  }

  public static Id ensure(
    String sobjectType,
    Map<String, String> criteriaMap,
    Map<String, Object> postPayload,
    Map<String, Object> patchPayload
  ) {
    List<String> criteriaList = new List<String>();
    for (String key : criteriaMap.keySet()) {
      criteriaList.add(key + '=\'' + criteriaMap.get(key) + '\'');
    }
    ToolingQueryResult queryResult = query(
      'select id from ' +
        sobjectType +
        ' where ' +
        String.join(criteriaList, ' and ') +
        ' limit 1'
    );
    if (queryResult.size == 1) {
      // update it
      patch(sobjectType, (Id) queryResult.getRecord(0).get('Id'), patchPayload);
      return (Id) queryResult.getRecord(0).get('Id');
    }

    // create it;
    ToolingCreateResult postResult = post(sobjectType, postPayload);
    return postResult.id;
  }
}
