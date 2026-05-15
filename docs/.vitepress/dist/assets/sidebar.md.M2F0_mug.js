import { _ as e, P as l, m as t, p as i } from "./chunks/framework.CHRDgIrQ.js";
const c = JSON.parse(
    '{"title":"","description":"","frontmatter":{},"headers":[],"relativePath":"_sidebar.md","filePath":"_sidebar.md"}'
  ),
  r = { name: "_sidebar.md" };
function n(o, a, s, h, f, _) {
  return (
    l(),
    t("div", null, [
      ...(a[0] ||
        (a[0] = [
          i(
            '<ul><li><a href="/">Home</a></li><li><a href="./getStarted.html">Getting Started</a><ul><li><a href="./install.html">Installation</a></li><li><a href="./flows.html">Use in Flows</a></li><li><a href="./lwc.html">Use in LWC</a></li><li><a href="./apex.html">Use in Apex</a></li><li><a href="./view.html">View captured events</a></li></ul></li><li><a href="./configuration.html">Configuration</a><ul><li><a href="./user.html">User Integration</a></li><li><a href="./debug.html">Debug Logs Integration</a></li><li><a href="./stack.html">StackTrace Integration</a></li><li><a href="./flowFault.html">Flow Faults Integration</a></li><li><a href="./lwcError.html">LWC Errors Integration</a></li></ul></li><li><a href="./changelog.html">Changelog</a></li></ul>',
            1
          )
        ]))
    ])
  );
}
const d = e(r, [["render", n]]);
export { c as __pageData, d as default };
