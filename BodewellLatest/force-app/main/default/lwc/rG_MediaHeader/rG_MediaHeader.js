import { LightningElement, api, track, wire } from 'lwc';
import BasePath from '@salesforce/community/basePath';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import RG_DefaultTollFree from '@salesforce/label/c.RG_Schedule_Call';

export default class RG_MediaHeader extends NavigationMixin(LightningElement) {
    @api mediapagelogo;
    @api logo;
    @wire(CurrentPageReference) pageRef;
    @track tollfreenumber = RG_DefaultTollFree;
    tollfreelink;
    formattedtollfreenumber;
    eventFired = false;
    pageType = 'media';
    location;
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        if(!this.eventFired) {
            this.eventFired = true;
            this[NavigationMixin.GenerateUrl]({
                type: 'comm__namedPage',
                attributes: {
                    name: currentPageReference.attributes.name,
                }
            }).then(url => {
                this.location = location;
                let fullUrl = this.location.origin + url;
                // this.pageViewEvent(fullUrl, this.pageType);
            });
        }
    }

    connectedCallback() {
        registerListener('tollfreeEvent', this.handleEvent, this);
        if (this.mediapagelogo) {
            this.logo = BasePath + '/sfsites/c/cms/delivery/media/' + this.mediapagelogo;
        }
        if(this.tollfreenumber) {
            this.tollfreelink = 'tel:' + this.tollfreenumber;
        }        
    }

    handleEvent(inpVal) {
        this.tollfreenumber = inpVal;
        this.tollfreelink = 'tel:' + this.tollfreenumber;
    }

    handleSchedule() {
            let scheduleServiceEvent = new CustomEvent(
                "gtm__serviceSchedule", {
                detail: {
                    clickLocation: 'header'
                }
            });
            document.dispatchEvent(scheduleServiceEvent, {
                bubbles: true,
                composed: true
            });
    }

    handleCall() {
        let contactUsCallEvent = new CustomEvent(
            "gtm__contactUsCall", {
            detail: {
                contact: this.tollfreenumber,
                contactClickLocation: 'header'
            }
        });
        document.dispatchEvent(contactUsCallEvent, {
            bubbles: true,
            composed: true
        });
    }

    // pageViewEvent(url,pageType) {
    //     let pageViewEvent = new CustomEvent(
    //         "gtm__pageView", {
    //     });
    //     document.dispatchEvent(pageViewEvent, {
    //         bubbles: true,
    //         composed: true
    //     });
    // }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }
}