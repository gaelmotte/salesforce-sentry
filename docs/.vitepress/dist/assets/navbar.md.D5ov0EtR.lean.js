import { _ as r, P as t, m as n, j as a } from "./chunks/framework.CHRDgIrQ.js";
const f = JSON.parse(
    '{"title":"","description":"","frontmatter":{},"headers":[],"relativePath":"_navbar.md","filePath":"_navbar.md"}'
  ),
  s = { name: "_navbar.md" };
function o(l, e, i, _, d, c) {
  return (
    t(),
    n("div", null, [
      ...(e[0] ||
        (e[0] = [
          a(
            "ul",
            null,
            [
              a("li", null, [a("a", { href: "/" }, "For Endusers")]),
              a("li", null, [a("a", { href: "/isv/" }, "For ISV")])
            ],
            -1
          )
        ]))
    ])
  );
}
const m = r(s, [["render", o]]);
export { f as __pageData, m as default };
