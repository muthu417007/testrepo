import { LightningElement,track,api } from 'lwc';
import {FlowAttributeChangeEvent, FlowNavigationNextEvent} from 'lightning/flowSupport';

import selectLocationAssets from '@salesforce/apex/CX_FlowLocationAssetsController.selectLocationAssets';
import addCaseAsset from '@salesforce/apex/CX_FlowLocationAssetsController.addCaseAsset';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const LOCATION_ERROR_MESSAGE = 'No Location selected for the Case. Select location to add an Asset';
const LOCATION_ASSET_ERROR_MESSAGE = 'No Assets exist for this Location';
export default class Cx_flowLocationAssets extends LightningElement {

    @api locationId;
    @api caseId;
    
    assetInformation;
    @track renderLines = true;
    @track addButtonDisabled = true;
    @track showSpinner = false;

    @track showErrorMessage = false;
    @track errorMessage;

    connectedCallback() {
        this.getLocationAssets(this.caseId);
    }

    processErrorMessages(message){
        this.showToast
        (
            message,
            message,
            'information'
        );
        this.showErrorMessage = true;
        this.errorMessage = message;
    }


    getLocationAssets(cId){
        selectLocationAssets({caseId:cId})
        .then(result => {
            if(result.messageIndicator === 'OK'){
                if(result.locationAssets.length < 1){      
                    this.processErrorMessages(LOCATION_ASSET_ERROR_MESSAGE);
                }
                else{
                    this.assetInformation = this.normalizeAssetDataWithEmptyData(result.locationAssets);
                    this.renderLines = true;
                }
            }
            else if(result.messageIndicator === 'NO_LOCATION_ID'){
                this.processErrorMessages(LOCATION_ERROR_MESSAGE);
            }
        })
        .catch(error => {
        });
    }

    showToast(title,message,variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    /**
    * Triggers the next item event for the flow 
    */
    handleNext(){
        this.dispatchEvent(new FlowNavigationNextEvent());
    }

    handleAddAsset(event){
        this.showSpinner = true;
        this.renderLines = false; 

        let geaAssetId = event.target.dataset.item;

        addCaseAsset({assetId:geaAssetId,caseId:this.caseId})
        .then(result =>{
            this.assetInformation = this.normalizeAssetDataWithEmptyData(result);
            this.showToast
            (
                'Success',
                'Asset Attached to the Case',
                'success'
            );
            this.showSpinner = false;
            this.renderLines = true;
 
            if(this.assetInformation.length == 0){
                this.handleNext();
            }

        })
        .catch(error =>{
            this.showSpinner = false;
            this.renderLines = true;
        });

    }

    normalizeAssetDataWithEmptyData(result){
        let returnArray = [];
        result.forEach(element => {
            let wrapper = {};
            wrapper.Id = element.Id;
            
            if(element.Model_Number__c == undefined){
                wrapper.Model_Number__c = '';   
            }else{
              wrapper.Model_Number__c = element.Model_Number__c;  
            }
            if(element.SerialNumber == undefined){
                wrapper.SerialNumber = '';
            }
            else{
                wrapper.SerialNumber = element.SerialNumber;
            }
            if(element.InstallDate == undefined){
                wrapper.InstallDate = '';
            }
            else{
                wrapper.InstallDate = element.InstallDate;
            }
           
            returnArray.push(wrapper);
        });
        return returnArray;
    }

}