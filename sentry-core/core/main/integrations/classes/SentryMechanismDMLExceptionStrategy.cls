public virtual class SentryMechanismDMLExceptionStrategy extends SentryMechanismExceptionStrategy {
  public virtual override System.Type getExceptionType() {
    return DmlException.class;
  }
  public virtual override SentryValueClassMechanism getMechanism(Exception ex) {
    SentryValueClassMechanism mechanism = super.getMechanism(ex);

    for (Integer i = 0; i < Math.min(ex.getNumDml(), 5); i++) {
      mechanism.data.put('dmlFieldNames' + i, ex.getDmlFieldNames(i));
      mechanism.data.put('dmlId' + i, ex.getDmlId(i));
      mechanism.data.put('dmlIndex' + i, ex.getDmlIndex(i));
      mechanism.data.put('dmlMessage' + i, ex.getDmlMessage(i));
      mechanism.data.put('dmlStatusCode' + i, ex.getDmlStatusCode(i));
      mechanism.data.put('dmlType' + i, ex.getDmlType(i));
    }

    mechanism.data.put('numDml', ex.getNumDml());

    mechanism.type = getExceptionType().getName();
    System.debug(JSON.serialize(mechanism.data));

    return mechanism;
  }
}
