import { LightningElement, api, wire } from "lwc";
import getAccountDetails from "@salesforce/apex/AccountController.getAccountDetails";
import updateAccountStatus from "@salesforce/apex/AccountController.updateAccountStatus";

// Exposed page-level component — should receive SentryBoundaryMixin
export default class AccountDashboard extends LightningElement {
  @api recordId;

  account;
  error;

  @wire(getAccountDetails, { accountId: "$recordId" })
  wiredAccount({ data, error }) {
    if (data) {
      this.account = data;
    } else if (error) {
      this.error = error;
    }
  }

  handleStatusChange(event) {
    const newStatus = event.detail.value;
    updateAccountStatus({ accountId: this.recordId, status: newStatus })
      .then(() => {
        this.dispatchEvent(new CustomEvent("statusupdated"));
      })
      .catch((error) => {
        this.error = error;
      });
  }
}
