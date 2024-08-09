import { LightningElement } from "lwc";

export default class BuggedLWC extends LightningElement {
  connectedCallback() {
    throw new Error("Some stupid thing happend");
  }

  handleClick() {
    throw new Error("Some other stupid thing happend");
  }
}
