import { LightningElement, track, wire, api } from 'lwc';
import getServiceLocations from '@salesforce/apex/BDW_serviceAreaController.getServiceArea';
import locationpin from '@salesforce/resourceUrl/svglocationpin';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

export default class Bw_serviceAreas extends NavigationMixin(LightningElement) {
    @track serviceAreaLocations;
    @track retailAreaLocations;
    locationpinsvg = locationpin;
    @api serviceAreaNumber;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.serviceAreaName = currentPageReference.state.areaNam;
            this.serviceAreaNumber = currentPageReference.state.areaNo;
        }
    }

    connectedCallback() {
        getServiceLocations({})
            .then(result => {
                this.serviceAreaLocations = result;
                console.log('Service Locations ' + JSON.stringify(result));
            })
            .catch(error => {
                console.log(error);
            });
    }

    areaName;
    areaNumber;
    mobileNumber(e) {
        var rid = e.target.dataset.value;  
        this.serviceAreaLocations.forEach((item, index) => {
            if (item.Id == rid) {
                this.areaName = item.Service_Area_Name__c;
                this.areaNumber = item.Service_Area_Number__c;
            }
        });
        this.gtmEvent();
        window.location = "tel:" + this.areaNumber;
    }

    handleServiceLocation(e) {
        var rid = e.target.dataset.value;
        var areaName;
        var areaNumber;

        this.serviceAreaLocations.forEach((item, index) => {
            if (item.Id == rid) {
                areaName = item.Service_Area_Name__c;
                areaNumber = item.Service_Area_Number__c;
            }
        });

        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Service_Area_Locations__c'
            },
            state: {
                areaNam: areaName,
                areaNo: areaNumber
            }
        });
    }

    gtmEvent() {
        let contactUsCallEvent = new CustomEvent(
            'gtm__contactUsCall', {
            detail: {
                contact: this.areaName
            }
        });
        document.dispatchEvent(
            contactUsCallEvent, {
            bubbles: true,
            composed: true
        });
    }
}