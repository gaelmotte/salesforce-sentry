import { LightningElement, api, wire } from "lwc";
import getAccountDetails from "@salesforce/apex/AccountController.getAccountDetails";
import updateAccountStatus from "@salesforce/apex/AccountController.updateAccountStatus";
import getContactsByAccount from "@salesforce/apex/AccountController.getContactsByAccount";

import { SentryBoundaryMixin, Sentry } from "c/sentryMixin";

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
      this[Sentry].log(JSON.stringify(["Account loaded:", data.Name]));
    } else if (error) {
      this.error =
        error?.body?.message ?? error?.statusText ?? "Failed to load account";
      this[Sentry].log(`Failed to load account: ${this.error}`);
    }
  }

  @wire(getContactsByAccount, { accountId: "$recordId" })
  wiredContacts({ data, error }) {
    if (data) {
      this.contacts = data;
      this[Sentry].log(`Loaded ${data.length} contacts`);
    } else if (error) {
      this.error =
        error?.body?.message ?? error?.statusText ?? "Failed to load contacts";
      this[Sentry].log(`Failed to load contacts: ${this.error}`);
    }
  }

  handleStatusChange(event) {
    const newStatus = event.detail.value;
    this[Sentry].log(`Updating status to: ${newStatus}`);
    updateAccountStatus({ accountId: this.recordId, status: newStatus })
      .then(() => {
        this[Sentry].log(`Status updated to: ${newStatus}`);
        this.dispatchEvent(new CustomEvent("statusupdated"));
      })
      .catch((error) => {
        this.error =
          error?.body?.message ??
          error?.statusText ??
          "Failed to update status";
        this[Sentry].log(
          JSON.stringify(["Failed to update status:", this.error])
        );
      });
  }

  handleContactSelected(event) {
    this[Sentry].log(`Contact selected from child: ${event.detail}`);
  }
}
