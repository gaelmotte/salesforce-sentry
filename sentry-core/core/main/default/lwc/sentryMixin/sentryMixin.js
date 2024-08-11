import { ShowToastEvent } from "lightning/platformShowToastEvent";
import captureLWCError from "@salesforce/apex/Sentry.captureLWCError";

function assertIsLightningElementSubclass(Base) {
  const baseProto = Base.prototype;

  if (typeof baseProto.dispatchEvent !== "function") {
    console.log("Base is not an Element type");

    throw new TypeError(`${Base} must be an Element type`);
  }
}

const Sentry = Symbol("sentry");

/**
 * This mixin is intended for components that are NOT exposed.
 */
const SentryMixin = (Base, componentName) => {
  assertIsLightningElementSubclass(Base);

  return class extends Base {
    constructor() {
      super();
      this.template.addEventListener("sentry_error", (event) => {
        const errorEvent = new CustomEvent("sentry_error", {
          bubbles: true,
          detail: {
            ...event.detail,
            cmpStack: componentName + "\n" + event.detail.cmpStack
          }
        });
        this.dispatchEvent(errorEvent);
      });
    }

    [Sentry] = Object.freeze({
      log: (message) => {
        console.log(`Sentry: (${componentName}) ${message}`);
        const logEvent = new CustomEvent("sentry_log", {
          bubbles: true,
          detail: { message, componentName, timestamp: new Date() }
        });
        this.dispatchEvent(logEvent);
      },
      captureException: (error) => {
        const errorEvent = new CustomEvent("sentry_error", {
          bubbles: true,
          detail: {
            error: error.message,
            stack: error.stack,
            cmpStack: componentName,
            timestamp: new Date()
          }
        });
        this.dispatchEvent(errorEvent);
      }
    });
  };
};

/**
 * This mixin is intended for components that ARE exposed
 * Implement a `[displayError](error)` to display the error as you wish.
 * It is otherwise shown as a toast
 */
const displayError = Symbol("displayError");

const SentryBoundaryMixin = (Base, componentName) => {
  assertIsLightningElementSubclass(Base);

  return class extends SentryMixin(Base, componentName) {
    logs = [];

    constructor() {
      super();
      this.template.addEventListener("sentry_log", (event) => {
        console.log("SentryBoundary: ", event.detail.message);
        this.logs.push({ ...event.detail });
      });

      this.template.addEventListener("sentry_error", (event) => {
        const errorEvent = {
          ...event.detail,
          cmpStack: componentName + "\n" + event.detail.cmpStack,
          logs: this.logs
        };
        captureLWCError({ event: errorEvent }).then(() => {
          if (this[displayError]) {
            this[displayError](errorEvent.error);
          } else {
            // TODO : consider move over to a notification, so error in apex and flows may use a coherent display
            // TODO : consider taking some options as to how to display the error
            // TODO : consider overriding the render() method to display the error
            const toastEvent = new ShowToastEvent({
              title: "An Error occured",
              message: errorEvent.error,
              variant: "error",
              mode: "sticky"
            });
            this.dispatchEvent(toastEvent);
          }
        });
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
          logs: this.logs,
          timestamp: new Date()
        }
      }).then(() => {
        if (this[displayError]) {
          this[displayError](error);
        } else {
          // TODO : consider move over to a notification, so error in apex and flows may use a coherent display
          // TODO : consider taking some options as to how to display the error
          // TODO : consider overriding the render() method to display the error
          const toastEvent = new ShowToastEvent({
            title: "An Error occured",
            message: error.message,
            variant: "error",
            mode: "sticky"
          });
          this.dispatchEvent(toastEvent);
        }
      });
    }

    [Sentry] = Object.freeze({
      ...this[Sentry],
      log: (message) => {
        this.logs.push({ message, componentName, timestamp: new Date() });
      },
      captureException: (error) => {
        const errorEvent = {
          error: error.message,
          stack: error.stack,
          cmpStack: componentName,
          timestamp: new Date()
        };
        captureLWCError({ event: errorEvent }).then(() => {
          if (this[displayError]) {
            this[displayError](errorEvent.error);
          } else {
            // TODO : consider move over to a notification, so error in apex and flows may use a coherent display
            // TODO : consider taking some options as to how to display the error
            // TODO : consider overriding the render() method to display the error
            const toastEvent = new ShowToastEvent({
              title: "An Error occured",
              message: errorEvent.error,
              variant: "error",
              mode: "sticky"
            });
            this.dispatchEvent(toastEvent);
          }
        });
      }
    });
  };
};

export { SentryBoundaryMixin, SentryMixin, displayError, Sentry };
