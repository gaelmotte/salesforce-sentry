public with sharing class SentryUserIntegration implements ISentryIntegration {

    public SentryUserIntegration() {

    }

    public void applyToScope(SentryScope scope) {
        scope.addProcessor(new SentryUserEventProcessor());
    }
}