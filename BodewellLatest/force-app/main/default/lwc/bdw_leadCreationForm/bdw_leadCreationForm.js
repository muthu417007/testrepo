import { LightningElement, track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import LEAD_OBJECT from '@salesforce/schema/Lead';
import FIRSTNAME_FIELD from '@salesforce/schema/Lead.FirstName';
import LASTNAME_FIELD from '@salesforce/schema/Lead.LastName';
import EMAIL_FIELD from '@salesforce/schema/Lead.Email';
import PHONE_FIELD from '@salesforce/schema/Lead.Phone';
import COMPANY_FIELD from '@salesforce/schema/Lead.Company';
import WOULDCONTACT_FIELD from '@salesforce/schema/Lead.I_would_like_to_be_contacted__c';
import CONTACTPREF_FIELD from '@salesforce/schema/Lead.Contact_Preference__c';
import COMMENT_FIELD from '@salesforce/schema/Lead.Comments_from_Lead__c';
import createleadRec from '@salesforce/apex/BDW_CreateLead.createLead';

export default class Bdw_leadCreationForm extends NavigationMixin(LightningElement) {

    @track firstName = FIRSTNAME_FIELD;
    @track lastName = LASTNAME_FIELD;
    @track email = EMAIL_FIELD;
    @track phone = PHONE_FIELD;
    @track company = COMPANY_FIELD;
    @track wouldcontact = WOULDCONTACT_FIELD;
    @track contactPref = CONTACTPREF_FIELD;
    @track commentLead = COMMENT_FIELD;
    stringRec;

    recaptchaResponse;
    generalError;

    message;
    error;

    valuePref = '';
    value = [];

    testsize = false;

    rec = {
        FirstName: this.firstName,
        LastName: this.lastName,
        Email: this.email,
        Phone: this.phone,
        Company: this.company,
        I_would_like_to_be_contacted__c: this.wouldcontact,
        Contact_Preference__c: this.contactPref,
        Comments_from_Lead__c: this.commentLead
    }

    get optionsPref() {
        return [
            { label: 'Email', value: 'Email' },
            { label: 'Phone', value: 'Phone' },
        ];
    }

    handlePreferenceChange(event) {
        this.valuePref = event.detail.value;
        this.rec.Contact_Preference__c = event.detail.value;
    }

    get options() {
        return [
            { label: 'Scheduling service for my appliance', value: 'Scheduling service for my appliance' },
            { label: 'Buying parts for my appliance', value: 'Buying parts for my appliance' },
            { label: 'Getting help using or troubleshooting my appliance', value: 'Getting help using or troubleshooting my appliance' },
            { label: 'Purchasing a new appliance', value: 'Purchasing a new appliance' },
            { label: 'I don’t need to be contacted immediately', value: 'I don’t need to be contacted immediately' },
            { label: 'I would like to know more about Bodewell services & promotions', value: 'I would like to know more about Bodewell services & promotions' },
            { label: 'Other (specify below)', value: 'Other (specify below)' },
        ];
    }

    handleCheckboxGroupChange(e) {
        this.value = e.detail.value;
        this.rec.I_would_like_to_be_contacted__c = this.value.join(';');
    }

    handlefirstNameChange(event) {
        this.rec.FirstName = event.target.value;
    }
    handlelastNameChange(event) {
        this.rec.Company = 'BODEWELL LEAD'
        this.rec.LastName = event.target.value;

    }
    handleemailChange(event) {
        this.rec.Email = event.target.value;
    }
    handlephoneChange(event) {
        this.rec.Phone = event.target.value;
    }

    comment;
    counts = 250;

    handleCommentsChange(event) {
        this.rec.Comments_from_Lead__c = event.target.value;
        this.counts = 250 - this.rec.Comments_from_Lead__c.length;
    }
    get cout() {
        return this.counts + "characters left.";
    }
    
    showCountFlag = false;
    handleFocus(event)
    {
        this.showCountFlag = true;
    }
    handleBlur(event)
    {
        this.showCountFlag = false;
    }

    onVerified(event) {
        this.recaptchaResponse = event.detail.response;
        document.getElementById("myBtn").disabled = false;
        this.generalError = false;
        debugger;
     }

    handleSubmit() 
    {
        debugger;
        if(!this.generalError)
        {
            this.stringRec = JSON.stringify(this.rec);
            console.log(this.stringRec);

            createleadRec({ leadRec: this.rec })
                .then(result => {
                    debugger;
                    this.message = result;
                    this.error = undefined;
                    if (this.message !== undefined) {
                        this.rec.FirstName = '';
                        this.rec.LastName = '';
                        this.rec.Phone = '';
                        this.rec.Email = '';
                        this.rec.Company = '';
                    }
                    console.log(JSON.stringify(result));

                    this[NavigationMixin.Navigate]({
                        type: 'comm__namedPage',
                        attributes: {
                            name: 'Coupon__c'
                        },
                        state: {}
                    });
                })
                .catch(error => {
                    this.message = undefined;
                    this.error = error;
                    console.log("error", JSON.stringify(this.error));
                })
        }
    }
}