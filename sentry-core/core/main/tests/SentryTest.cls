@isTest
public with sharing class SentryTest {
  // private class Thrower {
  //   public void throwsMathsException() {
  //     System.debug('How much makes 42 divived by 0 ? ' + (42 / 0));
  //   }

  //   public void throwsDMLException() {
  //     insert new Account();
  //   }
  // }

  // private class Catcher {
  //   public void catchesMathsException() {
  //     try {
  //       (new Thrower()).throwsMathsException();
  //     } catch (Exception e) {
  //       Sentry.captureException(e);
  //     }
  //   }
  //   public void catchesDMLException() {
  //     try {
  //       (new Thrower()).throwsDMLException();
  //     } catch (Exception e) {
  //       Sentry.captureException(e);
  //     }
  //   }
  // }

  private class SentryIngestMock implements HttpCalloutMock {
    public HttpResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setStatus('OK');
      res.setStatusCode(200);
      return res;
    }
  }

  @IsTest
  public static void handlesExceptionAndEnqueuesTransportEventJob() {
    // Test.setMock(HttpCalloutMock.class, new SentryIngestMock());

    Test.startTest();
    try {
      System.debug('How much makes 42 divived by 0 ? ' + (42 / 0));
    } catch (Exception e) {
      Sentry.captureException(e);
    }
    Test.stopTest();
    AsyncApexJob job = [SELECT id, ApexClass.Name FROM AsyncApexJob LIMIT 1];
    System.debug('job:' + json.serialize(job));
    Assert.isNotNull(job, 'shoudl have enqued a QueueableTransportEvent');
    Assert.areEqual(SentryClient.class.getName(), job.ApexClass.Name);
  }

  @isTest
  public static void throwsWhenInstanciated() {
    Boolean threw = false;
    try {
      new Sentry();
    } catch (Exception e) {
      System.Assert.isTrue(
        e.getMessage().contains('is not meant to be instanciated')
      );
      threw = true;
    } finally {
      System.Assert.isTrue(threw);
    }
  }
}
