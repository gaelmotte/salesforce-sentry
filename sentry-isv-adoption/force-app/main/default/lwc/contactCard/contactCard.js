import { LightningElement, api } from "lwc";

// Internal child component — not exposed, should receive SentryMixin
export default class ContactCard extends LightningElement {
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
