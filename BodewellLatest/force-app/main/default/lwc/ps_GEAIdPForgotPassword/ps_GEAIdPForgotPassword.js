import {api,track, LightningElement} from 'lwc';
import {NavigationMixin} from "lightning/navigation";
import sendForgotEmail from "@salesforce/apex/PS_GEAIdPForgotPasswordCtrl.sendForgotEmail";

export default class PsGeaIdPForgotPassword extends NavigationMixin(LightningElement) {

    @api
    emailLabel = 'Email';
    @api
    submitButtonLabel = 'Submit';
    @api
    errorMessage = 'If an account exist an email will be sent with instruction on resetting your password';
   //added as part of Terms and Conditions on reset page
    @api termsAndConditionsURL = 'https://www.geappliances.com/privacy/terms.htm';
    @api termsAndConditionsURLLabel = 'Terms of Use';
    @api privacyPolicyURL = 'https://www.geappliances.com/privacy/privacy_policy.htm';
    @api privacyPolicyURLLabel = 'Privacy Statement';
    @api privacyPolicyLabel = 'Privacy Statement';
    @track termsAndConditionsHasError = false;
    @track emailInput;
    @track isEmailValid = true;
//constants
TERMS_AND_CONDITIONS_WITH_ERROR = 'slds-m-top_medium slds-m-bottom_medium terms-and-conditions-required';
TERMS_AND_CONDITIONS_WITHOUT_ERROR = 'slds-m-top_medium slds-m-bottom_medium';

    
    isLoading = false;
    showRequestError = false;
    isTermsAndConditions = false;
    onKeyUpEmailInput(component) {
        //if 'enter' key login
        if (component.which === 13) {
            this.handleSubmit();
        }
    }

    handleEmailChange(event) {
        this.emailInput = event.target.value;
        const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        let emailVal = this.emailInput;
        if (emailVal.match(emailRegex)) {
            this.isEmailValid = true;
        } else {
            this.isEmailValid = false;
        }
    }
    onTermAndConditionsChanged(event) {
        this.termsAndConditionsChecked = event.target.checked;
    }
    handleSubmit() {
        if(!this.emailInput){
            this.isEmailValid = false;
        }
       /* if(!this.termsAndConditionsChecked){
            this.isTermsAndConditions = true;
        }
        else{
            this.isTermsAndConditions = false;
        } */

        /*

        if (this.emailInput.length <= 0 || !emailInput.validity.valid || !this.termsAndConditionsChecked) {
            return termsAndConditionsHasError;
        }
        if(!this.termsAndConditionsChecked || !this.isEmailValid){
            return;
        }

        */
        let emailInput = this.template.querySelector(`[data-id="emailInput"]`);
       // this.termsAndConditionsHasError = !this.termsAndConditionsChecked;
        if (this.emailInput.length <= 0 || !emailInput.validity.valid ) {
            return termsAndConditionsHasError;
        }
        if( !this.isEmailValid){
            return;
        }
        this.isLoading = true;
        this.showRequestError = false;

        sendForgotEmail({ 
            email: this.emailInput
            
        })
            .then(() => {
                console.log('email test',email);
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                        name: "Check_Password"
                    }
                });
            })
            .catch(() => {
                //this.showRequestError = true;
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                        name: "Check_Password"
                    }
                });
              
            })
            .finally(() => {
                this.isLoading = false;
            })
    }
    get termsAndConditionsClass() {
        return this.termsAndConditionsHasError ? this.TERMS_AND_CONDITIONS_WITH_ERROR : this.TERMS_AND_CONDITIONS_WITHOUT_ERROR;
    }
}