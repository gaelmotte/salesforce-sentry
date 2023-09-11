public with sharing class SentryConfigNoop implements SentryConfigInterface {
    public SentryConfigNoop() {

    }
    public Boolean isEnabled(){
        return false;
    }

    public SentryDSN getDSN(){
        return null;
    }
}