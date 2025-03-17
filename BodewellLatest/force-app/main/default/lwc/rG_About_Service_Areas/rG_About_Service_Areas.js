import { LightningElement, api, wire } from 'lwc';
import netStyles from '@salesforce/resourceUrl/RG_StyleSheet';
import { loadStyle } from 'lightning/platformResourceLoader';
import basepath from '@salesforce/community/basePath';
export default class RG_About_Service_Areas extends LightningElement {
    @api contentHeading;
    @api content;
    @api sectionId = 'Service Area';
    @api buttonLabel = 'View service Areas';
    @api redirectionLink;
    @api navigationtype;
    redirectURL;
    isExpand = true;
    BasePath = basepath;

    connectedCallback() {
        if (this.navigationtype == 'Site Page') {
            this.redirectURL = this.BasePath + this.redirectionLink;
        }
        else if (this.navigationtype == 'External Link') {
            this.redirectURL = this.redirectionLink;
        }
    }

    renderedCallback() {
        this.template.querySelector('h2').setAttribute('id', this.sectionId);
        Promise.all([
            loadStyle(this, netStyles)
        ])
    }

    showAll() {
        if (this.isExpand == false) {
            this.isExpand = true;
        } else if (this.isExpand == true) {
            this.isExpand = false;
        }
    }

    handleClick(e) {
        if (this.navigationtype == 'Site Page') {
            e.preventDefault();
            let reloadEvent = new CustomEvent(
                "rg_redirection", {
                detail: {
                    url: this.redirectURL
                }
            });
            document.dispatchEvent(reloadEvent, {
                bubbles: true,
                composed: true
            });
        }
    }
}