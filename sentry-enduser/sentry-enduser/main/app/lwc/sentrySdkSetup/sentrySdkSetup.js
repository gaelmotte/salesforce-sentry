import { LightningElement, wire } from "lwc";
import { gql, graphql } from "lightning/graphql";
import { NavigationMixin } from "lightning/navigation";

export default class SentrySdkSetup extends NavigationMixin(LightningElement) {
  // wire the graphql adapater to fetch the custom metadata
  @wire(graphql, {
    query: gql`
      query SentryConfigs {
        uiapi {
          query {
            configs: sentrysdk__Sentry_Config__mdt(first: 50) {
              totalCount
              edges {
                node {
                  DeveloperName {
                    value
                  }
                  sentrysdk__DSN__c {
                    value
                  }
                  sentrysdk__ApexClass__c {
                    value
                  }
                  sentrysdk__Enabled__c {
                    value
                  }
                  sentrysdk__Sampling__c {
                    value
                  }
                }
              }
            }
          }
        }
      }
    `
  })
  configs;

  get configsJSON() {
    return JSON.stringify(this.configs);
  }

  get configsJSONPretty() {
    return JSON.stringify(this.configs, null, 2);
  }

  // get configs totalcouunt
  get configsTotalCount() {
    return this.configs?.data?.uiapi?.query?.configs?.totalCount ?? 0;
  }

  get zeroConfig() {
    return (
      this.configsTotalCount === 0 ||
      this.configs.data.uiapi.query.configs.edges.filter(
        (config) => config.node.sentrysdk__Enabled__c.value
      ).length === 0
    );
  }

  get oneConfig() {
    return (
      this.configsTotalCount === 1 ||
      this.configs.data.uiapi.query.configs.edges.filter(
        (config) => config.node.sentrysdk__Enabled__c.value
      ).length === 1
    );
  }

  // get first config
  get firstConfig() {
    if (this.configsTotalCount !== 1) {
      // filter the active ones
      const activeConfigs = this.configs.data.uiapi.query.configs.edges.filter(
        (config) => config.node.sentrysdk__Enabled__c.value
      );
      if (activeConfigs.length === 1) {
        return activeConfigs[0].node;
      }
      throw new Error("More than one active config found");
    }

    return this.configs.data.uiapi.query.configs.edges[0].node;
  }

  get isActive() {
    return (
      this.firstConfig.sentrysdk__DSN__c.value !== null &&
      this.firstConfig.sentrysdk__Enabled__c.value
    );
  }

  handleClick() {
    console.log("handleClick");
    console.log(this.configs);
    console.log(this.configsJSON);
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: "https://gaelmotte.github.io/salesforce-sentry/#/install"
      }
    });
  }
}
