import { LightningElement } from 'lwc';
import getSiteConfiguration from '@salesforce/apex/PS_GEAIdPCustomerConfigHelper.getSiteConfiguration';
import getEnvironmentConfiguration from '@salesforce/apex/PS_GEAIdPEnvironmentConfigHelper.getEnvironmentConfiguration';

export default class Ps_GEAIdP_CommHeaderGenerator extends LightningElement {
    connectedCallback() {
        getSiteConfiguration().then(function (siteConfigData) {
            let siteConfig = siteConfigData;

            getEnvironmentConfiguration().then(function(environmentConfigData) {
                document.dispatchEvent(new CustomEvent("geaidm__configurationLoaded", {
                    bubbles: true,
                    composed: true,
                    detail: {
                        global: siteConfig,
                        local: environmentConfigData
                    }
                }));
            });
        }).catch(function(e) {
            console.error(e);
        });
    }
}