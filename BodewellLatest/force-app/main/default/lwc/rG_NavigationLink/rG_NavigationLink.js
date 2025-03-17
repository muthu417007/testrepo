import { LightningElement, api } from 'lwc';
import BasePath from '@salesforce/community/basePath';

export default class RG_NavigationLink extends LightningElement {
    @api link;
    @api label;
    @api isServiceArea;
    basePath = BasePath;
    redirectLink;

    connectedCallback() { 
        this.redirectLink = this.basePath + this.link;
    }

    navClick(event) {
        event.preventDefault();
        this.gtmNavigationEventFire(this.label, this.redirectLink);
        let reloadEvent = new CustomEvent(
            "rg_redirection", {
            detail: {
              url: this.redirectLink
            }
          });
          document.dispatchEvent(reloadEvent, {
            bubbles: true,
            composed: true
          });
    }

    gtmNavigationEventFire(elementText,url) {
        let navigationEvent = new CustomEvent(
            "gtm__navigation", {
            detail: {
                navElementText: elementText,
                navLocation: 'header',
                navURL: url
            }
        });
        document.dispatchEvent(navigationEvent, {
            bubbles: true,
            composed: true
        });
    }
}