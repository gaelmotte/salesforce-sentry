import { LightningElement, api, wire } from "lwc";
import getAccountDetails from "@salesforce/apex/AccountController.getAccountDetails";
import updateAccountStatus from "@salesforce/apex/AccountController.updateAccountStatus";
import getContactsByAccount from "@salesforce/apex/AccountController.getContactsByAccount";

import { SentryBoundaryMixin } from "c/sentryMixin";

export default class AccountDashboard extends SentryBoundaryMixin(
  LightningElement,
  "AccountDashboard"
) {
  @api recordId;

  account;
  contacts;
  error;

  @wire(getAccountDetails, { accountId: "$recordId" })
  wiredAccount({ data, error }) {
    if (data) {
      this.account = data;
    } else if (error) {
      this.error =
        error?.body?.message ?? error?.statusText ?? "Failed to load account";
    }
  }

  @wire(getContactsByAccount, { accountId: "$recordId" })
  wiredContacts({ data, error }) {
    if (data) {
      this.contacts = data;
    } else if (error) {
      this.error =
        error?.body?.message ?? error?.statusText ?? "Failed to load contacts";
    }
  }

  handleStatusChange(event) {
    const newStatus = event.detail.value;
    updateAccountStatus({ accountId: this.recordId, status: newStatus })
      .then(() => {
        this.dispatchEvent(new CustomEvent("statusupdated"));
      })
      .catch((error) => {
        this.error =
          error?.body?.message ??
          error?.statusText ??
          "Failed to update status";
      });
  }

  handleContactSelected(event) {
    console.log(event);
  }
}
