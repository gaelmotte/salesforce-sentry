import { LightningElement, api } from "lwc";

export default class ContactCard extends LightningElement {
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
