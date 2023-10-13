public with sharing class SentryTestSafeQueueable {
  private static Integer jobQueuedCount = 0;

  public static Id enqueueJob(Queueable queueable) {
    if (Test.isRunningTest() && jobQueuedCount == 1) {
      return '000000000000000000';
    }
    jobQueuedCount++;
    return System.enqueueJob(queueable);
  }
}
