import { LightningElement, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getOpportunities from "@salesforce/apex/OpportunityController.getOpportunities";

// Exposed component with existing NavigationMixin composition
export default class OpportunityList extends NavigationMixin(LightningElement) {
  opportunities;
  error;

  @wire(getOpportunities)
  wiredOpportunities({ data, error }) {
    if (data) {
      this.opportunities = data;
    } else if (error) {
      this.error = error;
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
