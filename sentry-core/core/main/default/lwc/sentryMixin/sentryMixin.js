import { ShowToastEvent } from "lightning/platformShowToastEvent";

function assertIsLightningElementSubclass(Base) {
  const baseProto = Base.prototype;

  if (typeof baseProto.dispatchEvent !== "function") {
    console.log("Base is not an Element type");

    // throw new TypeError(`${Base} must be an Element type`);
  }
}

const HandleError = Symbol("handleError");
const SentryBoundaryMixin = (Base) => {
  assertIsLightningElementSubclass(Base);
  return class extends Base {
    errorCallback(error, stack) {
      console.error(error);
      console.log(stack);

      if (this[HandleError]) {
        this[HandleError](error);
      } else {
        console.log("No error handler");
        const event = new ShowToastEvent({
          title: "An Error occured",
          message: error
        });
        this.dispatchEvent(event);
      }
    }
  };
};

export { SentryBoundaryMixin, HandleError };
