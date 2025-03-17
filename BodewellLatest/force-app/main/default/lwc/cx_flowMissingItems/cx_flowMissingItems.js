import { LightningElement,track,api } from 'lwc';
import {FlowAttributeChangeEvent, FlowNavigationNextEvent} from 'lightning/flowSupport';

import selectCaseItems from '@salesforce/apex/CX_FlowMissingItemsController.selectCaseItems';

export default class Cx_flowMissingItems extends LightningElement {
    
    @api recordId;
    @api 
    contactId = '';

    @api
    locationId = '';

    hasContact = false;
    hasLocation = false;
    hasCaseAssets = false;

    handleNext(event){
        const nextNavigationEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(nextNavigationEvent);
    }
    
    checkAndSetTheCaseDate(result){
        if(result[0] == 'emptyContact'){
            this.hasContact = false;  
        }
        else{
            this.contactId = result[0];
            this.hasContact = true;
        }

        if(result[1] == 'emptyLocation'){
            this.hasLocation = false;
        }else{
            this.locationId = result[1];
            this.hasLocation = true;
        }
        if(result[2] == 'emptyAsset'){
            this.hasCaseAssets = false;
        }else{
            this.hasCaseAssets = true;
        }
    }

    connectedCallback() {
        // initialize component
        selectCaseItems({caseId:this.recordId})
        .then(result => {
            this.checkAndSetTheCaseDate(result);
        })
        .catch(error => {
            console.log(error);
        });
    }
}