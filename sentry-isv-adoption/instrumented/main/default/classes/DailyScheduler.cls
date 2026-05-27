public class DailyScheduler implements Schedulable {
  public void execute(SchedulableContext ctx) {
    try {
      NightlyBatchJob batch = new NightlyBatchJob();
      Database.executeBatch(batch, 200);
    } catch (Exception e) {
      Sentry.captureException(e);
      throw e;
    }
  }
}
