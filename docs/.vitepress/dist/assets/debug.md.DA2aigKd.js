import { _ as e, P as a, m as n, p as r } from "./chunks/framework.DV4GPsGO.js";
const f = JSON.parse(
    '{"title":"DebugLogsIntegration","description":"","frontmatter":{},"headers":[],"relativePath":"debug.md","filePath":"debug.md"}'
  ),
  i = { name: "debug.md" };
function o(l, t, s, d, g, h) {
  return (
    a(),
    n("div", null, [
      ...(t[0] ||
        (t[0] = [
          r(
            '<h1 id="debuglogsintegration" tabindex="-1">DebugLogsIntegration <a class="header-anchor" href="#debuglogsintegration" aria-label="Permalink to “DebugLogsIntegration”">​</a></h1><p>It enriches events with info extracted from the debug logs.</p><p>This only works if the user has trace flags enabled. Good news is, it can add the traceflags for 24hours when an issue is caught for the user.</p><h2 id="parameters" tabindex="-1">Parameters <a class="header-anchor" href="#parameters" aria-label="Permalink to “Parameters”">​</a></h2><table tabindex="0"><thead><tr><th style="text-align:center;">position</th><th style="text-align:center;">type</th><th style="text-align:center;">default</th><th style="text-align:left;">effect</th></tr></thead><tbody><tr><td style="text-align:center;">1</td><td style="text-align:center;">Boolean</td><td style="text-align:center;">false</td><td style="text-align:left;">Should the SDK enable Trace Flags for the user when an error is caught</td></tr><tr><td style="text-align:center;">2</td><td style="text-align:center;">String</td><td style="text-align:center;"><code>Sentry_SDK_Tooling_Api_Credential</code></td><td style="text-align:left;">Name of the Named Credential to use to enable Trace Flags</td></tr></tbody></table><h2 id="additional-configuration" tabindex="-1">Additional configuration <a class="header-anchor" href="#additional-configuration" aria-label="Permalink to “Additional configuration”">​</a></h2><p>TODO List the steps to create a self named cred for the tooling api</p>',
            7
          )
        ]))
    ])
  );
}
const u = e(i, [["render", o]]);
export { f as __pageData, u as default };
