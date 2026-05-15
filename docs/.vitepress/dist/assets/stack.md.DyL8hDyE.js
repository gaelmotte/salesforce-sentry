import { _ as e, P as a, m as n, p as r } from "./chunks/framework.DV4GPsGO.js";
const f = JSON.parse(
    '{"title":"StackTraceIntegration","description":"","frontmatter":{},"headers":[],"relativePath":"stack.md","filePath":"stack.md"}'
  ),
  l = { name: "stack.md" };
function s(i, t, c, d, o, h) {
  return (
    a(),
    n("div", null, [
      ...(t[0] ||
        (t[0] = [
          r(
            '<h1 id="stacktraceintegration" tabindex="-1">StackTraceIntegration <a class="header-anchor" href="#stacktraceintegration" aria-label="Permalink to “StackTraceIntegration”">​</a></h1><p>It enriches events with detais about the APEX stacktrace.</p><h2 id="parameters" tabindex="-1">Parameters <a class="header-anchor" href="#parameters" aria-label="Permalink to “Parameters”">​</a></h2><table tabindex="0"><thead><tr><th style="text-align:center;">position</th><th style="text-align:center;">type</th><th style="text-align:center;">default</th><th style="text-align:left;">effect</th></tr></thead><tbody><tr><td style="text-align:center;">1</td><td style="text-align:center;">Integer</td><td style="text-align:center;">5</td><td style="text-align:left;">Number of lines of code before and after the faulty line should be added as context</td></tr><tr><td style="text-align:center;">2</td><td style="text-align:center;">List&lt; SentryMechanismExceptionStrategy &gt;</td><td style="text-align:center;">[]</td><td style="text-align:left;">List of Strategies to enrich the exception with. Should you implement your own custom exception, this can help capture usefull data</td></tr><tr><td style="text-align:center;">3</td><td style="text-align:center;">class implements IInAppCallback</td><td style="text-align:center;">AllFramesInAppCallback</td><td style="text-align:left;">Callback to define what frames are <code>inApp</code></td></tr></tbody></table>',
            4
          )
        ]))
    ])
  );
}
const g = e(l, [["render", s]]);
export { f as __pageData, g as default };
