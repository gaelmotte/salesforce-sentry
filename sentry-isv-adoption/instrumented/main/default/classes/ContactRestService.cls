@RestResource(urlMapping='/contacts/*')
global with sharing class ContactRestService {
  @HttpGet
  global static Contact getContact() {
    try {
      String contactId = RestContext.request.requestURI.substringAfterLast('/');
      return [
        SELECT Id, FirstName, LastName, Email, Phone
        FROM Contact
        WHERE Id = :contactId
        LIMIT 1
      ];
    } catch (Exception e) {
      Sentry.captureException(e);
      throw e;
    }
  }

  @HttpPost
  global static Id createContact() {
    try {
      String body = RestContext.request.requestBody.toString();
      Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(
        body
      );
      Contact c = new Contact(
        FirstName = (String) payload.get('firstName'),
        LastName = (String) payload.get('lastName'),
        Email = (String) payload.get('email')
      );
      insert c;
      return c.Id;
    } catch (Exception e) {
      Sentry.captureException(e);
      throw e;
    }
  }

  @HttpDelete
  global static void deleteContact() {
    try {
      String contactId = RestContext.request.requestURI.substringAfterLast('/');
      Contact c = [SELECT Id FROM Contact WHERE Id = :contactId LIMIT 1];
      delete c;
    } catch (Exception e) {
      Sentry.captureException(e);
      throw e;
    }
  }
}
