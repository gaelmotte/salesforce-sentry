public class NightlyBatchJob implements Database.Batchable<SObject> {
  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      'SELECT Id, LastActivityDate FROM Opportunity WHERE IsClosed = false'
    );
  }

  public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
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
  }

  public void finish(Database.BatchableContext bc) {
    AsyncApexJob job = [
      SELECT Id, Status, NumberOfErrors
      FROM AsyncApexJob
      WHERE Id = :bc.getJobId()
    ];
    System.debug('NightlyBatchJob finished. Errors: ' + job.NumberOfErrors);
  }
}
