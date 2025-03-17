import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import logo from '@salesforce/resourceUrl/svglogo';
import basepath from '@salesforce/community/basePath';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import bw_termURL from '@salesforce/label/c.bw_termsURL';
import bw_privacyCenterURL from '@salesforce/label/c.bw_privacyCenterURL';
import bw_accessibilityStatementURL from '@salesforce/label/c.bw_accessibilityStatement';
import bw_californiaPrivacyNoticeURL from '@salesforce/label/c.bw_californiaPrivacyNoticeURL';
import bw_doNotSellURL from '@salesforce/label/c.bw_doNotSellURL';

export default class Bdw_footer extends NavigationMixin(LightningElement) {

    logosvg = logo;
    navelement;
    navurl;
    BasePath;
    termURL;
    privacyCenterURL;
    accessibilityStatementURL;
    californiaPrivacyNoticeURL;
    doNotSellURL;

    connectedCallback() {
        this.BasePath = basepath;
        this.termURL = bw_termURL;
        this.privacyCenterURL = bw_privacyCenterURL;
        this.accessibilityStatementURL = bw_accessibilityStatementURL;
        this.californiaPrivacyNoticeURL = bw_californiaPrivacyNoticeURL;
        this.doNotSellURL = bw_doNotSellURL;
    }

    handleClick() {
        this.navelement = "cookie settings";
        this.navurl = "javascript:void(0);";
        this.gtmEventNavBar();
        console.log("We are inside it");
        try {
            document.dispatchEvent(new CustomEvent('Bodewell_OneTrust_ToggleInfoDisplay', {
                detail: 'OneTrust'
            }), {
                bubbles: true,
                composed: true
            });
        } catch (ex) {
            console.error("Test Case error: ", ex);
        }
    }

    handleTerms(e)
    {
        this.navelement = "terms";
        this.navurl = e.target.dataset.value;
        this.gtmEventNavBar();
    }

    handlePrivacy(e)
    {
        this.navelement = "privacy";
        this.navurl = e.target.dataset.value;
        this.gtmEventNavBar();
    }

    handleAccessibility(e)
    {
        this.navelement = "accessibility";
        this.navurl = e.target.dataset.value;
        this.gtmEventNavBar();
    }

    handleCaliforniaPrivacy(e)
    {
        this.navelement = "California Privacy Notice";
        this.navurl = e.target.dataset.value;
        this.gtmEventNavBar();
    }

    handleDoNotSell(e)
    {
        this.navelement = "Do Not Sell or Share my Personal Information";
        this.navurl = e.target.dataset.value;
        this.gtmEventNavBar();
    }

    handleSiteMap() {
        this.navelement = "site map";
        this.navurl = this.BasePath + "/site-map/";
        this.gtmEventNavBar();
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Site_Map__c'
            },
            state: {}
        });
    }

    aboutUs() {
        this.navelement = "about";
        this.navurl = this.BasePath + "/about-us/";
        this.gtmEventNavBar();
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'About_Us__c'
            },
            state: {}
        });
    }

    gtmEventNavBar() {
        let gtmEventNavBarEvent = new CustomEvent(
            'gtm__navHeader', {
            detail: {
                navLocation: "footer",
                navElementText: this.navelement,
                navURL: this.navurl
            }
        });
        document.dispatchEvent(
            gtmEventNavBarEvent, {
            bubbles: true,
            composed: true
        });
    }
}