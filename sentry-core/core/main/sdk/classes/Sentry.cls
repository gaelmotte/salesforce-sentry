/**
 * https://develop.sentry.dev/sdk/unified-api/#static-api
 */
global with sharing class Sentry {
  @testVisible
  private Sentry() {
    throw new TypeException('JSONDeserializer is not meant to be instanciated');
  }

  global static void captureException(Exception ex) {
    SentryHub.getCurrentHub().captureException(ex);
  }

  @AuraEnabled
  global static void captureLWCError(SentryLWCErrorInputParameters event) {
    try {
      System.debug('called the apex action');
      System.debug(JSON.serialize(event));
      SentryHub.getCurrentHub().captureLWCError('error', 'stack', 'cmpStack');
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description Entry method for Flow's Exception
   * @param inputParameters Input parameter with the Interview GUID
   */
  @InvocableMethod(
    label='Sentry - Flow exception'
    description='Send the flow exception to Sentry'
    iconName='resource:sentryLogo:logo'
  )
  global static void captureFlowFault(
    List<SentryFlowInputParameters> inputParameters
  ) {
    // Check input parameters is valid
    for (SentryFlowInputParameters inputParam : inputParameters) {
      String flowInterviewGUID = inputParam.interviewGUID;
      String flowFaultMessage = inputParam.faultMessage;
      if (
        String.isBlank(flowInterviewGUID) && String.isBlank(flowFaultMessage)
      ) {
        throw new SentryException('Input parameters invalid');
      }
      SentryHub.getCurrentHub()
        .captureFlowFault(flowInterviewGUID, flowFaultMessage);
    }
  }

  // public static void captureMessage(String message) {
  //   SentryHub.getCurrentHub().captureMessage(message);
  // }

  // public static void addBreadcrumb(SentryBreadcrumb crumb) {
  //   SentryHub.getCurrentHub().addBreadcrumb(crumb);
  // }

  /**
   * This is the recommended method when the framework is able to push scopes itself.
   * In the case of Salesforce, no hook is available, so scopes need to be pushed and popped by the caller
   */
  // public static void pushScope(
  //   System.Type scopeType,
  //   ISentryConfigureScopeCallback callback
  // ) {
  //   // TODO check scopetype extends SentryScope
  //   // TODO check the callback can handle the ScopeType
  //   SentryHub.getCurrentHub().pushScope(scopeType, callback);
  // }

  // public static void popScope() {
  //   SentryHub.getCurrentHub().popScope();
  // }

  // public static String getLastEventId() {
  //   return 'todo';
  // }

  // notion of session does not make sense for Salesforce

  // Internal class for Invocable flow method
  global class SentryFlowInputParameters {
    @InvocableVariable(label='Flow Interview GUID' required=true)
    public String interviewGUID;
    @InvocableVariable(label='Flow Fault Message' required=true)
    public String faultMessage;
  }

  global class SentryLWCErrorInputParameters {
    @AuraEnabled
    public String error { get; set; }
    @AuraEnabled
    public String stack { get; set; }
    @AuraEnabled
    public String cmpStack { get; set; }
    @AuraEnabled
    public List<SentryLWCLog> logs { get; set; }
  }

  global class SentryLWCLog {
    @AuraEnabled
    public String message { get; set; }
    @AuraEnabled
    public String componentName { get; set; }
    @AuraEnabled
    public Datetime timestamp { get; set; }
  }
}
