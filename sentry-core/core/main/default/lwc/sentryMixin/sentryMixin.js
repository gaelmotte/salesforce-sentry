import { ShowToastEvent } from "lightning/platformShowToastEvent";
import captureLWCError from "@salesforce/apex/Sentry.captureLWCError";
import { track } from "lwc";

function assertIsLightningElementSubclass(Base) {
  const baseProto = Base.prototype;

  if (typeof baseProto.dispatchEvent !== "function") {
    console.log("Base is not an Element type");

    // throw new TypeError(`${Base} must be an Element type`);
  }
}

/**
 * This mixin is intended for components that are NOT exposed.
 */
const SentryMixin = (Base, componentName) => {
  assertIsLightningElementSubclass(Base);

  return class extends Base {
    Sentry = Object.freeze({
      log: (message) => {
        console.log(`Sentry: (${componentName}) ${message}`);
        const logEvent = new CustomEvent("sentry_log", {
          bubbles: true,
          detail: { message, componentName, timestamp: new Date() }
        });

        // Dispatches the event.
        this.dispatchEvent(logEvent);
      }
    });
  };
};

/**
 * This mixin is intended for components that ARE exposed
 * Implement a `[HandleError](error)` to display the error as you wish.
 * It is otherwise shown as a toast
 */
const HandleError = Symbol("handleError");

const SentryBoundaryMixin = (Base, componentName) => {
  assertIsLightningElementSubclass(Base);

  return class extends SentryMixin(Base, componentName) {
    @track
    logs = [];

    constructor() {
      super();
      this.template.addEventListener("sentry_log", (event) => {
        console.log("SentryBoundary: ", event.detail.message);
        this.logs.push({ ...event.detail });
      });
    }

    errorCallback(error, stack) {
      // TODO identify if error commes from LDS for they do not have the same props
      // https://github.com/trailheadapps/lwc-recipes/blob/main/force-app/main/default/lwc/ldsUtils/ldsUtils.js

      captureLWCError({
        event: {
          error: error.message,
          stack: error.stack,
          cmpStack: stack,
          logs: this.logs
        }
      })
        .then(() => {
          // nothing to do ?
        })
        .catch((e) => {
          console.log(e);
          //TODO Handle cases were we failed to log to sentry
        })
        .finally(() => {
          if (this[HandleError]) {
            this[HandleError](error);
          } else {
            // TODO : consider move over to a notification, so error in apex and flows may use a coherent display
            // TODO : consider taking some options as to how to display the error
            // TODO : consider overriding the render() method to display the error
            const event = new ShowToastEvent({
              title: "An Error occured",
              message: error.message,
              variant: "error",
              mode: "sticky"
            });
            this.dispatchEvent(event);
          }
        });
    }
  };
};

export { SentryBoundaryMixin, SentryMixin, HandleError };
