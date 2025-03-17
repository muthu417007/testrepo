import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

//import custom labels
import RG_Terms from '@salesforce/label/c.RG_Terms';
import RG_Privacy from '@salesforce/label/c.RG_Privacy';
import RG_California_Privacy_Notice from '@salesforce/label/c.RG_California_Privacy_Notice';
import RG_Cookie_Settings from '@salesforce/label/c.RG_Cookie_Settings';
import RG_Sitemap from '@salesforce/label/c.RG_Sitemap';
import RG_FAQ from '@salesforce/label/c.RG_FAQ';
import RG_Do_Not_Sell_or_Share_My_Personal_Information from '@salesforce/label/c.RG_Do_Not_Sell_or_Share_My_Personal_Information';
import RG_Accessibility from '@salesforce/label/c.RG_Accessibility';
import RG_aboutGe from '@salesforce/label/c.RG_aboutGe';
import BasePath from '@salesforce/community/basePath';

import getNavigationMenu from '@salesforce/apex/RG_NavigationMenuItemsController.getNavigationMenuItems';

export default class RG_Footer extends NavigationMixin(LightningElement) {

    @api label = {
        RG_California_Privacy_Notice,
        RG_Terms,
        RG_Privacy,
        RG_FAQ,
        RG_Sitemap,
        RG_Cookie_Settings,
        RG_Do_Not_Sell_or_Share_My_Personal_Information,
        RG_Accessibility,
        RG_aboutGe

    };

    @api termLink;
    @api privacyLink;
    @api privacyNoticeLink;
    @api consentLink;
    @api cookieLink;
    @api accessibilityLink;
    @api faqLink;
    @api sitemapLink;
    @api aboutGeLink;

    @api copyRightLabel;
    @api tradeMark;
    @api lic;
    @api cookie;
    @api sectionId;
    @api menuName;

    navArea = 'footer';

    @track menuItems = [];
    @track menuListItems = [];
    @track isLoaded = false;
    @track error;

    @wire(getNavigationMenu, {
        menuName: '$menuName',
        publishedStatus: 'Draft'
    })
    wiredMenuItems({ error, data }) {
        if (data && !this.isLoaded) {
            if (data.success) {
                this.menuItems = data.result;
                this.menuListItems = data.result.map((item, index) => {
                    return {
                        id: index,
                        hasChild: item.hasChild,
                        isMenu: item.isMenu,
                        menuItemId: item.menuItemId,
                        menuItemName: item.menuItemName,
                        menuItemTarget: item.menuItemTarget,
                        isServiceArea: false,
                        type: item.menuItemType,
                        isExternalLink: (item.menuItemType == 'ExternalLink') ? true : false,
                        isCookieSettings: (item.menuItemName == 'Cookie Settings') ? true : false
                    }
                });
                this.success = 'Success';
            }
            console.log(`Navigation Menu List: ${JSON.stringify(this.menuListItems)}`);
            //this.setLinks(this.menuListItems);          
        } else if (error) {
            this.error = error;
            this.menuItems = [];
            console.log(`Navigation menu error: ${JSON.stringify(this.error)}`);
            this.success = 'Failed';
        }
    }

    setLinks(data) {
        if (data.length > 0) {
            data.forEach(element => {
                if (element.menuItemName == this.label.RG_Terms) {
                    this.termLink = element.menuItemTarget;
                }
                if (element.menuItemName == this.label.RG_Privacy) {
                    this.privacyLink = element.menuItemTarget;
                }
                if (element.menuItemName == this.label.RG_California_Privacy_Notice) {
                    this.privacyNoticeLink = element.menuItemTarget;
                }
                if (element.menuItemName == this.label.RG_Sitemap) {
                    this.sitemapLink = BasePath + element.menuItemTarget;
                }
                if (element.menuItemName == this.label.RG_Do_Not_Sell_or_Share_My_Personal_Information) {
                    this.consentLink = element.menuItemTarget;
                }
                if (element.menuItemName == this.label.RG_Accessibility) {
                    this.accessibilityLink = element.menuItemTarget;
                }
                if (element.menuItemName == this.label.RG_FAQ) {
                    this.faqLink = BasePath + element.menuItemTarget;
                }

            });
        }
    }

