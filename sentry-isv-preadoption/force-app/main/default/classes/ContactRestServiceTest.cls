@IsTest
private class ContactRestServiceTest {
  static Contact insertContact() {
    Account acc = new Account(Name = 'Rest Test Account');
    insert acc;
    Contact c = new Contact(
      FirstName = 'Rest',
      LastName = 'User',
      Email = 'rest@test.com',
      AccountId = acc.Id
    );
    insert c;
    return c;
  }

  @IsTest
  static void testGetContact() {
    Contact c = insertContact();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/contacts/' + c.Id;
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;

    Contact result = ContactRestService.getContact();
    System.assertEquals(c.Id, result.Id);
    System.assertEquals('rest@test.com', result.Email);
  }

  @IsTest
  static void testCreateContact() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/contacts/';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(
      '{"firstName":"New","lastName":"Person","email":"new@test.com"}'
    );
    RestContext.request = req;
    RestContext.response = res;

    Id result = ContactRestService.createContact();
    System.assertNotEquals(null, result);
    Contact created = [
      SELECT FirstName, LastName
      FROM Contact
      WHERE Id = :result
    ];
    System.assertEquals('New', created.FirstName);
    System.assertEquals('Person', created.LastName);
  }

  @IsTest
  static void testDeleteContact() {
    Contact c = insertContact();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/contacts/' + c.Id;
    req.httpMethod = 'DELETE';
    RestContext.request = req;
    RestContext.response = res;

    ContactRestService.deleteContact();
    System.assertEquals(0, [SELECT COUNT() FROM Contact WHERE Id = :c.Id]);
  }
}
