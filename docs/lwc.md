# Usage in LWC

Mixins are offered as a way to integrate with Sentry from LWC.

They come in two flavors:

- `SentryMixin` for leaf components
- `SentryBoundaryMixin` for boundary (aka exposed) components

## `SentryMixin`

Here's a minimal example

```js
import { LightningElement } from "lwc";
import { SentryMixin, Sentry } from "sentrysdk/sentryMixin";

export default class BuggedLWC extends SentryMixin(
  LightningElement,
  "BuggedLWC"
) {
  connectedCallback() {
    this[Sentry].log("connected");
  }

  handleClickThrow() {
    this[Sentry].log("here is a log");
    throw new Error("Some stupid thing happened");
  }

  handleClickCaptureException() {
    this[Sentry].log("here is a log from the other button");
    this[Sentry].captureException(
      new Error("Some other stupid thing happened")
    );
  }
}
```

### Constructor

The constructor takes two params :

- the element you are extending from. It should most likely be `LightningElement`, but it could be another mixin
- the name of the component. Sorry, you'll have to repeat yourself here.

### Methods

- `log`: captures a log that will appear as a breadcrumb in sentry. It won't be logged to the dev console in the browser.
- `captureException`: captures a JS error. You likely want to put that in a `catch` block :)

### Note

It is imperative that such a component be a child of a `SentryBoundaryMixin` component.

## `SentryBoundaryMixin`

This is a superset of `SentryMixin`

```js
import { LightningElement } from "lwc";
import { SentryBoundaryMixin, Sentry, displayError } from "sentrysdk/sentryMixin";

export default class ParentLWC extends SentryBoundaryMixin(
  LightningElement,
  "ParentLWC"
) {
    [...]
    //optional
    this[displayError] = (error)=>{
        console.log(error);
    }
}
```

### Constructor

The constructor takes two params :

- the element you are extending from. It should most likely be `LightningElement`, but it could be another mixin
- the name of the component. Sorry, you'll have to repeat yourself here.

### Methods

- `log`: captures a log that will appear as a breadcrumb in sentry. It won't be logged to the dev console in the browser.
- `captureException`: captures a JS error. You likely want to put that in a `catch` block :)

### Optional custom handling of error display

By default, the boundary component will display a toast with the error.
If you implement a `this[displayError]` callback, you are then free to display the error any way you'd like.
