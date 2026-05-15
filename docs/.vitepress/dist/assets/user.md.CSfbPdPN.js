import { _ as e, P as a, m as r, p as n } from "./chunks/framework.DV4GPsGO.js";
const m = JSON.parse(
    '{"title":"UserIntegration","description":"","frontmatter":{},"headers":[],"relativePath":"user.md","filePath":"user.md"}'
  ),
  s = { name: "user.md" };
function i(l, t, d, o, c, h) {
  return (
    a(),
    r("div", null, [
      ...(t[0] ||
        (t[0] = [
          n(
            '<h1 id="userintegration" tabindex="-1">UserIntegration <a class="header-anchor" href="#userintegration" aria-label="Permalink to “UserIntegration”">​</a></h1><p>It enriches events with user details.</p><h2 id="parameters" tabindex="-1">Parameters <a class="header-anchor" href="#parameters" aria-label="Permalink to “Parameters”">​</a></h2><table tabindex="0"><thead><tr><th style="text-align:center;">position</th><th style="text-align:center;">type</th><th style="text-align:center;">default</th><th style="text-align:left;">effect</th></tr></thead><tbody><tr><td style="text-align:center;">1</td><td style="text-align:center;">Boolean</td><td style="text-align:center;">true</td><td style="text-align:left;">Enrich with assigned Profile and Permission sets</td></tr><tr><td style="text-align:center;">2</td><td style="text-align:center;">Boolean</td><td style="text-align:center;">false</td><td style="text-align:left;">Enrich with User PII (Firstname, Lastname, Email, isActive, languageLocaleKey, country)</td></tr></tbody></table><p>Note, The Organization ID and User Id are always sent to allow sentry to count how many users are impacted by a given issue.</p>',
            5
          )
        ]))
    ])
  );
}
const p = e(s, [["render", i]]);
export { m as __pageData, p as default };
