public with sharing class SentryTestSafeQueueable {
  public static Id enqueueJob(Queueable queueable) {
    if (Test.isRunningTest() && Limits.getLimitQueueableJobs() == 1) {
      return '000000000000000000';
    }
    if (Limits.getQueueableJobs() > Limits.getLimitQueueableJobs()) {
      throw new SentryException('Queuable limit');
    } else {
      return System.enqueueJob(queueable);
    }
  }
}
