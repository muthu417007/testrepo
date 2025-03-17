import { LightningElement, wire, api } from 'lwc';
import iconphone from '@salesforce/resourceUrl/svgiconphone';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';


export default class Bw_ServiceAreaLocations extends NavigationMixin(LightningElement) {
    iconphonesvg = iconphone;
    @api serviceAreaName;
    @api serviceAreaNumber;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.serviceAreaName = currentPageReference.state.areaNam;
            this.serviceAreaNumber = currentPageReference.state.areaNo;
        }
    }

    mobileNumber(e) {
        var contactNumber = e.target.dataset.value;
        this.gtmEvent();
        window.location = "tel:" + contactNumber;
    }
    gtmEvent() {
        let contactUsCallEvent = new CustomEvent(
            'gtm__contactUsCall', {
            detail: {
                contact: this.serviceAreaName
            }
        });
        document.dispatchEvent(
            contactUsCallEvent, {
            bubbles: true,
            composed: true
        });
    }

    mobileNumberStrip(e){
        var contactNumber = e.target.dataset.value;
        this.gtmEventStrip();
        window.location = "tel:" + contactNumber;
    }
    gtmEventStrip() {
        let contactUsCallEvent = new CustomEvent(
            'gtm__contactUsCall', {
            detail: {
                contact: "Schedule a service online or call " + this.serviceAreaNumber + " today!"
            }
        });
        document.dispatchEvent(
            contactUsCallEvent, {
            bubbles: true,
            composed: true
        });
    }
}