import { LightningElement, track, wire, api } from 'lwc';
import getRetailLocations from '@salesforce/apex/BDW_serviceAreaController.getRetailArea';
import locationpin from '@salesforce/resourceUrl/svglocationpin';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

export default class Bw_retailAreas extends NavigationMixin(LightningElement) {

    @track retailAreaLocations;
    locationpinsvg = locationpin;
    @api retailAreaNumber;

    connectedCallback() {
        getRetailLocations({})
            .then(result => {
                this.retailAreaLocations = result;
                console.log('Retail Locations ' + JSON.stringify(result));
            })
            .catch(error => {
                console.log(error);
            });
    }
    
    areaName;
    areaNumber;
    mobileNumber(e) {
        var rid = e.target.dataset.value;
        this.retailAreaLocations.forEach((item, index) => {
            if (item.Id == rid) {
                this.areaName = item.Retail_Area_Name__c;
                this.areaNumber = item.Retail_Area_Number__c;
            }
        });
        this.gtmEvent();
        window.location = "tel:" + this.areaNumber;
    }

    handleRetailLocation(e) {
        var rid = e.target.dataset.value;
        var areaName;
        var areaNumber;
        var addressLine1;
        var addressLine2;
        var addressCity;
        var addressState;
        var addressZip;


        this.retailAreaLocations.forEach((item, index) => {
            if (item.Id == rid) {
                areaName = item.Retail_Area_Name__c;
                areaNumber = item.Retail_Area_Number__c;
                addressLine1 = item.Retail_Area_AddresLine1__c;
                addressLine2 = item.Retail_Area_AddresLine2__c;
                addressCity = item.Retail_Area_City__c;
                addressState = item.Retail_Area_State__c;
                addressZip = item.Retail_Area_ZipCode__c;
            }
        });

        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Retail_Area_Locations__c'
            },
            state: {
                ANa: areaName,
                ANo: areaNumber,
                A1: addressLine1,
                A2: addressLine2,
                C: addressCity,
                S: addressState,
                Z: addressZip
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