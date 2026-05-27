@IsTest
private class NightlyBatchJobTest {
  @IsTest
  static void testBatch_startAndFinish() {
    // No open opportunities → execute called with empty scope, finish still runs
    Test.startTest();
    Database.executeBatch(new NightlyBatchJob(), 200);
    Test.stopTest();
  }

  @IsTest
  static void testExecute_emptyScope() {
    NightlyBatchJob job = new NightlyBatchJob();
    job.execute(null, new List<Opportunity>());
  }
}
