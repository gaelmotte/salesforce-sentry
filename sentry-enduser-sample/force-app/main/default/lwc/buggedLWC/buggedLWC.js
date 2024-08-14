import { LightningElement } from "lwc";
import { SentryMixin, Sentry } from "c/sentryMixin";

export default class BuggedLWC extends SentryMixin(
  LightningElement,
  "BuggedLWC"
) {
  connectedCallback() {
    // throw new Error("Some stupid thing happend");
    this[Sentry].log("connected");
  }

  handleClickThrow() {
    this[Sentry].log("here is a log");
    throw new Error("Some other stupid thing happend");
  }

  handleClickCaptureException() {
    this[Sentry].log("here is a log from the other button");
    this[Sentry].captureException(new Error("Some other stupid thing happend"));
  }
}
