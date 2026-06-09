// Manually fires NightlyBatchJob to trigger the unknown-stage crash (scenario 3).
// The batch marks open Opportunities with no recent activity as 'Stalled'.
// 'Stalled' is not in the ISV package's stageProbability map, so OpportunityTrigger
// throws IllegalArgumentException → captured by the trigger and the batch job.
Database.executeBatch(new sentrysdk.NightlyBatchJob());
System.debug('NightlyBatchJob queued — check Sentry for the Stalled stage error.');
