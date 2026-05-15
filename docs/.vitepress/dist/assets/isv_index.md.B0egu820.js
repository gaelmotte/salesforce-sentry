import { _ as r, P as a, m as t, p as o } from "./chunks/framework.DV4GPsGO.js";
const u = JSON.parse(
    '{"title":"Sentry SDK for ISVs","description":"","frontmatter":{},"headers":[],"relativePath":"isv/index.md","filePath":"isv/index.md"}'
  ),
  n = { name: "isv/index.md" };
function s(i, e, p, d, c, h) {
  return (
    a(),
    t("div", null, [
      ...(e[0] ||
        (e[0] = [
          o(
            '<h1 id="sentry-sdk-for-isvs" tabindex="-1">Sentry SDK for ISVs <a class="header-anchor" href="#sentry-sdk-for-isvs" aria-label="Permalink to “Sentry SDK for ISVs”">​</a></h1><p>If you&#39;re building a managed package and want to embed Sentry error tracking for your customers, ISV support is on the roadmap.</p><p>The planned approach is an npm package that wraps the SDK for use in your own packaging pipeline, so you can bundle Sentry reporting without requiring customers to install a separate managed package.</p><h2 id="current-workaround" tabindex="-1">Current workaround <a class="header-anchor" href="#current-workaround" aria-label="Permalink to “Current workaround”">​</a></h2><p>You can include the <code>sentry-core</code> source directly in your own package today. The core SDK has no external dependencies and is designed to be namespace-safe. Have a look at the <a href="https://github.com/gaelmotte/salesforce-sentry/" target="_blank" rel="noreferrer">source on GitHub</a> to evaluate whether this fits your use case.</p><h2 id="help-prioritize-this" tabindex="-1">Help prioritize this <a class="header-anchor" href="#help-prioritize-this" aria-label="Permalink to “Help prioritize this”">​</a></h2><p>If ISV support matters to you, <a href="https://github.com/gaelmotte/salesforce-sentry/issues" target="_blank" rel="noreferrer">open a GitHub issue</a> — it helps gauge demand and shapes the roadmap.</p>',
            7
          )
        ]))
    ])
  );
}
const f = r(n, [["render", s]]);
export { u as __pageData, f as default };
