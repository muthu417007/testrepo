// Purpose: For Headers
// Author: Akhil M R
// Modified By: Akhil M R
import { LightningElement, wire, api, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';

import getNavigationMenu from '@salesforce/apex/RG_NavigationMenuItemsController.getNavigationMenuItems';
import IsGuestUser from '@salesforce/user/isGuest';
import BasePath from '@salesforce/community/basePath';
import gealogo from '@salesforce/resourceUrl/GEAlogo';
import RG_ScheduleServiceLink from '@salesforce/label/c.RG_ScheduleServiceLink';
import RG_ServiceAreaPageTitle from '@salesforce/label/c.RG_Service_Area_Page_Title';
import RG_DefaultTollFree from '@salesforce/label/c.RG_Schedule_Call';
import RG_State_Page_Phone_Number from '@salesforce/label/c.RG_StatePagePhoneNumber';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubsub';

export default class RG_Header extends NavigationMixin(LightningElement) {

    communityData = {
        gealogo: gealogo,
        basepath: BasePath,
        isGuestUser: IsGuestUser
    };

    success = 'Not Available';
    tollfreenumber = RG_DefaultTollFree;
    tollfreelink = 'tel:' + RG_DefaultTollFree;
    formattedtollfreenumber;
    @api imageiconid;
    @api menuName;
    @api buttonlabel = 'SCHEDULE SERVICE';
    @api redirectionLink = 'https://genet.geappliances.com/eService/Service/productSelection?Login=Guest';
    @api buttonArea = 'header';

    @track menuItems = [];
    @track menuListItems = [];
    @track isLoaded = false;
    @track error;

    publishedState;
    redirectURL = '';
    connected = false;
    eventFired = false;
    location;

    @wire(CurrentPageReference) pageRef;

    @wire(getNavigationMenu, {
        menuName: '$menuName',
        publishedStatus: 'Draft'
    })
    wiredMenuItems({ error, data }) {
        if (data && !this.isLoaded) {
            if(data.success) {
                this.menuItems = data.result;
                this.menuListItems = data.result.map((item, index) => {
                    return {
                        id: index,
                        hasChild: item.hasChild,
                        isMenu: item.isMenu,
                        menuItemId: item.menuItemId,
                        menuItemName: item.menuItemName,
                        menuItemTarget: item.menuItemTarget,
                        subMenuItemList: item.subMenuItemList,
                        isServiceArea: (item.menuItemName == 'Service Areas') ? true : false
                    }
                });
                this.success = 'Success';
            }            
        } else if (error) {
            this.error = error;
            this.menuItems = [];
            this.success = 'Failed';
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

        if (currentPageReference.state.servicearea && !currentPageReference.state.localarea) {
            this.tollfreenumber = RG_State_Page_Phone_Number;
            this.tollfreelink = 'tel:' + this.tollfreenumber;
        }
        if (!currentPageReference.state.result) {
            this.pageViewEvent();
        }
    }

    connectedCallback() {
        this.connected = true;
        registerListener('localCityTollFreeNo', this.handleEvent, this);
        registerListener('serviceAreaEvent', this.handleServiceAreaEvent, this);
        registerListener('tollefreeEventCallBack', this.handleTollefreeEventCallBack, this);
        this.formattedtollfreenumber = this.tollfreenumber.replace(/\D+/g, "");
        if (this.formattedtollfreenumber) {
            window.addEventListener('_st_mln_ready', (e)=>{
                let dialogEvent = new CustomEvent(
                    "st_event", {
                    detail: {
                        phone: this.formattedtollfreenumber // need to pass 10 digit(8778882222) string format
                    }
                });
                document.dispatchEvent(dialogEvent, {
                    bubbles: true,
                    composed: true
                });
            });
            // To trigger the event Listener
            document.addEventListener('trackingNumberEvent', (e)=>{
                this.tollfreenumber = e.detail.value; 
                this.tollfreelink = 'tel:' + this.tollfreenumber;               
                fireEvent(this.pageRef, 'tollFreeNoEvent', this.tollfreenumber);
                console.log('DNI TollFree No: ', this.tollfreenumber);
            });
        }
    }

    handleEvent(inpVal) {
        this.tollfreenumber = inpVal;
        this.tollfreelink = 'tel:' + this.tollfreenumber;
        fireEvent(this.pageRef, 'tollFreeNoEvent', this.tollfreenumber);
    }

    handleTollefreeEventCallBack(e) {                
        sessionStorage.setItem('dni_value','true');
        fireEvent(this.pageRef, 'tollFreeNoEvent', this.tollfreenumber);        
        sessionStorage.removeItem('dni_value');
    }

    handleServiceAreaEvent(inp) {
        if(inp.localarea) {
            let titleLabel = RG_ServiceAreaPageTitle.split('{}');
            let localLOwer = inp.localarea.toLowerCase();
            let local = localLOwer[0].toUpperCase() + localLOwer.substring(1);
            let state = inp.state;
            document.title = titleLabel[0] + local + ',' + state + titleLabel[1];
            this.pageViewEvent();
        } else {
            let titleLabel = RG_ServiceAreaPageTitle.split('{}');
            let stateLOwer = inp.state.toLowerCase();
            let state = stateLOwer[0].toUpperCase() + stateLOwer.substring(1);
            document.title = titleLabel[0] + state + titleLabel[1];
            this.pageViewEvent();
        }
    }

    pageViewEvent() {
        if(!this.eventFired) {
            let pageViewEvent = new CustomEvent("gtm__pageView");
            document.dispatchEvent(pageViewEvent, {
                bubbles: true,
                composed: true
            });      
            this.eventFired = true;
        }  
    }

    //Method for handle navigation 
    handleNavigation(event) {
        try {
            this.redirectURL = this.communityData.basepath + event.target.dataset.value;
            let labelText;
            let selectedNav = this.menuListItems.filter(item => item.menuItemTarget == event.target.dataset.value);
            if(selectedNav.length > 0) {
                labelText = selectedNav[0].menuItemName;
            } else {
                this.menuListItems.forEach(element => {
                    if(element.subMenuItemList){
                        labelText = element.subMenuItemList.filter(item => item.subMenuItemTarget == event.target.dataset.value)[0].subMenuItemName;
                    }
                });
            }
            this.gtmNavigationEventFire(labelText,this.buttonArea,this.location.origin + this.redirectURL);
        } catch (ex) {
            console.error(ex);
        }
    }

    handleSchedule() {
        if (this.buttonlabel.toLowerCase().indexOf('schedule service') > -1) {
            let scheduleServiceEvent = new CustomEvent(
                "gtm__serviceSchedule", {
                detail: {
                    clickLocation: this.buttonArea
                }
            });
            document.dispatchEvent(scheduleServiceEvent, {
                bubbles: true,
                composed: true
            });
        }
    }

    handleCall() {
        let contactUsCallEvent = new CustomEvent(
            "gtm__contactUsCall", {
            detail: {
                contact: this.tollfreenumber,
                contactClickLocation: this.buttonArea
            }
        });
        document.dispatchEvent(contactUsCallEvent, {
            bubbles: true,
            composed: true
        });
    }

    handleHomeClick() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home',
            }
        });
    }

    gtmNavigationEventFire(elementText,location,url) {
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

    disconnectedCallback() {
        unregisterAllListeners(this);
    }
}