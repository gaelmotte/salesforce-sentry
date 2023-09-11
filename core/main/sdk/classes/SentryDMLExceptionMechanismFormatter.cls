public with sharing class SentryDMLExceptionMechanismFormatter extends SentryExceptionMechanismFormatter {
  public virtual override Boolean supports(Exception ex) {
    System.Type exType = System.Type.forName(ex.getTypeName());

    return DmlException.class.isAssignableFrom(exType) ||
      EmailException.class.isAssignableFrom(exType);
  }
  public virtual override SentryValueClass.Mechanism getMechanism(
    Exception ex
  ) {
    SentryValueClass.Mechanism mechanism = super.getMechanism(ex);

    List<Map<String, Object>> details = new List<Map<String, Object>>();
    for (Integer i = 0; i < ex.getNumDml(); i++) {
      details.add(
        new Map<String, Object>{
          'dmlFieldNames' => ex.getDmlFieldNames(i),
          'dmlId' => ex.getDmlId(i),
          'dmlIndex' => ex.getDmlIndex(i),
          'dmlMessage' => ex.getDmlMessage(i),
          'dmlStatusCode' => ex.getDmlStatusCode(i),
          'dmlType' => ex.getDmlType(i)
        }
      );
    }

    mechanism.data.putAll(
      new Map<String, Object>{
        'numDml' => ex.getNumDml(),
        'details' => details
      }
    );

    mechanism.type = 'DMLException';

    return mechanism;
  }
}
