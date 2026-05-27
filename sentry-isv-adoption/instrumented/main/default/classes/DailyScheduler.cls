public class DailyScheduler implements Schedulable {
  public void execute(SchedulableContext ctx) {
    NightlyBatchJob batch = new NightlyBatchJob();
    Database.executeBatch(batch, 200);
  }
}
