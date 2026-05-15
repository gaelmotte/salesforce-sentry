import { _ as i, P as a, m as e, p as n } from "./chunks/framework.DV4GPsGO.js";
const E = JSON.parse(
    '{"title":"Usage in Apex","description":"","frontmatter":{},"headers":[],"relativePath":"apex.md","filePath":"apex.md"}'
  ),
  t = { name: "apex.md" };
function h(l, s, p, r, k, d) {
  return (
    a(),
    e("div", null, [
      ...(s[0] ||
        (s[0] = [
          n(
            `<h1 id="usage-in-apex" tabindex="-1">Usage in Apex <a class="header-anchor" href="#usage-in-apex" aria-label="Permalink to “Usage in Apex”">​</a></h1><p>Wrap any code that may throw with a try/catch and call <code>Sentry.captureException()</code>. The error is reported to Sentry and you can re-throw to preserve normal error handling.</p><h2 id="basic-example" tabindex="-1">Basic example <a class="header-anchor" href="#basic-example" aria-label="Permalink to “Basic example”">​</a></h2><div class="language-apex"><button title="Copy Code" class="copy"></button><span class="lang">apex</span><pre class="shiki shiki-themes github-light github-dark" style="--shiki-light:#24292e;--shiki-dark:#e1e4e8;--shiki-light-bg:#fff;--shiki-dark-bg:#24292e;" tabindex="0" dir="ltr"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">try</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> {</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    someService.</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">doWork</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">();</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">} </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">catch</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> (</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Exception</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> e</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">) {</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Sentry.</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">captureException</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(e);</span></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">    throw</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> e;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">}</span></span></code></pre></div><h2 id="realistic-example-—-a-trigger-handler" tabindex="-1">Realistic example — a trigger handler <a class="header-anchor" href="#realistic-example-—-a-trigger-handler" aria-label="Permalink to “Realistic example — a trigger handler”">​</a></h2><div class="language-apex"><button title="Copy Code" class="copy"></button><span class="lang">apex</span><pre class="shiki shiki-themes github-light github-dark" style="--shiki-light:#24292e;--shiki-dark:#e1e4e8;--shiki-light-bg:#fff;--shiki-dark-bg:#24292e;" tabindex="0" dir="ltr"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">public</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> with sharing </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">class</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> AccountTriggerHandler</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> {</span></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">    public</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> static</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> void</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> afterInsert</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">List</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">&lt;</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">Account</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">&gt; </span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">newAccounts</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">) {</span></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">        try</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> {</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">            ExternalSyncService.</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">sync</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(newAccounts);</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        } </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">catch</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> (</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Exception</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> e</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">) {</span></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;">            // Report to Sentry, then fail gracefully so other trigger handlers can continue</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">            Sentry.</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">captureException</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(e);</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        }</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    }</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">}</span></span></code></pre></div><h2 id="adding-user-context" tabindex="-1">Adding user context <a class="header-anchor" href="#adding-user-context" aria-label="Permalink to “Adding user context”">​</a></h2><p>If you want the Sentry event to include the current user&#39;s identity, enable the <code>SentryUserIntegration</code> in your <a href="./configuration.html">configuration</a>. No extra code is required at the call site — the integration runs automatically on every captured event.</p><h2 id="sampling" tabindex="-1">Sampling <a class="header-anchor" href="#sampling" aria-label="Permalink to “Sampling”">​</a></h2><p>You can control what percentage of events are forwarded to Sentry via the <code>Sampling</code> field on the <code>Sentry Config</code> custom metadata record (0–100). This is useful for high-volume orgs where you want representative coverage without overwhelming your Sentry quota.</p>`,
            10
          )
        ]))
    ])
  );
}
const o = i(t, [["render", h]]);
export { E as __pageData, o as default };
