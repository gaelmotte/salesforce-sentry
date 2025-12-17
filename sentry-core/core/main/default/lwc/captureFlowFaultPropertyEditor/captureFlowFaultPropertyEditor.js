import { api, LightningElement } from "lwc";

import getFlowDefinitionId from "@salesforce/apex/SentryCaptureFlowFaultPropertyEditorCtrl.getFlowDefitionId";

export default class CaptureFlowFaultPropertyEditor extends LightningElement {
  @api
  inputVariables;

  @api
  elementInfo;

  get interviewGUID() {
    return this.inputVariables.find(
      (variable) => variable.name === "interviewGUID"
    )?.value;
  }

  get faultMessage() {
    return this.inputVariables.find(
      (variable) => variable.name === "faultMessage"
    )?.value;
  }

  get elementApiName() {
    return this.inputVariables.find(
      (variable) => variable.name === "elementApiName"
    )?.value;
  }

  get flowDefinitionId() {
    return this.inputVariables.find(
      (variable) => variable.name === "flowDefinitionId"
    )?.value;
  }

  @api
  validate() {
    return [];
  }

  setDefaultProperties() {
    const interviewGUIDvalueChangedEvent = new CustomEvent(
      "configuration_editor_input_value_changed",
      {
        bubbles: true,
        cancelable: false,
        composed: true,
        detail: {
          name: "interviewGUID",
          newValue: "{!$Flow.InterviewGuid}",
          newValueDataType: "String"
        }
      }
    );
    this.dispatchEvent(interviewGUIDvalueChangedEvent);
    const faultMessagevalueChangedEvent = new CustomEvent(
      "configuration_editor_input_value_changed",
      {
        bubbles: true,
        cancelable: false,
        composed: true,
        detail: {
          name: "faultMessage",
          newValue: "{!$Flow.FaultMessage}",
          newValueDataType: "String"
        }
      }
    );
    this.dispatchEvent(faultMessagevalueChangedEvent);
    const elementApiNamevalueChangedEvent = new CustomEvent(
      "configuration_editor_input_value_changed",
      {
        bubbles: true,
        cancelable: false,
        composed: true,
        detail: {
          name: "elementApiName",
          newValue: this.elementInfo.apiName,
          newValueDataType: "String"
        }
      }
    );
    this.dispatchEvent(elementApiNamevalueChangedEvent);
  }

  setFlowDefinitionId() {
    const params = new URLSearchParams(window.location.search);
    const value = params.get("flowId");
    console.log("found flow id", value);
    getFlowDefinitionId({ params: { flowId: value } }).then((result) => {
      console.log("found flow definition id", result);
      const flowDefinitionIdvalueChangedEvent = new CustomEvent(
        "configuration_editor_input_value_changed",
        {
          bubbles: true,
          cancelable: false,
          composed: true,
          detail: {
            name: "flowDefinitionId",
            newValue: result,
            newValueDataType: "String"
          }
        }
      );
      this.dispatchEvent(flowDefinitionIdvalueChangedEvent);
    });
  }

  connectedCallback() {
    this.setDefaultProperties();
    this.setFlowDefinitionId();
  }
}
