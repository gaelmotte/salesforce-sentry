import {
  _ as t,
  P as a,
  m as r,
  p as n,
  c as o,
  f as l,
  h as s
} from "./chunks/framework.DV4GPsGO.js";
const u = JSON.parse(
    '{"title":"Usage in Flows","description":"","frontmatter":{},"headers":[],"relativePath":"flows.md","filePath":"flows.md"}'
  ),
  i = { name: "flows.md" };
function h(p, e, d, c, m, g) {
  return (
    a(),
    r("div", null, [
      ...(e[0] ||
        (e[0] = [
          n(
            '<h1 id="usage-in-flows" tabindex="-1">Usage in Flows <a class="header-anchor" href="#usage-in-flows" aria-label="Permalink to “Usage in Flows”">​</a></h1><h2 id="sample-existing-flow" tabindex="-1">Sample existing flow <a class="header-anchor" href="#sample-existing-flow" aria-label="Permalink to “Sample existing flow”">​</a></h2><p>In this example, we will track issues that could occur in a custom lead conversion flow.</p><p>Your flow should already have a fault path that routes errors to a screen or message element — Sentry reporting hooks into that same path.</p><p><img src="' +
              o +
              '" alt="Existing Flow"></p><h2 id="adding-a-sentry-element" tabindex="-1">Adding a Sentry element <a class="header-anchor" href="#adding-a-sentry-element" aria-label="Permalink to “Adding a Sentry element”">​</a></h2><p>In the Flow Builder palette, search for <strong>Capture Sentry Event</strong>. Drag it onto the canvas and connect it from the fault path of any element you want to monitor.</p><p><img src="' +
              l +
              '" alt="Adding the element"></p><h2 id="configuring-the-element" tabindex="-1">Configuring the element <a class="header-anchor" href="#configuring-the-element" aria-label="Permalink to “Configuring the element”">​</a></h2><p>Set the <strong>Error Message</strong> input to the fault variable you want to capture (typically <code>{!$Flow.FaultMessage}</code>). The element will serialize the fault context and send it to Sentry automatically.</p><p><img src="' +
              s +
              '" alt="Configuring the element"></p><p>After adding the Sentry element, your fault path should look like:</p><ol><li><strong>Fault connector</strong> → Sentry element (captures the error)</li><li>Sentry element → your existing error screen / toast element (shows the error to the user)</li></ol><p>This way, errors are both reported to Sentry and surfaced to the user.</p>',
            14
          )
        ]))
    ])
  );
}
const _ = t(i, [["render", h]]);
export { u as __pageData, _ as default };
