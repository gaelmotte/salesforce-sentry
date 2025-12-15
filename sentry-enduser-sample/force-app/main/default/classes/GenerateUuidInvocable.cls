public with sharing class GenerateUuidInvocable {
  @InvocableMethod(label='Generate Uuid')
  public static List<String> generateUuid(List<Lead> leads) {
    List<String> uuids = new List<String>();
    for (Lead l : leads) {
      uuids.add(UUID.randomUUID().toString());
    }
    return uuids;
  }
}
