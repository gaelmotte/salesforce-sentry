public virtual class SentryMechanismDMLExceptionStrategy extends SentryMechanismExceptionStrategy {
  public virtual override System.Type getExceptionType() {
    return DmlException.class;
  }
  public virtual override SentryValueClass.Mechanism getMechanism(
    Exception ex
  ) {
    SentryValueClass.Mechanism mechanism = super.getMechanism(ex);

    Map<String, Object> details = new Map<String, Object>();
    for (Integer i = 0; i < Math.min(ex.getNumDml(), 5); i++) {
      details.putAll(
        new Map<String, Object>{
          'dmlFieldNames' + i => ex.getDmlFieldNames(i),
          'dmlId' + i => ex.getDmlId(i),
          'dmlIndex' + i => ex.getDmlIndex(i),
          'dmlMessage' + i => ex.getDmlMessage(i),
          'dmlStatusCode' + i => ex.getDmlStatusCode(i),
          'dmlType' + i => ex.getDmlType(i)
        }
      );
    }

    mechanism.data.put('numDml', ex.getNumDml());
    mechanism.data.putAll(details);

    mechanism.type = getExceptionType().getName();

    return mechanism;
  }
}
