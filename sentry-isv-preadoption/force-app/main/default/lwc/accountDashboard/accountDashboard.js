import { LightningElement, api, wire } from "lwc";
import getAccountDetails from "@salesforce/apex/AccountController.getAccountDetails";
import updateAccountStatus from "@salesforce/apex/AccountController.updateAccountStatus";
import getContactsByAccount from "@salesforce/apex/AccountController.getContactsByAccount";

export default class AccountDashboard extends LightningElement {
  @api recordId;

  account;
  contacts;
  error;

  @wire(getAccountDetails, { accountId: "$recordId" })
  wiredAccount({ data, error }) {
    if (data) {
      this.account = data;
      console.log(`Account loaded: ${data.Name}`);
    } else if (error) {
      this.error =
        error?.body?.message ?? error?.statusText ?? "Failed to load account";
      console.log(`Failed to load account: ${this.error}`);
    }
  }

  @wire(getContactsByAccount, { accountId: "$recordId" })
  wiredContacts({ data, error }) {
    if (data) {
      this.contacts = data;
      console.log(`Loaded ${data.length} contacts`);
    } else if (error) {
      this.error =
        error?.body?.message ?? error?.statusText ?? "Failed to load contacts";
      console.log(`Failed to load contacts: ${this.error}`);
    }
  }

  handleStatusChange(event) {
    const newStatus = event.detail.value;
    console.log(`Updating status to: ${newStatus}`);
    updateAccountStatus({ accountId: this.recordId, status: newStatus })
      .then(() => {
        console.log(`Status updated to: ${newStatus}`);
        this.dispatchEvent(new CustomEvent("statusupdated"));
      })
      .catch((error) => {
        this.error =
          error?.body?.message ??
          error?.statusText ??
          "Failed to update status";
        console.log(`Failed to update status: ${this.error}`);
      });
  }

  handleContactSelected(event) {
    console.log(`Contact selected from child: ${event.detail}`);
  }
}
