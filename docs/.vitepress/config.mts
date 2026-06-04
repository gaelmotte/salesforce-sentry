import { defineConfig } from "vitepress";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  base: "/salesforce-sentry",
  title: "Sentry SDK for Salesforce",
  description:
    "A much nicer way to be aware of issues on the Salesforce platform",
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    logo: "/SentrySDK.png",
    nav: [
      { text: "Home", link: "/" },
      { text: "ISV", link: "/isv/" },
      { text: "Changelog", link: "/changelog" },
      { text: "ISV Changelog", link: "/isv/changelog" }
    ],
    sidebar: {
      "/isv/": [
        {
          text: "Getting Started",
          items: [
            { text: "Overview", link: "/isv/" },
            { text: "Prerequisites", link: "/isv/prerequisites" },
            { text: "Initial Setup", link: "/isv/setup" }
          ]
        },
        {
          text: "Configuration",
          items: [
            { text: "Defining a Configuration", link: "/isv/configuration" },
            { text: "SentryISVContextIntegration", link: "/isv/isv-context" },
            { text: "User Integration", link: "/isv/user" },
            { text: "Stacktrace Integration", link: "/isv/stacktrace" },
            { text: "LWC Errors Integration", link: "/isv/lwc-errors" },
            { text: "Flow Faults Integration", link: "/isv/flow-faults" }
          ]
        },
        {
          text: "Adopt",
          items: [
            { text: "Using the SDK in Your Package", link: "/isv/usage" }
          ]
        },
        {
          text: "Upgrading",
          items: [
            { text: "Upgrading & Codemods", link: "/isv/upgrading" }
          ]
        },
        {
          text: "Architecture",
          items: [
            { text: "How It Works", link: "/how-it-works" }
          ]
        },
        {
          text: "Reference",
          items: [
            { text: "Troubleshooting & FAQ", link: "/isv/troubleshooting" },
            { text: "ISV Changelog", link: "/isv/changelog" }
          ]
        }
      ],
      "/": [
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
        },
        {
          text: "Architecture",
          items: [
            { text: "How it works", link: "/how-it-works" },
            { text: "Troubleshooting", link: "/troubleshooting" }
          ]
        }
      ]
    },

    socialLinks: [
      {
        icon: "github",
        link: "https://github.com/gaelmotte/salesforce-sentry/"
      }
    ]
  }
});
