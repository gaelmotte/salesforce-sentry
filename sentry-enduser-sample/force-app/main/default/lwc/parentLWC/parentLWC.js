import { LightningElement } from "lwc";
import { SentryBoundaryMixin, Sentry } from "c/sentryMixin";

export default class ParentLWC extends SentryBoundaryMixin(
  LightningElement,
  "ParentLWC"
) {
  showChild = false;

  handleClick() {
    this.showChild = !this.showChild;
    this[Sentry].log("show child");
  }

  // [HandleError](error){

  //     this.error = error;
  // }
  handleClickCaptureException() {
    this[Sentry].log("here is a log from the other button");
    this[Sentry].captureException(new Error("Some other stupid thing happend"));
  }
}
