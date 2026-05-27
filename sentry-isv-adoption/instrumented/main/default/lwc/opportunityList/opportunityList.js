import { LightningElement, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getOpportunities from "@salesforce/apex/OpportunityController.getOpportunities";

import { SentryBoundaryMixin, Sentry } from "c/sentryMixin";

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
      this[Sentry].log(`Loaded ${data.length} opportunities`);
    } else if (error) {
      this.error =
        error?.body?.message ??
        error?.statusText ??
        "Failed to load opportunities";
      this[Sentry].captureException(new Error(this.error));
    }
  }

  navigateToRecord(event) {
    const recordId = event.currentTarget.dataset.id;
    this[Sentry].log(`Navigating to opportunity: ${recordId}`);
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: { recordId, actionName: "view" }
    });
  }
}
