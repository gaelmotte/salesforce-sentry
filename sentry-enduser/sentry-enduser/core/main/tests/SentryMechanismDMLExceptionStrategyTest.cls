@IsTest
public with sharing class SentryMechanismDMLExceptionStrategyTest {
  @istest
  public static void addsDmlErrorDetails() {
    SentryMechanismDMLExceptionStrategy mechStrategy = new SentryMechanismDMLExceptionStrategy();
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
        true
      )
      .withFieldAccess(
        Sentry_Payload__c.SObjectType,
        Sentry_Payload__c.SObjectType.fields.Stored_By_Sentry__c,
        true,
        false
      )
      .build()) {
      try {
        insert as user new List<Sentry_Payload__c>{
          new Sentry_Payload__c(Payload__c = 'something'),
          new Sentry_Payload__c(
            Payload__c = 'something',
            Stored_By_Sentry__c = true
          )
        };
      } catch (Exception e) {
        Test.startTest();
        mech = mechStrategy.getMechanism(e);
        Test.stopTest();
      }

      Assert.areEqual(
        1,
        mech.data.get('numDml'),
        'should have two record failures'
      );

      Assert.areEqual(
        'Stored_By_Sentry__c',
        mech.data.get('dmlFieldNames0'),
        '1st error on Stored_By_Sentry__c'
      );
      Assert.areEqual(0, mech.data.get('dmlIndex0'), '1st record should fail');
    }

  }
}
