global class NightlyBatchJob implements Database.Batchable<SObject> {
  global Database.QueryLocator start(Database.BatchableContext bc) {
    try {
      return Database.getQueryLocator(
        'SELECT Id, LastActivityDate FROM Opportunity WHERE IsClosed = false'
      );
    } catch (Exception e) {
      Sentry.captureException(e);
      throw e;
    }
  }

  global void execute(Database.BatchableContext bc, List<Opportunity> scope) {
    try {
      Sentry.log(
        LoggingLevel.INFO,
        'NightlyBatchJob.execute — processing ' + scope.size() + ' records'
      );
      List<Opportunity> toUpdate = new List<Opportunity>();
      for (Opportunity opp : scope) {
        if (opp.LastActivityDate < Date.today().addDays(-90)) {
          Sentry.log('Marking opportunity ' + opp.Id + ' as Stalled');
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

  global void finish(Database.BatchableContext bc) {
    try {
      AsyncApexJob job = [
        SELECT Id, Status, NumberOfErrors
        FROM AsyncApexJob
        WHERE Id = :bc.getJobId()
      ];
      Sentry.log('NightlyBatchJob finished. Errors: ' + job.NumberOfErrors);
    } catch (Exception e) {
      Sentry.captureException(e);
      throw e;
    }
  }
}
