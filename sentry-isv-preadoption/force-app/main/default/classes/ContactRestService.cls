@RestResource(urlMapping='/contacts/*')
global with sharing class ContactRestService {
  @HttpGet
  global static Contact getContact() {
    String contactId = RestContext.request.requestURI.substringAfterLast('/');
    return [
      SELECT Id, FirstName, LastName, Email, Phone
      FROM Contact
      WHERE Id = :contactId
      LIMIT 1
    ];
  }

  @HttpPost
  global static Id createContact() {
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
  }

  @HttpDelete
  global static void deleteContact() {
    String contactId = RestContext.request.requestURI.substringAfterLast('/');
    Contact c = [SELECT Id FROM Contact WHERE Id = :contactId LIMIT 1];
    delete c;
  }
}
