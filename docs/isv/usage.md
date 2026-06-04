# Using the SDK in Your Package

Once vendored and configured, instrumenting your package code works almost identically to the end-user SDK. The key difference is that there are no `sentrysdk.` prefixes — everything lives in your namespace.

## Apex

Wrap exception-prone code with `Sentry.captureException()`:

```apex
try {
    someService.doWork();
} catch (Exception e) {
    Sentry.captureException(e);
    throw e; // re-throw to preserve normal error handling
}
```

Add this to catch blocks in your triggers, service classes, and controllers wherever you want visibility in Sentry.

## Flows

In Flow Builder, search for **"Capture Sentry Event"** — the same element name as the end-user SDK. Drag it onto the canvas, connect it from the fault path of any monitored element, and set the **Error Message** input to `{!$Flow.FaultMessage}`.

```
Fault connector → Capture Sentry Event → existing error screen or fault handler
```

The element is available because the Flow action metadata was vendored into your package alongside the Apex classes.

## LWC

Two mixins are available: `SentryMixin` for leaf components and `SentryBoundaryMixin` for boundary components that catch child errors.

::: warning
The LWC import path needs verification against a scratch org before publishing. In managed packages, LWC module resolution may not require an explicit namespace prefix in the import statement. Confirm and update this section accordingly.
:::

**`SentryMixin`** — leaf components:

```js
import { LightningElement } from "lwc";
import { SentryMixin, Sentry } from "sentryMixin"; // verify import path

export default class MyComponent extends SentryMixin(
  LightningElement,
  "MyComponent"
) {
  handleClick() {
    this[Sentry].captureException(new Error("something went wrong"));
  }
}
```

**`SentryBoundaryMixin`** — boundary components:

```js
import { LightningElement } from "lwc";
import { SentryBoundaryMixin, Sentry, displayError } from "sentryMixin"; // verify import path

export default class ParentComponent extends SentryBoundaryMixin(
  LightningElement,
  "ParentComponent"
) {
  connectedCallback() {
    this[displayError] = (error) => {
      console.log(error);
    };
  }
}
```
