---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: "Sentry SDK for Salesforce"
  text: "Salesforce has no global exception handler. Now it does."
  tagline: "When Apex throws, a Flow faults, or an LWC crashes in production — you'll know. Sentry SDK routes errors to your Sentry project in real time, with stack traces, user context, and breadcrumbs."
  actions:
    - theme: brand
      text: Get Started
      link: /getStarted
    - theme: alt
      text: Install v0.5
      link: https://login.salesforce.com/packaging/installPackage.apexp?p0=04tQy000000VcSPIA0

features:
  - title: One-click managed package & CLI for quick adoption
    details: Install from AppExchange in minutes. Use the `@salesforce-sentry/codemods` CLI to generate config files, instrument your codebase, and validate the setup — without touching a single file by hand.
  - title: Apex, Flow, and LWC coverage
    details: Capture exceptions in Apex triggers and classes, fault paths in Flows, and unhandled errors in Lightning Web Components — all routed to the same Sentry project.
  - title: Fully configurable
    details: Control sampling rate, filter PII, enrich events with user identity, and extend with custom integrations via a simple Apex interface.
---
