import { LightningElement,track,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import {FlowAttributeChangeEvent, FlowNavigationNextEvent} from 'lightning/flowSupport';

import createContact from '@salesforce/apex/CX_CreateContactAssetLocationController.createContact';

import { showToast, handleError } from 'c/cx_utils';

export default class Cx_createContactAssetLocation extends NavigationMixin(LightningElement) {
    
    @api recordId;
    @api contactId;
    @api newContactData;
    
    @track firstName;
    @track lastName;
    @track phoneNumber;
    @track email;
    @track zip;
    @track street;
    @track country = 'United States';
    @track city;
    @track state;
    @track isChecked = false;
    @track isUnknonwAddressSelected = true;
    @track unknownAddress = false;

    @track showSpinner = false;

    @track contactFieldsDisabled = false;
    validateButtonDisabled = false; 

    firstRender = true;

    /**
    * A lifecycle hook that runs when the component renders or re-renders an item on the screen,
    * when first executing, checks if input data was received for email or phone
    */
    renderedCallback() {
        if(this.firstRender) {
            this.checkNewContactData();
            this.firstRender = false;
        }    
    }

    /**
    * A method that checks if data was received for phone or email, if so, adds to the respective field
    */
    checkNewContactData() {
        if(!this.newContactData) {
            return;
        }

        if(this.newContactData.includes('@')) {
            this.template.querySelector('[data-id="email"]').value = this.newContactData;
            this.email = this.newContactData;
        } else {
            this.template.querySelector('[data-id="phone"]').value = this.newContactData;
            this.phoneNumber = this.newContactData;
        }
    }

    /**
    * Triggers the next item event for the flow 
    */
    handleNext(){
        this.dispatchEvent(new FlowAttributeChangeEvent('contactId', this.contactId));
        this.dispatchEvent(new FlowNavigationNextEvent());
    }
    
    
    /**
    * the method that creates the contact information
    *  @param {event} event - A click event 
    */
    handleCreateContactInformation(event){
        if(!this.validateContactCreationFields(event)){
            return;
        }

        this.showSpinner = true;
        this.contactFieldsDisabled = true;

        let methodWrapper = {};

        methodWrapper.street = this.street;
        methodWrapper.zip = this.zip;
        methodWrapper.phone = this.phoneNumber;
        methodWrapper.email = this.email;
        methodWrapper.firstName = this.firstName;
        methodWrapper.lastName = this.lastName;
        methodWrapper.unknownAddress = this.unknownAddress;
        methodWrapper.usePhoneField = true;
        methodWrapper.country = this.country;
        methodWrapper.state = this.state;
        methodWrapper.city = this.city;
        console.log(methodWrapper);

        createContact(
            {wrapperString:JSON.stringify(methodWrapper),caseId:this.recordId}
            )
        .then(result => {
            this.contactId = result.Id;
            showToast(this, 'Contact Creation', 'Contact Creation is Successfull', 'success');
            this.showSpinner = false;
            this.handleNext();
        })
        .catch(error => {
            handleError(this, error);
            this.validateButtonDisabled = false;
            this.showSpinner = false;
            this.contactFieldsDisabled = false;
        });
    }

    /**
    * the method that validates the input fields 
    * @param {event} event - A click event
    */
    validateContactCreationFields(event){
        if(this.country==='United States'){
            if(this.isChecked){
                if(this.isFieldEmpty(this.firstName) || this.isFieldEmpty(this.lastName) || 
                        this.isFieldEmpty(this.phoneNumber)){
                    showToast(this, 'Please fill the fields', 'For contact creation please fill all the Contact Information', 'warning');
                    return false;
                } 
            }else {
                    if(this.isFieldEmpty(this.firstName) || this.isFieldEmpty(this.lastName) || 
                        this.isFieldEmpty(this.phoneNumber) || this.isFieldEmpty(this.zip) || 
                        this.isFieldEmpty(this.street)){
                        showToast(this, 'Please fill the fields', 'For contact creation please fill all the Contact Information', 'warning');
                        return false;
                    }
                } 
        }
   
        if(this.country==='Canada'){
            if(this.isChecked){ 
                if(this.isFieldEmpty(this.firstName) || this.isFieldEmpty(this.lastName) || 
                    this.isFieldEmpty(this.phoneNumber) ){
                    showToast(this, 'Please fill the fields', 'For contact creation please fill all the Contact Information', 'warning');
                    return false;
                }
            } else {
                if(this.isFieldEmpty(this.firstName) || this.isFieldEmpty(this.lastName) || 
                    this.isFieldEmpty(this.phoneNumber) || this.isFieldEmpty(this.zip) || 
                    this.isFieldEmpty(this.street) ||  this.isFieldEmpty(this.city) || this.isFieldEmpty(this.state)){
                    showToast(this, 'Please fill the fields', 'For contact creation please fill all the Contact Information', 'warning');
                    return false;
                }  
            }   
        }     
    
        return true;
    }

    /**
    * the method that chesks the field value
    * @param value - value that will checked
    */
    isFieldEmpty(value){
        if(value == null || value == undefined || value == ''){
            return true;
        }
        return false;
    }


    /**
    * the method that clears the fields
    * @event event - event param
    */
    handleClearAllFields(event){
        this.firstName = null;
        this.lastName = null;
        this.phoneNumber = null;
        this.email = null;
        this.zip = null;
        this.street = null;
        this.country = 'United States';
        this.contactFieldsDisabled = false;
    }
    
    /**
    * the method that handles firstNameField change
    * @event event - event param
    */
    handleFirstNameChange(event){
        this.firstName = event.target.value;
    }
    handleCityChange(event){
        this.city = event.target.value;
    }
    handleStateChange(event){
        this.state = event.target.value;
    }

    /**
    * the method that handles lastNameField change
    * @event event - event param
    */
    handleLastNameChange(event){
        this.lastName = event.target.value;
    }

    /**
    * the method that handles phoneNumberField change
    * @event event - event param
    */
    handlePhoneNumberChange(event){
        this.phoneNumber = event.target.value;
    }

    /**
    * the method that handles zipField change
    * @event event - event param
    */
    handleZipChange(event){
        this.zip = event.target.value;
    }

    /**
    * the method that handles streetField change
    * @event event - event param
    */
    handleStreetChange(event){
        this.street = event.target.value;
    }
    handleCountryChange(event) {
        this.country =  event.target.value;
    }
    /**
    * the method that handles email change
    * @event event - event param
    */
    handleEmailChange(event){
        this.email = event.target.value;
    }

    /**
    * the method that handles Unknown address selection
    * @event event - event param
    */
    handleCheckboxChange(event){
        this.isChecked = event.target.checked;
        this.isUnknonwAddressSelected = !this.isChecked;
        this.street = event.target.checked ? 'NoAddress':'';
        this.zip = event.target.checked ? '00000':'';
        this.unknownAddress = event.target.checked ? true : false;
        console.log('Check box selected: '+this.isChecked);
        console.log('Fields not set as requried: '+this.isUnknonwAddressSelected);
    }

    get inputOptions() {
        return [
            { label: 'United States', value: 'United States' },
            { label: 'Canada', value: 'Canada' }
        ];
    }

    get renderOptionalField() {
        return this.country === 'Canada' ? true : false;
    }

   
}