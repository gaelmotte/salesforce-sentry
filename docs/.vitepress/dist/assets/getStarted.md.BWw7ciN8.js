import { _ as a, P as t, m as r, p as o } from "./chunks/framework.DV4GPsGO.js";
const u = JSON.parse(
    '{"title":"Prerequisites","description":"","frontmatter":{},"headers":[],"relativePath":"getStarted.md","filePath":"getStarted.md"}'
  ),
  n = { name: "getStarted.md" };
function i(s, e, l, d, c, h) {
  return (
    t(),
    r("div", null, [
      ...(e[0] ||
        (e[0] = [
          o(
            '<h1 id="prerequisites" tabindex="-1">Prerequisites <a class="header-anchor" href="#prerequisites" aria-label="Permalink to “Prerequisites”">​</a></h1><p>This will guide you through the standard setup of the SDK and its usage.</p><blockquote><p>If you want a deeper dive into what information is sent to Sentry when an issue is encountered, have a look at the <a href="./configuration.html">Configuration</a> guide.</p></blockquote><h2 id="sentry-project" tabindex="-1">Sentry Project <a class="header-anchor" href="#sentry-project" aria-label="Permalink to “Sentry Project”">​</a></h2><p>You already have a Sentry project and have its DSN close at hand.</p><h2 id="salesforce-edition" tabindex="-1">Salesforce Edition <a class="header-anchor" href="#salesforce-edition" aria-label="Permalink to “Salesforce Edition”">​</a></h2><p>You are on Salesforce Enterprise Edition or higher. (Platform Events, required for the async transport, are not available on lower editions.)</p><h2 id="yourself" tabindex="-1">Yourself <a class="header-anchor" href="#yourself" aria-label="Permalink to “Yourself”">​</a></h2><p>You are comfortable with Salesforce development: writing Apex classes and working with Custom Metadata Types.</p><h2 id="performance-governor-limits" tabindex="-1">Performance &amp; governor limits <a class="header-anchor" href="#performance-governor-limits" aria-label="Permalink to “Performance &amp; governor limits”">​</a></h2><p>The SDK is designed to be non-blocking. Errors are published as a Platform Event within your transaction (a lightweight DML operation), and all HTTP callouts to the Sentry API happen asynchronously in a separate Queueable context. Capturing an exception adds one Platform Event publish to your transaction — no synchronous HTTP callouts, no significant governor limit impact.</p>',
            11
          )
        ]))
    ])
  );
}
const f = a(n, [["render", i]]);
export { u as __pageData, f as default };
