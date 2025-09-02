/*
 * REPLACEMENT TO MAKE IT EEASIER TO UUNSTALL THE PACKAGE
 *
 */

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
    [Sentry] = Object.freeze({
      log: (message) => {
        console.log(`Sentry: (${componentName}) ${message}`);
      },
      captureException: (error) => {
        console.log(`Sentry: (${error})`);
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
    errorCallback(error, stack) {
      console.log(`Sentry: (${error}) ${stack}`);
    }

    [Sentry] = Object.freeze({
      ...this[Sentry],
      log: (message) => {
        console.log(`Sentry: (${componentName}) ${message}`);
      },
      captureException: (error) => {
        console.log(`Sentry: (${error})`);
      }
    });
  };
};

export { SentryBoundaryMixin, SentryMixin, displayError, Sentry };
