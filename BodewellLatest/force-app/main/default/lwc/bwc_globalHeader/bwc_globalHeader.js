import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import BWC_UI from '@salesforce/resourceUrl/BodewellTheme';
import basePath from '@salesforce/community/basePath';
import FORM_FACTOR from "@salesforce/client/formFactor";


/**
 * @slot promotions
 * @slot multiNav
 */

export default class Bwc_globalHeader extends NavigationMixin(LightningElement) {
    
    deviceType;

    constructor() {
        super();
        sessionStorage.setItem('currentUserId', USER_ID);
    }

    BODEWELL_LOGO = BWC_UI + '/img/Bodewell-logo.png'

    get homeUrl() {
        return basePath;
    }
    
    /**
    * @description Controls whether the header is shown or not for easier drag and drop
    * @type {boolean}
    */
    @api toggleHeader;

    /**
    * @description Controls whether to have transparent background for header
    * @type {boolean}
    */
    @api hasBanner;

    /**
    * @description Controls whether to show promotion banner
    * @type {boolean}
    */
    @api hasPromo;

    get headerStyles() {
        return this.hasBanner ? 'global-header background-empty' : 'global-header background-fill';
    }
    get contentStyles() {
        return this.hasBanner ? 'header-content slds-grid slds-wrap' : 'header-content slds-grid slds-wrap background-fill';
    }
    get navigationStyles() {
        return this.hasBanner ? 'header-navigation slds-grid slds-grid_align-center' : 'header-navigation header-fill slds-grid slds-grid_align-center';
    }

   connectedCallback() {
        if (FORM_FACTOR === "Large") {
            this.deviceType = "Desktop/Laptop";
        } else if (FORM_FACTOR === "Medium") {
            this.deviceType = "Tablet";
        } else if (FORM_FACTOR === "Small") {
            this.deviceType = "Mobile";
        }
    }

    toggleMenu() {
        let mobileBtn = this.template.querySelector('.mobile-nav');
        let mobileNav = this.template.querySelector('.header-navigation');
        mobileBtn.classList.toggle('is-active');
        mobileNav.classList.toggle('is-active');
    }

    handleGoToServiceAreas() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Service_Areas__c'
            }
        });
    }

 
}