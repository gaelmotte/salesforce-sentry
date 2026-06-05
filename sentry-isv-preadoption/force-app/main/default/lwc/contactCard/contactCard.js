import { LightningElement, api } from "lwc";

// eslint-disable-next-line no-unused-vars
import { SentryMixin, Sentry } from "c/sentryMixin";

export default class ContactCard extends SentryMixin(
  LightningElement,
  "ContactCard"
) {
  @api contact;

  get fullName() {
    return `${this.contact.FirstName} ${this.contact.LastName}`;
  }

  handleClick() {
    console.log(`Contact selected: ${this.contact.Id}`);
    this.dispatchEvent(
      new CustomEvent("contactselected", { detail: this.contact.Id })
    );
  }
}
