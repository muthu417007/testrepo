import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {FlowAttributeChangeEvent,FlowNavigationNextEvent} from 'lightning/flowSupport';
import selectContactLocations from '@salesforce/apex/CX_FlowLocationComponentController.selectContactLocations';
import createAndSetCaseLocation from '@salesforce/apex/CX_FlowLocationComponentController.createAndSetCaseLocation';
import setSelectedLocation from '@salesforce/apex/CX_FlowLocationComponentController.setSelectedLocation';

import { showToast, handleError } from 'c/cx_utils';

export default class Cx_flowLocationComponent extends LightningElement {

    @api caseId;
    @api contactId;
    @api locationId;

    locationInformation;

    @track addButtonDisabled = false;
    @track renderLines = true;
    @track showSpinner = false;
    @track disableCreationButtonsAndInput;


    @track zip;
    @track street;
    
    connectedCallback() {
        this.getContactLocations(this.contactId,this.locationId);
    }

    getContactLocations(contId,locId){
        selectContactLocations({contactId:contId,currentLocationId:locId})
        .then(result => {
            this.locationInformation = result;
        })
        .catch(error => {
            handleError(this, error);
            this.enableAll(); 
        });
    }

    validateLocationCreationFields(event){
        if(this.isFieldEmpty(this.zip) || this.isFieldEmpty(this.street)){
            showToast(this, 'Please fill the fields', 'For location creation please fill all the Location information', 'warning');
            return false;
        } 
        return true;
    }

    isFieldEmpty(value){
        if(value == null || value == undefined || value == ''){
            return true;
        }
        return false;
    }

    disableAll(){
        this.renderLines = false;
        this.showSpinner = true;
        this.disableCreationButtonsAndInput = true;
    }

    enableAll(){
        this.renderLines = true;
        this.showSpinner = false;
        this.disableCreationButtonsAndInput = false;
    }

    updateCaseLocationWithSelected(event){
        this.disableAll();

        let locationId = event.target.dataset.item;

        setSelectedLocation({
            caseId: this.caseId,
            locationId: locationId,
            contactId: this.contactId})
        .then(result => {
            this.locationInformation = result;
            this.locationId = locationId;
            this.setFlowLocationIdParameter(this.locationId);
            showToast(this, 'Success', 'Case Location Updated!', 'success');
            this.enableAll();
        })
        .catch(error => {
            handleError(this, error);
            this.enableAll();
        });
    }

    setFlowLocationIdParameter(locId) {
        this.dispatchEvent(new FlowAttributeChangeEvent('CX_LocationId', locId));
        this.dispatchEvent(new FlowNavigationNextEvent());
    }

    createNewLocation(){

        if(!this.validateLocationCreationFields()){
            return;
        }

        this.disableAll();
        createAndSetCaseLocation({
                contactId:this.contactId,
                street: this.street,
                zipCode: this.zip,
                caseId: this.caseId})
        .then(result => {
            console.log('Location Creation Return value');
            console.log(result);
            this.locationInformation = result.locationInformation;
            this.locationId = result.selectedLocationId;
            this.setFlowLocationIdParameter(this.locationId);
            showToast(this, 'Success', 'Location Created!', 'success');
            this.enableAll();
        })
        .catch(error => {
            handleError(this, error);
            this.enableAll();
        });
    }

    handleClearAllFields(){
        this.zip = null;
        this.street = null;
    }

    handleZipChange(event){
        this.zip = event.target.value;
    }

    handleStreetChange(event){
        this.street = event.target.value;
    }
}