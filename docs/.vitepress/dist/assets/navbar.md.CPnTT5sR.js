import { _ as r, P as t, m as s, j as e } from "./chunks/framework.DV4GPsGO.js";
const p = JSON.parse(
    '{"title":"","description":"","frontmatter":{},"headers":[],"relativePath":"_navbar.md","filePath":"_navbar.md"}'
  ),
  n = { name: "_navbar.md" };
function o(l, a, c, i, _, d) {
  return (
    t(),
    s("div", null, [
      ...(a[0] ||
        (a[0] = [
          e(
            "ul",
            null,
            [
              e("li", null, [
                e("a", { href: "/salesforce-sentry/" }, "For Endusers")
              ]),
              e("li", null, [
                e("a", { href: "/salesforce-sentry/isv/" }, "For ISV")
              ])
            ],
            -1
          )
        ]))
    ])
  );
}
const m = r(n, [["render", o]]);
export { p as __pageData, m as default };
