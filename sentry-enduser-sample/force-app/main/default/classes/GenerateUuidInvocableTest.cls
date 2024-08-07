@isTest
public class GenerateUuidInvocableTest {
  @isTest
  static void testGenerateUuid() {
    Test.startTest();
    String generatedUuid = GenerateUuidInvocable.generateUuid()[0];
    Test.stopTest();

    System.assertEquals(
      36,
      generatedUuid.length(),
      'Generated UUID should be of length 36'
    );
  }
}
