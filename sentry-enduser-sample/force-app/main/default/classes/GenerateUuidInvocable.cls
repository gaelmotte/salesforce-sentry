public with sharing class GenerateUuidInvocable {
  @InvocableMethod(label='Generate Uuid')
  public static List<String> generateUuid() {
    return new List<String>{ UUID.randomUUID().toString() };
  }
}
