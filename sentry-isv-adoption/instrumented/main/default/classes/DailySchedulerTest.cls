@IsTest
private class DailySchedulerTest {
  @IsTest
  static void testSchedule() {
    Test.startTest();
    String jobId = System.schedule(
      'NightlyBatchJobTest',
      '0 0 2 * * ?',
      new DailyScheduler()
    );
    Test.stopTest();
    System.assertNotEquals(null, jobId);
  }
}
