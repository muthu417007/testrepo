import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/servicearea__c.Name';
import STATE_FIELD from '@salesforce/schema/servicearea__c.State__c';
import TOLL_FIELD from '@salesforce/schema/servicearea__c.Tollfree_Phone__c';
import getServiceAreaById from '@salesforce/apex/RG_ServiceAreasController.getServiceAreaById'
import CONTACT_LOGO from '@salesforce/resourceUrl/RG_IconContact';
import RG_Schedule_Call from '@salesforce/label/c.RG_Schedule_Call';
import ScheduleServiceLink from '@salesforce/label/c.RG_ScheduleServiceLink';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubsub';
import BasePath from '@salesforce/community/basePath';

export default class RG_ServiceAreaContent extends NavigationMixin(LightningElement) {

    urlParam = '';
    url;
    serviceArea;
    state;
    serviceState;
    hasState;
    isloop;
    contactLogo = CONTACT_LOGO;
    schedulePhone = RG_Schedule_Call;
    schedulePhoneLink = 'tel:' + RG_Schedule_Call;
    scheduleServiceLink = ScheduleServiceLink;
    hasPageLinkList = false;
    @track pageLinkList = [];
    @track localList = [];
    hasLocalArea = false;

    pageLinks = [
        {
            pageLabel: 'Refrigerator',
            pageApiName: 'Refrigerator_Resources__c'
        },
        {
            pageLabel: 'Oven/Range',
            pageApiName: 'Oven_Range_Resources__c'
        },
        {
            pageLabel: 'Dishwasher',
            pageApiName: 'Dishwasher_Resources__c'
        },
        {
            pageLabel: 'Dryer',
            pageApiName: 'Dryer_Resources__c'
        },
        {
            pageLabel: 'Washing Machine',
            pageApiName: 'Washing_Machine_Resources__c'
        },
        {
            pageLabel: 'Freezer',
            pageApiName: 'Freezer_Resources__c'
        }
    ];

    myBreadcrumbs = [
        {
            id: 'Home',
            label: 'Home',
            url: '/regea',
            isActive: false
        },
        {
            id: 'Service Areas',
            label: 'Service Areas',
            url: '/regea/service-areas',
            isActive: false
        }
    ];

    breadcrumbs = [];

    areaStack = [];

    localServiceAreaName;
    localServiceAreaPhone;
    localServiceAreaPhoneLink;
    localServiceAreaTollFreePhone;
    contentBody;
    stateAbbreviation;
    @api stateContentHeading = "FAST, RELIABLE APPLIANCE REPAIR";
    @api cityContentHeading = "EXPERT REPAIRS DONE RIGHT";

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        this.pageLinks.forEach((item, index) => {
            this[NavigationMixin.GenerateUrl]({
                type: 'comm__namedPage',
                attributes: {
                    name: item.pageApiName
                },
            }).then((url) => {
                this.hasPageLinkList = true;
                this.pageLinkList.push({
                    pageLabel: item.pageLabel,
                    pageApiName: item.pageApiName,
                    pageUrl: url
                });
                //console.log('this.pageLinkList: ', JSON.stringify(this.pageLinkList));
            });
        });                  
        document.addEventListener('load_url_event', (e) => {
            this.url = e.detail.value.split('/service-area/');
            this.urlParam = this.getUrlParamValue(this.url[1]);
            this.getServiceAreaById(this.urlParam);
        });      
        let urlEvent = new CustomEvent("get_url_event", {
            detail: {
                value: "get_url_event"
            }
        });
        document.dispatchEvent(urlEvent, {
            bubbles: true,
            composed: true
        });
    }

    getUrlParamValue(url) {
        // console.log('url param: ', url);
        if (url.indexOf('/') != -1) {
            return url.split('/')[0];
        } else {
            return url;
        }
    }

    getServiceAreaById(id) {
        getServiceAreaById({ objId: id })
            .then(result => {                
                this.localList = result.localAreaList;
                this.hasState = false;
                if(this.urlParam == result.serviceArea.Id && this.localList) {
                    this.hasLocalArea = (this.localList.length > 0) ? true : false;
                }
                if (!this.isloop) {
                    this.serviceArea = result.serviceArea.Name;
                    this.serviceState = result.serviceArea.Name;
                    this.areaStack.push({id:result.serviceArea.Name, label:result.serviceArea.Name, isActive: true, url: BasePath + '/service-area/' + result.serviceArea.Id + '/' + result.serviceArea.Name.replace(/\s+/g, '-').toLowerCase()});
                    if(!result.serviceArea.State__c) {
                        this.myBreadcrumbs = this.myBreadcrumbs.concat(this.areaStack);
                        this.breadcrumbs = this.myBreadcrumbs;
                    }
                    this.stateAbbreviation = result.serviceArea.State_Abbreviation__c ? result.serviceArea.State_Abbreviation__c : '';
                    this.localServiceAreaPhone = result.serviceArea.Local_Phone__c ? result.serviceArea.Local_Phone__c : '';
                    this.localServiceAreaPhoneLink = 'tel:' + this.localServiceAreaPhone;
                    this.contentBody = result.serviceArea.Side_Text__c ? result.serviceArea.Side_Text__c : '';
                    this.localServiceAreaTollFreePhone = result.serviceArea.Tollfree_Phone__c ? result.serviceArea.Tollfree_Phone__c : '';
                    fireEvent(this.pageRef, 'localCityTollFreeNo', this.localServiceAreaTollFreePhone);
                }
                if (result.serviceArea.State__c) {
                    this.isloop = true;
                    this.getServiceAreaById(result.serviceArea.State__c);
                }
                if (this.isloop && !result.serviceArea.State__c) {
                    this.state = result.serviceArea.Name;                    
                    this.serviceState = result.serviceArea.Name;
                    this.areaStack.push({id:result.serviceArea.Name, label:result.serviceArea.Name, isActive: false, url: BasePath + '/service-area/' + result.serviceArea.Id + '/' + result.serviceArea.Name.replace(/\s+/g, '-').toLowerCase()});
                    this.areaStack.reverse();
                    this.myBreadcrumbs = this.myBreadcrumbs.concat(this.areaStack);
                    this.breadcrumbs = this.myBreadcrumbs;
                    this.stateAbbreviation = result.serviceArea.State_Abbreviation__c ? result.serviceArea.State_Abbreviation__c : '';
                    this.hasState = true;
                }
            })
            .catch(error => {
                console.error(error);
                // console.log(JSON.stringify(error));
            });
    }

    handleCall() {
        let contactUsCallEvent = new CustomEvent(
            "gtm__contactUsCall", {
            detail: {
                contact: this.localServiceAreaPhone,
                contactClickLocation: 'body'
            }
        });
        document.dispatchEvent(contactUsCallEvent, {
            bubbles: true,
            composed: true
        });
    }

    handleScheduleOnline() {
        let scheduleServiceEvent = new CustomEvent(
            "gtm__serviceSchedule", {
            detail: {
                clickLocation: 'body'
            }
        });
        document.dispatchEvent(scheduleServiceEvent, {
            bubbles: true,
            composed: true
        });
    }

    handleResourceNavigation(event) {
        event.preventDefault();
        var navUrl = event.currentTarget.dataset.value;
        let reloadEvent = new CustomEvent(
            "rg_redirection", {
            detail: {
                url: navUrl
            }
        });
        document.dispatchEvent(reloadEvent, {
            bubbles: true,
            composed: true
        });
    }

    disableLink(event) {
        event.preventDefault();
    }
}