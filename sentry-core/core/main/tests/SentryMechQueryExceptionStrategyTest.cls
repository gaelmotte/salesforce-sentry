@istest
public with sharing class SentryMechQueryExceptionStrategyTest {
  @isTest
  public static void addsInaccessibleFields() {
    SentryMechanismQueryExceptionStrategy mechStrategy = new SentryMechanismQueryExceptionStrategy();
    SentryValueClassMechanism mech;

    System.runAs((new TestUserBuilder())
      .withObjectAccess(
        Sentry_Payload__c.SObjectType,
        TestUserBuilder.OBJECT_PERM_TYPE.READ
      )
      .withObjectAccess(
        Sentry_Payload__c.SObjectType,
        TestUserBuilder.OBJECT_PERM_TYPE.CREATE
      )
      .withFieldAccess(
        Sentry_Payload__c.SObjectType,
        Sentry_Payload__c.SObjectType.fields.Payload__c,
        true,
        false
      )
      .build()) {
      insert new Sentry_Payload__c();
      try {
        Sentry_Payload__c payload = [
          SELECT id, Error__c, Payload__c, Stored_By_Sentry__c
          FROM Sentry_Payload__c
          WITH USER_MODE
          LIMIT 1
        ];
      } catch (QueryException e) {
        Test.startTest();
        mech = mechStrategy.getMechanism(e);
        Test.stopTest();
      }
    }
    Assert.areEqual(
      mechStrategy.getExceptionType().getName(),
      mech.type,
      'should give the correct type'
    );
    Assert.areEqual(
      'Error__c, Stored_By_Sentry__c',
      mech.data.get('Sentry_Payload__c'),
      'should list the two fields'
    );
  }
}
