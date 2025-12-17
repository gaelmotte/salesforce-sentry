public with sharing class GenerateUuidInvocable {
  @InvocableMethod(label='Generate Uuid')
  public static List<String> generateUuid() {
    Integer i = 42 / 0;
    return new List<String>{ UUID.randomUUID().toString() };
  }
}
