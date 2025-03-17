import { LightningElement,api,track,wire } from 'lwc';
import { createRecord } from "lightning/uiRecordApi";
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TierAssignedValues from '@salesforce/schema/Customer_Registration__c.Tier_Assigned__c';
import BrandsSelling from '@salesforce/schema/Customer_Registration__c.BrandsCurrentlySellingmultipicklist__c';
import ProductsOffered from '@salesforce/schema/Customer_Registration__c.Products_Offered_Check_all_that_apply__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Registration_Object from '@salesforce/schema/Customer_Registration__c';
import uid from '@salesforce/user/Id';
import getASMUserRecord from '@salesforce/apex/GetASMRecord.getASMRecordDetails';

/**
 * Creates Account records.
 */
export default class Anw_DealerRegistration extends LightningElement {
    @track userID=uid;
    @track showdealerregistration=true;
    emailPattern = '[A-Za-z0-9._+-]+@[a-z0-9-]+.[a-z]{2,}$';
    emailPatternValidationMessage = 'Please enter a valid email';
    phonePattern = '[0-9]{3}-[0-9]{3}-[0-9]{4}|[0-9]{10}$';
    phonePatternValidationMessage = 'Please enter a valid phone number';
    addressFieldPattern = '^[a-zA-Z0-9 ]+$';
    addressPatternValidationMessage = 'Special characters are not allowded.';
    @api managerName;
    @track showregisteredproduct=false;
    @api managerEmail;
    @api managerPhone;
    @track successmsg;
    @track successdesc;
    @track otherbrands;
    @api dealerName;
    @api contactName;
    @api contactTitle;
    @api contactPhone;
    @api contactEmail;
    @api shipAddress;
    @api billAddress;
    @api annualVolume;
    @api brandsSelling;
    @api otherBrandsSelling;
    @api brandsUpdate;
    @api tierAssigned;
    @track CountryValues=[];
    @track otherbrands=false;
    @track tierAssignedValue;
    @track brandsSellingValue;
    @api emailMismatch=false;
    @track isLoading;
    @api billStreet;
    @api billCity;
    @api billState;
    @api billZipcode;
    @api billCountry;
    @api shipStreet;
    @api shipCity;
    @api shipState;
    @api shipZipcode;
    @api shipCountry;
    @api branchLocation;
    @track shipStateValues=[];
    @track billStateValues = []
    @track billSameAsShip = false;
    _selected=[];
    @track selectedproductsoffered=[];
    @track selectedBrands=[];
    connectedCallback(){
        this.otherbrands=false;
        this.showdealerregistration=true;
        console.log('user id '+this.userID);
        this.showregisteredproduct=false;
        this.CountryValues = [
            { label : 'USA', value : 'USA'},
            { label : 'CANADA', value : 'CANADA'}
        ]
        getASMUserRecord({ userId : this.userID})
            .then((jsonResponse) => {
                console.log('response is '+jsonResponse);
                if(jsonResponse!=null){
                    this.managerName=jsonResponse.FirstName+' '+jsonResponse.LastName;
                    console.log('Manager Name :- '+jsonResponse.Name);
                    this.managerEmail=jsonResponse.Email;
                    this.managerPhone=jsonResponse.Phone;
                }
            })
            .catch((error) => {
                console.log('error'+error);
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to load the page.',
                    variant: 'error',
                });
                dispatchEvent(evt);
           });
    
            
    }

    /*@wire(getASMUserRecord,{userId : '0057A000005as8RQAQ'})
    asmuserdata;*/
    //managerName=asmuserdata;
    @wire(getObjectInfo, { objectApiName: Registration_Object })
    registrationdata;

    @wire(getPicklistValues,
        {
            recordTypeId: '$registrationdata.data.defaultRecordTypeId',
            fieldApiName: TierAssignedValues
        }
    )
    TierAssignedValues;

    @wire(getPicklistValues,
        {
            recordTypeId: '$registrationdata.data.defaultRecordTypeId',
            fieldApiName: BrandsSelling
        }
    )
    BrandsSelling;

    @wire(getPicklistValues,
        {
            recordTypeId: '$registrationdata.data.defaultRecordTypeId',
            fieldApiName: ProductsOffered
        }
    )
    ProductsOffered;

    get selected() {
        return this._selected.length?this._selected:'none';
    }
    isSelectedInputValid(field) {
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if (inputField.name == field) {
                inputField.reportValidity();
            }
        });
    }
    handleproductsoffered(event){
        this.selectedproductsoffered= event.detail.value;
    }
    handleBrandsSellingChange(event){
        this.brandsSellingValue=event.detail.value;
        this.selectedBrands=event.detail.value;
        console.log('brands selling'+this.brandsSellingValue);
        if(this.selectedBrands.includes('Other'))
            this.otherbrands=true;
        else
            this.otherbrands=false;
    }
    isNewPhoneValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.phone-validate');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }
    handleContactInputChange(e) {
        if (e.target.name === "managerName") {
            this.managerName = e.target.value;
            this.isSelectedInputValid(e.target.name);
        } else if (e.target.name === "managerPhone") {
            this.managerPhone = e.target.value;
            this.isNewPhoneValid();
        } else if (e.target.name === "managerEmail") {
            this.managerEmail = e.target.value;
            this.emailMismatch = false;
            this.isSelectedInputValid(e.target.name);
        } else if (e.target.name === "dealerName") {
            this.dealerName = e.target.value;
            this.isSelectedInputValid(e.target.name);
        } else if (e.target.name === "contactName") {
            this.contactName = e.target.value;
            this.isSelectedInputValid(e.target.name);
        } else if (e.target.name === "contactPhone") {
            this.contactPhone = e.target.value;
            this.isNewPhoneValid();
        } else if (e.target.name === "contactEmail") {
            this.contactEmail = e.target.value;
            this.isSelectedInputValid(e.target.name);
        } else if(e.target.name === "shipAddress") {
            this.shipStreet = e.target.value;
            if(this.billSameAsShip == true)
                this.billStreet =this.shipStreet;
        } else if(e.target.name === "shipCity") {
            this.shipCity = e.target.value;
            if(this.billSameAsShip == true)
                this.billCity = this.shipCity;
        } else if(e.target.name === "shipState") {
            this.shipState = e.target.value;
            if(this.billSameAsShip == true)
                this.billState = this.shipState;
        } else if(e.target.name === "shipZipcode") {
            this.shipZipcode = e.target.value;
            if(this.billSameAsShip == true)
                this.billZipcode = this.shipZipcode;
        } else if(e.target.name === "shipCountry") {
            this.shipCountry = e.target.value;
            if(this.billSameAsShip == true){
                this.billCountry = this.shipCountry;
                this.handleStatePicklist(true);
            }
            else {
                this.handleStatePicklist(false);
            }
        }
        
        
        if(e.target.name === "shipCheckbox" ) {
            this.billSameAsShip = e.target.checked;
            this.handleStatePicklist(true);
            if(this.billSameAsShip){
                console.log('target val '+e.target.checked);
                this.billStreet = this.shipStreet;
                this.billState = this.shipState;
                this.billCity = this.shipCity;
                this.billZipcode = this.shipZipcode;
                this.billCountry = this.shipCountry;
            }
        }
    }

    handlebillStatePicklist(event){
        this.billCountry = event.detail.value;
        if(this.billCountry=='USA'){
            this.billStateValues = [

                 { label: 'Alabama', value: 'AL' },
                 { label: 'Alaska', value: 'AK' },
                 { label: 'Arizona', value: 'AZ' },
                 { label: 'Arkansas', value: 'AR' },
                
                 { label: 'California', value: ' CA' },
                
                 { label: 'Colorado', value: 'CO' },
                
                 { label: 'Connecticut', value: 'CT' },
                
                 { label: 'Delaware', value: 'DE' },
                
                 { label: 'District of Columbia', value: 'DC' },
                
                 { label: 'Florida', value: 'FL' },
                
                 { label: 'Georgia', value: 'GA' },
                
                 { label: 'Hawaii', value: 'HI' },
                
                 { label: 'Idaho', value: 'ID' },
                
                 { label: 'Illinois', value: 'IL' },
                
                 { label: 'Indiana', value: 'IN' },
                
                 { label: 'Iowa', value: 'IA' },
                
                 { label: 'Kansas', value: 'KS' },
                
                 { label: 'Kentucky', value: 'KY' },
                
                 { label: 'Louisiana', value: 'LA' },
                
                 { label: 'Maine', value: 'ME' },
                
                 { label: 'Maryland', value: 'MD' },
                
                 { label: 'Massachusetts', value: 'MA' },
                
                 { label: 'Michigan', value: 'MI' },
                
                 { label: 'Minnesota', value: 'MN' },
                
                 { label: 'Mississippi', value: 'MS' },
                
                 { label: 'Missouri', value: 'MO' },
                
                 { label: 'Montana', value: 'MT' },
                
                 { label: 'Nebraska', value: 'NE' },
                
                 { label: 'Nevada', value: 'NV' },
                
                 { label: 'New Hampshire', value: 'NH' },
                
                 { label: 'New Jersey', value: 'NJ' },
                
                 { label: 'New Mexico', value: 'NM' },
                
                 { label: 'New York', value: 'NY' },
                
                 { label: 'North Carolina', value: 'NC' },
                
                 { label: 'North Dakota', value: 'ND' },
                
                 { label: 'Ohio', value: 'OH' },
                
                 { label: 'Oklahoma', value: 'OK' },
                
                 { label: 'Oregon', value: 'OR' },
                
                 { label: 'Pennsylvania', value: 'PA' },
                
                 { label: 'Rhode Island', value: 'RI' },
                
                 { label: 'South Carolina', value: 'SC' },
                 { label: 'South Dakota', value: 'SD' },
                 { label: 'Tennessee', value: 'TN' },
                 { label: 'Texas', value: 'TX' },
                 { label: 'Utah', value: 'UT' },
                 { label: 'Vermont', value: 'VT' },
                 { label: 'Virginia', value: 'VA' },
                 { label: 'Washington', value: 'WA' },
                 { label: 'West Virginia', value: 'WV' },
                 { label: 'Wisconsin', value: 'WI' },
                 { label: 'Wyoming', value: 'WY' }
                
                ]
        }

        else if(this.billCountry == 'CANADA'){
            this.billStateValues = [
                { label: 'Alberta', value: 'AB' },
                { label: 'British Columbia', value: 'BC' },
                { label: 'Manitoba', value: 'MB' },
                { label: 'New Brunswick', value: 'NB' },
                { label: 'Newfoundland and Labrador', value: 'NL' },
                { label: 'Northwest Territories', value: 'NT' },
                { label: 'Nova Scotia', value: 'NS' },
                { label: 'Nunavut', value: 'NU' },
                { label: 'Ontario', value: 'ON' },
                { label: 'Prince Edward Island', value: 'PE' },
                { label: 'Quebec', value: 'QC' },
                { label: 'Saskatchewan', value: 'SK' },
                { label: 'Yukon', value: 'YT' }
                ]
        }
    }
    handleStatePicklist(flag){

        if(this.shipCountry=='USA'){
            this.shipStateValues = [

                 { label: 'Alabama', value: 'AL' },
                 { label: 'Alaska', value: 'AK' },
                 { label: 'Arizona', value: 'AZ' },
                 { label: 'Arkansas', value: 'AR' },
                
                 { label: 'California', value: ' CA' },
                
                 { label: 'Colorado', value: 'CO' },
                
                 { label: 'Connecticut', value: 'CT' },
                
                 { label: 'Delaware', value: 'DE' },
                
                 { label: 'District of Columbia', value: 'DC' },
                
                 { label: 'Florida', value: 'FL' },
                
                 { label: 'Georgia', value: 'GA' },
                
                 { label: 'Hawaii', value: 'HI' },
                
                 { label: 'Idaho', value: 'ID' },
                
                 { label: 'Illinois', value: 'IL' },
                
                 { label: 'Indiana', value: 'IN' },
                
                 { label: 'Iowa', value: 'IA' },
                
                 { label: 'Kansas', value: 'KS' },
                
                 { label: 'Kentucky', value: 'KY' },
                
                 { label: 'Louisiana', value: 'LA' },
                
                 { label: 'Maine', value: 'ME' },
                
                 { label: 'Maryland', value: 'MD' },
                
                 { label: 'Massachusetts', value: 'MA' },
                
                 { label: 'Michigan', value: 'MI' },
                
                 { label: 'Minnesota', value: 'MN' },
                
                 { label: 'Mississippi', value: 'MS' },
                
                 { label: 'Missouri', value: 'MO' },
                
                 { label: 'Montana', value: 'MT' },
                
                 { label: 'Nebraska', value: 'NE' },
                
                 { label: 'Nevada', value: 'NV' },
                
                 { label: 'New Hampshire', value: 'NH' },
                
                 { label: 'New Jersey', value: 'NJ' },
                
                 { label: 'New Mexico', value: 'NM' },
                
                 { label: 'New York', value: 'NY' },
                
                 { label: 'North Carolina', value: 'NC' },
                
                 { label: 'North Dakota', value: 'ND' },
                
                 { label: 'Ohio', value: 'OH' },
                
                 { label: 'Oklahoma', value: 'OK' },
                
                 { label: 'Oregon', value: 'OR' },
                
                 { label: 'Pennsylvania', value: 'PA' },
                
                 { label: 'Rhode Island', value: 'RI' },
                
                 { label: 'South Carolina', value: 'SC' },
                 { label: 'South Dakota', value: 'SD' },
                 { label: 'Tennessee', value: 'TN' },
                 { label: 'Texas', value: 'TX' },
                 { label: 'Utah', value: 'UT' },
                 { label: 'Vermont', value: 'VT' },
                 { label: 'Virginia', value: 'VA' },
                 { label: 'Washington', value: 'WA' },
                 { label: 'West Virginia', value: 'WV' },
                 { label: 'Wisconsin', value: 'WI' },
                 { label: 'Wyoming', value: 'WY' }
                
                ]
        }

        else if(this.shipCountry == 'CANADA'){
            this.shipStateValues = [
                { label: 'Alberta', value: 'AB' },
                { label: 'British Columbia', value: 'BC' },
                { label: 'Manitoba', value: 'MB' },
                { label: 'New Brunswick', value: 'NB' },
                { label: 'Newfoundland and Labrador', value: 'NL' },
                { label: 'Northwest Territories', value: 'NT' },
                { label: 'Nova Scotia', value: 'NS' },
                { label: 'Nunavut', value: 'NU' },
                { label: 'Ontario', value: 'ON' },
                { label: 'Prince Edward Island', value: 'PE' },
                { label: 'Quebec', value: 'QC' },
                { label: 'Saskatchewan', value: 'SK' },
                { label: 'Yukon', value: 'YT' }
                ]
        }
        if(flag ==true){
            this.billStateValues = this.shipStateValues;
        }
    }
    handleSubmit(){
        //this.showdealerregistration=false;
        //this.showregisteredproduct=true;
        this.managerName = this.template.querySelector('lightning-input[data-name="managerName"]').value.trim();
        this.managerEmail = this.template.querySelector('lightning-input[data-name="managerEmail"]').value.trim();
        this.managerPhone = this.template.querySelector('lightning-input[data-name="managerPhone"]').value.trim();
        this.dealerName = this.template.querySelector('lightning-input[data-name="dealerName"]').value.trim();
        this.contactName = this.template.querySelector('lightning-input[data-name="contactName"]').value.trim();
        this.contactEmail = this.template.querySelector('lightning-input[data-name="contactEmail"]').value.trim();
        this.contactPhone = this.template.querySelector('lightning-input[data-name="contactPhone"]').value.trim();
        this.contactTitle = this.template.querySelector('lightning-input[data-name="contactTitle"]').value.trim();
        this.annualVolume = this.template.querySelector('lightning-input[data-name="annualVolume"]').value.trim();
        //this.shipAddress = this.template.querySelector('lightning-input[data-name="shipAddress"]').value.trim();
        //this.billAddress = this.template.querySelector('lightning-input[data-name="billAddress"]').value.trim();
        this.billStreet = this.template.querySelector('lightning-input[data-name="billStreet"]').value.trim();
        this.billCity = this.template.querySelector('lightning-input[data-name="billCity"]').value.trim();
        this.billState = this.template.querySelector('[data-id="billStateId"]').value;
        this.billZipcode = this.template.querySelector('lightning-input[data-name="billZipcode"]').value.trim();
        this.billCountry = this.template.querySelector('[data-id="billCountryId"]').value;
        this.shipStreet = this.template.querySelector('lightning-input[data-name="shipStreet"]').value.trim();
        this.shipCity = this.template.querySelector('lightning-input[data-name="shipCity"]').value.trim();
        this.shipState = this.template.querySelector('[data-id="shipStateId"]').value;
        this.shipZipcode = this.template.querySelector('lightning-input[data-name="shipZipcode"]').value.trim();
        this.shipCountry = this.template.querySelector('[data-id="shipCountryId"]').value;
        this.branchLocation = this.template.querySelector('lightning-input[data-name="branchLocation"]').value.trim();
        
        this.brandsSelling = this.selectedBrands.join(';');
        if(this.selectedBrands.includes('Other'))
            this.otherBrandsSelling= this.template.querySelector('lightning-input[data-name="otherBrandsSelling"]').value.trim();
        this.brandsUpdate= this.template.querySelector('lightning-input[data-name="brandsUpdate"]').value.trim();
        this.tierAssigned= this.template.querySelector('[data-id="TireAssignedID"]').value;
        //console.log('selected products are '+ this.tierAssigned+' '+this.selectedproductsoffered);
        //console.log('values are'+this.contactTitle,this.managerEmail,this.managerName,this.managerPhone,this.contactEmail,this.contactName,this.contactPhone,this.dealerName,this.brandsSelling,this.brandsUpdate,this.annualVolume,this.shipAddress,this.billAddress);
        let plistvalue= this.selectedproductsoffered.join(';');
        //console.log('multi selct picklist is '+plistvalue );
        console.log('values'+this.brandsSelling+' 1 '+this.brandsUpdate+' 2 '+this.tierAssigned+'3 '+plistvalue);
        if(this.dealerName && this.contactName && this.contactEmail && this.contactPhone && this.contactTitle && this.annualVolume && this.shipStreet && this.shipCity && 
            this.shipState!=undefined && this.shipZipcode && this.shipCountry!=undefined && this.billCity && this.billState!=undefined && this.billZipcode && this.billCountry!=undefined && this.billStreet &&
            this.tierAssigned!=undefined && plistvalue && ( this.brandsSelling &&(!this.brandsSelling.includes('Other') || (this.brandsSelling.includes('Other') && this.otherBrandsSelling))) && this.brandsUpdate){
            this.isLoading=true;
        
        var customerRegistrationFields = {
            //'Dealer_Billing_Address__c': this.billAddress,
            'BrandsCurrentlySellingmultipicklist__c':this.brandsSelling,
            'Other_Brands_Currently_Selling__c':this.otherBrandsSelling,
            'Dealer_Contact_Email__c':this.contactEmail,
            'Dealer_Contact_Name__c':this.contactName,
            'Dealer_Contact_Phone_Number__c':this.contactPhone,
            'Dealer_Contact_Title__c':this.contactTitle,
            'Dealer_Name__c':this.dealerName,
            //'Dealer_Shipping_Address__c':this.shipAddress,
            //'Distributor_Territory_Manager_Email__c':this.managerEmail,
            //'Area_Sales_Manager_ASM__c':this.managerName,
            //'Distributor_Territory_Manager_Phone__c':this.managerPhone,
            'Estimated_Annual_Dealer_Volume__c':this.annualVolume,
            'Will_GEA_be_replacing_with_any_Brand__c':this.brandsUpdate,
            'Tier_Assigned__c':this.tierAssigned,
            'Products_Offered_Check_all_that_apply__c': plistvalue,
            'Billing_Street__c':this.billStreet,
            'Billing_City__c':this.billCity,
            'Billing_State__c':this.billState,
            'Billing_Zip_postal_Code__c':this.billZipcode,
            'Billing_Country__c':this.billCountry,
            'Shipping_Street__c':this.shipStreet,
            'Shipping_City__c':this.shipCity,
            'Shipping_Zip_postal_Code__c':this.shipZipcode,
            'Shipping_State__c':this.shipState,
            'Shipping_Country__c':this.shipCountry,
            'Distributor_Branch_Location__c':this.branchLocation
            //'RecordtypeId' : '0127A000000k0cTQAQ', 0127A000000k0TeQAI
        };
        var customerRegistrationrecord = { 'apiName': 'Customer_Registration__c', fields: customerRegistrationFields };
        createRecord(customerRegistrationrecord)
                .then(record => {
                    this.successmsg='Registration Successful';
                    this.successdesc='Thank You For Registering. Your request is submitted for approval.';
                    this.isLoading=false;
                    this.showdealerregistration=false;
                    this.showregisteredproduct=true;
                    const toastEvent = new ShowToastEvent({
                        title: 'Success',
                        message: 'Registration Successful',
                        variant: 'success'
    
    
                    });
                    dispatchEvent(toastEvent);
                })
                .catch(error=> {
                    this.isLoading=false;
                    this.showdealerregistration=false;
                    this.showregisteredproduct=true;
                    console.log('Registration Failed'+error.status+error.message);
                    this.successmsg='Registration Failed';
                    this.successdesc='We are sorry, your registration got failed due to some error.';
                    console.log('error-->'+JSON.stringify(error));
                    const toastEvent = new ShowToastEvent({
                        title: 'Failed',
                        message: 'Registration Failed'+error.body.message,
                        variant: 'error'
    
    
                    });
                    dispatchEvent(toastEvent);
                });
        }
        else {
            console.log('required fields missing');
            const evt = new ShowToastEvent({
                title: 'Required',
                message: 'Please fill all the required fields.',
                variant: 'error',
            });
            dispatchEvent(evt);
        }

              
    }
    
}