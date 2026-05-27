public class NightlyBatchJob implements Database.Batchable<SObject> {
  public Database.QueryLocator start(Database.BatchableContext bc) {
    try {
      return Database.getQueryLocator(
        'SELECT Id, LastActivityDate FROM Opportunity WHERE IsClosed = false'
      );
    } catch (Exception e) {
      Sentry.captureException(e);
      throw e;
    }
  }

  public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
    try {
      List<Opportunity> toUpdate = new List<Opportunity>();
      for (Opportunity opp : scope) {
        if (opp.LastActivityDate < Date.today().addDays(-90)) {
          opp.StageName = 'Stalled';
          toUpdate.add(opp);
        }
      }
      if (!toUpdate.isEmpty()) {
        update toUpdate;
      }
    } catch (Exception e) {
      Sentry.captureException(e);
      throw e;
    }
  }

  public void finish(Database.BatchableContext bc) {
    try {
      AsyncApexJob job = [
        SELECT Id, Status, NumberOfErrors
        FROM AsyncApexJob
        WHERE Id = :bc.getJobId()
      ];
      System.debug('NightlyBatchJob finished. Errors: ' + job.NumberOfErrors);
    } catch (Exception e) {
      Sentry.captureException(e);
      throw e;
    }
  }
}
