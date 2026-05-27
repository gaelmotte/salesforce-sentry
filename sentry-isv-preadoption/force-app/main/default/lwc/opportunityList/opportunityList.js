import { LightningElement, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getOpportunities from "@salesforce/apex/OpportunityController.getOpportunities";

export default class OpportunityList extends NavigationMixin(LightningElement) {
  opportunities;
  error;

  @wire(getOpportunities)
  wiredOpportunities({ data, error }) {
    if (data) {
      this.opportunities = data;
      console.log(`Loaded ${data.length} opportunities`);
    } else if (error) {
      this.error =
        error?.body?.message ??
        error?.statusText ??
        "Failed to load opportunities";
    }
  }

  navigateToRecord(event) {
    const recordId = event.currentTarget.dataset.id;
    console.log(`Navigating to opportunity: ${recordId}`);
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: { recordId, actionName: "view" }
    });
  }
}
