import { LightningElement } from "lwc";
import { SentryMixin } from "c/sentryMixin";

export default class BuggedLWC extends SentryMixin(
  LightningElement,
  "BuggedLWC"
) {
  connectedCallback() {
    // throw new Error("Some stupid thing happend");
    this.Sentry.log("connected");
  }

  handleClick() {
    this.Sentry.log("here is a log");
    // throw new Error("Some other stupid thing happend");
  }
}
