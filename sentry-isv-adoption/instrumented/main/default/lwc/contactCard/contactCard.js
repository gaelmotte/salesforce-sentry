import { LightningElement, api } from "lwc";

import { SentryMixin } from "c/sentryMixin";

export default class ContactCard extends SentryMixin(
  LightningElement,
  "ContactCard"
) {
  @api contact;

  get fullName() {
    return `${this.contact.FirstName} ${this.contact.LastName}`;
  }

  handleClick() {
    this.dispatchEvent(
      new CustomEvent("contactselected", { detail: this.contact.Id })
    );
  }
}
