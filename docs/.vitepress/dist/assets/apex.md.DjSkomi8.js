import { _ as i, P as a, m as e, p as n } from "./chunks/framework.CHRDgIrQ.js";
const g = JSON.parse(
    '{"title":"Usage in Apex","description":"","frontmatter":{},"headers":[],"relativePath":"apex.md","filePath":"apex.md"}'
  ),
  t = { name: "apex.md" };
function p(l, s, h, k, r, E) {
  return (
    a(),
    e("div", null, [
      ...(s[0] ||
        (s[0] = [
          n(
            `<h1 id="usage-in-apex" tabindex="-1">Usage in Apex <a class="header-anchor" href="#usage-in-apex" aria-label="Permalink to “Usage in Apex”">​</a></h1><p>In any class or trigger, you may use the following syntax.</p><div class="language-Apex"><button title="Copy Code" class="copy"></button><span class="lang">Apex</span><pre class="shiki shiki-themes github-light github-dark" style="--shiki-light:#24292e;--shiki-dark:#e1e4e8;--shiki-light-bg:#fff;--shiki-dark-bg:#24292e;" tabindex="0" dir="ltr"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">try</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">{</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    ...</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">}</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">catch</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Exception</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> e</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">){</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Sentry.</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">captureException</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(e);</span></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">    throw</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> e;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">}</span></span></code></pre></div>`,
            3
          )
        ]))
    ])
  );
}
const c = i(t, [["render", p]]);
export { g as __pageData, c as default };
