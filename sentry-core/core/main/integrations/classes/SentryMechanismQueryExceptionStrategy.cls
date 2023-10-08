public with sharing class SentryMechanismQueryExceptionStrategy extends SentryMechanismExceptionStrategy {
  public virtual override System.Type getExceptionType() {
    return QueryException.class;
  }
  public virtual override SentryValueClassMechanism getMechanism(Exception ex) {
    SentryValueClassMechanism mechanism = super.getMechanism(ex);

    Map<String, Object> details = new Map<String, Object>();
    Map<String, Set<String>> inaccessibleFields = ex.getInaccessibleFields();
    for (String sobjectType : inaccessibleFields.keySet()) {
      mechanism.data.put(
        sobjectType,
        String.join(inaccessibleFields.get(sobjectType), ', ')
      );
    }

    mechanism.type = getExceptionType().getName();

    return mechanism;
  }
}
