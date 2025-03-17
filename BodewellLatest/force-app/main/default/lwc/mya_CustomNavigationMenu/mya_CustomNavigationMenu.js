import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

// Templates
import Cafe from "./mya_CustomNavigationMenu_Cafe.html";
import GEA from "./mya_CustomNavigationMenu_GEA.html";
import Haier from "./mya_CustomNavigationMenu_Haier.html";

import getNavigationMenuItems from '@salesforce/apex/MYA_NavigationMenuItemsController.getNavigationMenuItems';
import isGuestUser from '@salesforce/user/isGuest';


export default class Mya_CustomNavigationMenu extends LightningElement {
    @api brand = 'GEA';
    /**
     * the menuName (NavigationMenuLinkSet.MasterLabel) exposed by the .js-meta.xml
     */
    @api menuName = 'MYA Menubar';
    @api mainMenu = 'MY Products';
    @api menuPath = 'My Appliance';

    /**
     * the menu items when fetched by the NavigationItemsController
     */
    @track menuItems = [];

    /**
     * if the items have been loaded
     */
    @track isLoaded = false;

    /**
     * the error if it occurs
     */
    @track error;

    /**
     * the published state of the site, used to determine from which schema to 
     * fetch the NavigationMenuItems
     */
    publishedState;
    myProductsUrl;
    parentMenuLink;
    menuPathItems = [];
    selectedItem = {};
    selectedItemLabel;
    selectedPageLabel;
    menuReady = false;



    // CSS loader function
    renderedCallback() {
            if (this.brand == "GEA") {

                // Promise.all([
                //     loadStyle(this, MYAGEACSS + '/MYAGEACSS/mya_NavigationMenu_GEA.css')
                // ]);
            } else if (this.brand == "Haier") {
                // Promise.all([
                //     loadStyle(this, MYAHAIERCSS + '/MYAHAIERCSS/mya_NavigationMenu_Haier.css')
                // ]);
            } else if (this.brand == "Cafe") {
                // Promise.all([
                //     loadStyle(this, MYACAFECSS + '/MYACAFECSS/mya_NavigationMenu_Cafe.css')
                // ]);
            }
            if (this.showaddressform && this.editRegistartion) {
                this.setEditValues();
            }
        }
        // UI render based on brand and user status
    render() {
        if (this.brand == "GEA") {
            return GEA;
        } else if (this.brand == "Haier") {
            return Haier;
        } else if (this.brand == "Cafe") {
            return Cafe;
        }
    }

    /**
     * Using a custom Apex controller, query for the NavigationMenuItems using the
     * menu name and published state.
     * 
     * The custom Apex controller is wired to provide reactive results. 
     */
    @wire(getNavigationMenuItems, {
        menuName: '$menuName',
        publishedState: 'Draft'
    })
    wiredMenuItems({ error, data }) {
        if (data && !this.isLoaded) {
            this.menuItems = data.map((item, index) => {
                return {
                    target: item.Target,
                    id: index,
                    label: item.Label,
                    defaultListViewId: item.DefaultListViewId,
                    type: item.Type,
                    accessRestriction: item.AccessRestriction
                }
            }).filter(item => {
                // Only show "Public" items if guest user
                return item.accessRestriction === "None" ||
                    (item.accessRestriction === "LoginRequired" && !isGuestUser);
            });
            this.error = undefined;
            this.isLoaded = true;
            this.setMenuPath(this.menuItems);
        } else if (error) {
            this.error = error;
            this.menuItems = [];
            this.isLoaded = true;
            console.log(`Navigation menu error: ${JSON.stringify(this.error)}`);
        }
    }


    /**
     * Using the CurrentPageReference, check if the app is 'commeditor'.
     * 
     * If the app is 'commeditor', then the page will use 'Draft' NavigationMenuItems. 
     * Otherwise, it will use the 'Live' schema.
     */
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        const app = currentPageReference && currentPageReference.state && currentPageReference.state.app;
        if (app === 'commeditor') {
            this.publishedState = 'Draft';
        } else {
            this.publishedState = 'Live';
        }
    }

    setMenuPath(menuItems) {
        debugger;
        if (menuItems.length > 0) {
            menuItems.forEach((item) => {
                if (item.label == this.mainMenu) {
                    this.selectedItem = item;
                    this.selectedItemLabel = item.label;
                    this.parentMenuLink = '/' + this.brand + '/s' + item.target;
                    item.isSelected = true;
                }             
                if (this.brand == "GEA" && item.label == 'My Products') {
                    this.myProductsUrl = '/GEA/s' + item.target;
                }
            }); 
            this.menuPathItems = this.menuPath.split("/");
            this.menuReady = true;
        }
    }
}