    renderedCallback() {
        this.template.querySelector('.overview-nav-section').setAttribute('id', this.sectionId);
    }

    handleCookies(event) {
        console.log("We are inside it");
        try {
            document.dispatchEvent(new CustomEvent('REGEA_OneTrust_ToggleInfoDisplay', {
                detail: 'OneTrust'
            }), {
                bubbles: true,
                composed: true
            });
        } catch (ex) {
            console.error("Test Case error: ", ex);
        }
    }

    // handleSitemap() {
    //     this[NavigationMixin.GenerateUrl]({
    //         type: 'comm__namedPage',
    //         attributes: {
    //             name: 'Sitemap__c',
    //         }
    //     }).then(url => {
    //         let fullUrl = location.origin + url;
    //         this.gtmNavigationEventFire(this.label.RG_Sitemap, this.navArea,fullUrl);
    //         let reloadEvent = new CustomEvent(
    //             "rg_redirection", {
    //             detail: {
    //               url: url
    //             }
    //           });
    //           document.dispatchEvent(reloadEvent, {
    //             bubbles: true,
    //             composed: true
    //           });
    //     });
    // }

    // handleFAQ() {        
    //     this[NavigationMixin.GenerateUrl]({
    //         type: 'comm__namedPage',
    //         attributes: {
    //             name: 'FAQ__c',
    //         }
    //     }).then(url => {
    //         let fullUrl = location.origin + url;
    //         this.gtmNavigationEventFire(this.label.RG_FAQ, this.navArea, fullUrl);
    //         let reloadEvent = new CustomEvent(
    //             "rg_redirection", {
    //             detail: {
    //               url: url
    //             }
    //           });
    //           document.dispatchEvent(reloadEvent, {
    //             bubbles: true,
    //             composed: true
    //           });
    //     });
    // }

    handleNavigation(event) {
        if (event.currentTarget.dataset.value == this.label.RG_Terms) {
            this.gtmNavigationEventFire(this.label.RG_Terms, this.navArea, this.termLink);
        }
        if (event.currentTarget.dataset.value == this.label.RG_Privacy) {
            this.gtmNavigationEventFire(this.label.RG_Privacy, this.navArea, this.privacyLink);
        }
        if (event.currentTarget.dataset.value == this.label.RG_California_Privacy_Notice) {
            this.gtmNavigationEventFire(this.label.RG_California_Privacy_Notice, this.navArea, this.privacyNoticeLink);
        }
        if (event.currentTarget.dataset.value == this.label.RG_Sitemap) {
            event.preventDefault();
            this.gtmNavigationEventFire(this.label.RG_Sitemap, this.navArea, location.origin + this.sitemapLink);
            this.handleRedirection(this.sitemapLink);
        }
        if (event.currentTarget.dataset.value == this.label.RG_Do_Not_Sell_or_Share_My_Personal_Information) {
            this.gtmNavigationEventFire(this.label.RG_Do_Not_Sell_or_Share_My_Personal_Information, this.navArea, this.consentLink);
        }
        if (event.currentTarget.dataset.value == this.label.RG_Accessibility) {
            this.gtmNavigationEventFire(this.label.RG_Accessibility, this.navArea, this.accessibilityLink);
        }
        if (event.currentTarget.dataset.value == this.label.RG_FAQ) {
            event.preventDefault();
            this.gtmNavigationEventFire(this.label.RG_FAQ, this.navArea, location.origin + this.faqLink);
            this.handleRedirection(this.faqLink);
        }
        if (event.currentTarget.dataset.value == this.label.RG_aboutGe) {
            this.gtmNavigationEventFire(this.label.RG_aboutGe, this.navArea, this.aboutGeLink);
        }
    }

    gtmNavigationEventFire(elementText, location, url) {
        let navigationEvent = new CustomEvent(
            "gtm__navigation", {
            detail: {
                navElementText: elementText,
                navLocation: location,
                navURL: url
            }
        });
        document.dispatchEvent(navigationEvent, {
            bubbles: true,
            composed: true
        });
    }

    handleRedirection(link) {
        let reloadEvent = new CustomEvent(
            "rg_redirection", {
            detail: {
                url: link
            }
        });
        document.dispatchEvent(reloadEvent, {
            bubbles: true,
            composed: true
        });
    }
}