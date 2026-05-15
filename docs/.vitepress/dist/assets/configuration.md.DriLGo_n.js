import { _ as i, P as a, m as t, p as n } from "./chunks/framework.CHRDgIrQ.js";
const g = JSON.parse(
    '{"title":"Advanced Configuration","description":"","frontmatter":{},"headers":[],"relativePath":"configuration.md","filePath":"configuration.md"}'
  ),
  e = { name: "configuration.md" };
function h(l, s, r, p, k, o) {
  return (
    a(),
    t("div", null, [
      ...(s[0] ||
        (s[0] = [
          n(
            `<h1 id="advanced-configuration" tabindex="-1">Advanced Configuration <a class="header-anchor" href="#advanced-configuration" aria-label="Permalink to “Advanced Configuration”">​</a></h1><p>You already have seen in <a href="./getStarted.html">Getting Started</a> how part of the configuration is made through a custom metadata.</p><p>In the following, you will see how to create a configuration class for finer settings.</p><h2 id="create-a-configuration-class" tabindex="-1">Create a configuration class <a class="header-anchor" href="#create-a-configuration-class" aria-label="Permalink to “Create a configuration class”">​</a></h2><p>Using your usual dev workflow, crate a new class for the Sentry SDK config.</p><p>It must read like this :</p><div class="language-apex"><button title="Copy Code" class="copy"></button><span class="lang">apex</span><pre class="shiki shiki-themes github-light github-dark" style="--shiki-light:#24292e;--shiki-dark:#e1e4e8;--shiki-light-bg:#fff;--shiki-dark-bg:#24292e;" tabindex="0" dir="ltr"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">public</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> with sharing </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">class</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> MySentryConfig</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> extends</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> Sentrysdk__SentryConfig</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> {</span></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">  public</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> virtual</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> override</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> List</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">&lt;</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">ISentryIntegration</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">&gt; </span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">getIntegrations</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">() {</span></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">    return</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> new</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> List</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">&lt;</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">ISentryIntegration</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">&gt;{</span></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">      new</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> SentryUserIntegration</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">true</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, </span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">true</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">), </span><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;">// capture user PII, which is not default</span></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">      new</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> SentryDebugLogsIntegration</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(), </span><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;">// all de defaults</span></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">      new</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> SentryStacktraceIntegration</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(), </span><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;">// all the defaults,</span></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">      new</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> SentryFlowFaultIntegration</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(),</span></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">      new</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> SentryLWCErrorIntegration</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">()</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    };</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  }</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">}</span></span></code></pre></div><p>What you should pay attention to :</p><ul><li>The classname : Name it anyway you like, but keep it somewhere because it will be used in the custom metadata</li><li><code>extends SentryConfig</code>: Your class must extend this.</li><li>List of integrations with their parameters.</li></ul><h2 id="integrations-you-say" tabindex="-1">Integrations you say ? <a class="header-anchor" href="#integrations-you-say" aria-label="Permalink to “Integrations you say ?”">​</a></h2><p>Yes, Integrations represent a group of actions to enrich an event.</p><p>Some are built into the product and are listed in the next page. You may develop your own to scrub certain data away, or filter what events are sent to sentry.</p>`,
            12
          )
        ]))
    ])
  );
}
const c = i(e, [["render", h]]);
export { g as __pageData, c as default };
