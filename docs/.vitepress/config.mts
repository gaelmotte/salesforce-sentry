import { defineConfig } from "vitepress";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  base: "/salesforce-sentry",
  title: "Sentry SDK for Salesforce",
  description:
    "A much nicer way to be aware of issues on the Salesforce platform",
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    logo: "_media/SentrySDK.png",
    nav: [
      { text: "Home", link: "/" },
      { text: "ISV", link: "/isv/" },
      { text: "Changelog", link: "/changelog" }
    ],

    sidebar: [
      {
        text: "Getting Started",
        items: [
          { text: "Prerequisites", link: "/getStarted" },
          { text: "Installation", link: "/install" },
          { text: "Use in Flows", link: "/flows" },
          { text: "Use in LWC", link: "/lwc" },
          { text: "Use in Apex", link: "/apex" },
          { text: "View captured events", link: "/view" }
        ]
      },
      {
        text: "Configuration",
        items: [
          { text: "Defining a configuration", link: "/configuration" },
          { text: "User Integration", link: "/user" },
          { text: "Debug Logs Integration", link: "/debug" },
          { text: "StackTrace Integration", link: "/stack" },
          { text: "LWC Errors Integration", link: "/lwcError" },
          { text: "Flow Faults Integration", link: "/flowFault" }
        ]
      }
    ],

    socialLinks: [
      {
        icon: "github",
        link: "https://github.com/gaelmotte/salesforce-sentry/"
      }
    ]
  }
});
