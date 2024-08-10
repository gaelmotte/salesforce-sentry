import { LightningElement } from "lwc";
import { SentryBoundaryMixin, Sentry } from "c/sentryMixin";

export default class ParentLWC extends SentryBoundaryMixin(
  LightningElement,
  "ParentLWC"
) {
  showChild = false;
  error;

  getCause() {
    return this.error.cause;
  }

  getStack() {
    return this.error.stack;
  }

  handleClick() {
    this.showChild = !this.showChild;
    this[Sentry].log("show child");
  }

  // [HandleError](error){

  //     this.error = error;
  // }
}
