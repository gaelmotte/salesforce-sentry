import { LightningElement } from "lwc";
import { SentryBoundaryMixin /*, HandleError*/ } from "c/sentryMixin";

export default class ParentLWC extends SentryBoundaryMixin(LightningElement) {
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
  }

  // [HandleError](error){

  //     this.error = error;
  // }
}
