import { LightningElement, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getOpportunities from "@salesforce/apex/OpportunityController.getOpportunities";

import { SentryBoundaryMixin } from "c/sentryMixin";

export default class OpportunityList extends SentryBoundaryMixin(
  NavigationMixin(LightningElement),
  "OpportunityList"
) {
  opportunities;
  error;

  @wire(getOpportunities)
  wiredOpportunities({ data, error }) {
    if (data) {
      this.opportunities = data;
    } else if (error) {
      this.error =
        error?.body?.message ??
        error?.statusText ??
        "Failed to load opportunities";
    }
  }

  navigateToRecord(event) {
    const recordId = event.currentTarget.dataset.id;
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: { recordId, actionName: "view" }
    });
  }
}
