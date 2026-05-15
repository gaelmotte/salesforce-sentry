import {
  _ as a,
  P as t,
  m as o,
  p as n,
  d as i,
  g as s
} from "./chunks/framework.CHRDgIrQ.js";
const f = JSON.parse(
    '{"title":"Installation","description":"","frontmatter":{},"headers":[],"relativePath":"install.md","filePath":"install.md"}'
  ),
  r = { name: "install.md" };
function l(d, e, c, m, h, p) {
  return (
    t(),
    o("div", null, [
      ...(e[0] ||
        (e[0] = [
          n(
            '<h1 id="installation" tabindex="-1">Installation <a class="header-anchor" href="#installation" aria-label="Permalink to “Installation”">​</a></h1><h2 id="package-installation" tabindex="-1">Package installation <a class="header-anchor" href="#package-installation" aria-label="Permalink to “Package installation”">​</a></h2><p>Install this package with this <a href="https://login.salesforce.com/packaging/installPackage.apexp?p0=04tQy000000IjI1IAK" target="_blank" rel="noreferrer">link</a></p><h2 id="base-configuration" tabindex="-1">Base configuration <a class="header-anchor" href="#base-configuration" aria-label="Permalink to “Base configuration”">​</a></h2><h3 id="add-a-custom-metadata-record" tabindex="-1">Add a custom metadata record <a class="header-anchor" href="#add-a-custom-metadata-record" aria-label="Permalink to “Add a custom metadata record”">​</a></h3><p>In setup, search for <code>Custom Metadata Types</code><img src="' +
              i +
              '" alt="Custom Metadata List"></p><p>Click on <code>Manage Records</code> next to <code>Sentry Config</code>, then new. <img src="' +
              s +
              '" alt="Config Sample"></p><p>Note :</p><ul><li>you may have several records for this custom metadata but only one should be active</li><li>You may name those records anyway you like</li><li>DSN should be your Sentry project DSN</li><li>Apexclass must be a class implementing <code>ISentryConfig</code>, we provide <code>SentryEnduserDefaultConfig</code> as a default to help you get started.</li><li>Sampling must be between 0 and 100, defines what percentage of events are sent to sentry.</li></ul><h3 id="add-a-remote-site" tabindex="-1">Add a remote site <a class="header-anchor" href="#add-a-remote-site" aria-label="Permalink to “Add a remote site”">​</a></h3><p>In setup, search for <code>Remote Site Settings</code>, then click <code>New Remote Site</code>. Name it <code>Sentry</code> and for URL, it should be <code>https://o&lt;somenumber&gt;.ingest.sentry.io</code>. The ingest URL can be found from your DSN.</p>',
            11
          )
        ]))
    ])
  );
}
const g = a(r, [["render", l]]);
export { f as __pageData, g as default };
