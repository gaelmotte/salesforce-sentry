global with sharing class SentryCaptureFlowFaultPropertyEditorCtrl {
  @AuraEnabled
  global static string getFlowDefitionId(
    SentryCaptureFlowFaultPropertyEditorPara params
  ) {
    try {
      System.debug('called the apex action');
      System.debug(JSON.serialize(params));

      // find the flowdefitinion by looking the flow
      FlowVersionView flowVersionView = [
        SELECT durableId, FlowDefinitionViewId
        FROM FlowVersionView
        WHERE durableId = :params.flowId
        LIMIT 1
      ];
      FlowDefinitionView flowDefinitionView = [
        SELECT id, durableId, ActiveVersionId, ApiName, LatestVersionId
        FROM FlowDefinitionView
        WHERE durableId = :flowVersionView.FlowDefinitionViewId
        LIMIT 1
      ];

      System.debug(
        'found flow definition id ' +
          flowDefinitionView.durableId +
          ' for flow ' +
          params.flowId
      );
      return flowDefinitionView.durableId;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
