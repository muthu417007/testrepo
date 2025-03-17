import {api, LightningElement, track, wire} from 'lwc';
import {CurrentPageReference, NavigationMixin} from 'lightning/navigation';
import registerUser from '@salesforce/apex/PS_GEAIdPCommSelfRegCtrl.registerUser';
import getBwcMyaMetaData from '@salesforce/apex/BWC_MYA_Configurations_Controller.getBwcMyaMetaData';
import GEA from './ps_GEAIdPCommSelfRegForm.html';
import Bodewell from './ps_GEAIdPCommSelfRegFormBodewell.html';
import basePath from "@salesforce/community/basePath";
import googleImage from '@salesforce/resourceUrl/googleImage';
import facebookImage from '@salesforce/resourceUrl/facebookImage';


const PASSWORD_SHOULD_CONTAIN_CHARACTER = 'Password should include a letter';
const PASSWORD_SHOULD_CONTAIN_NUMBER = 'Password should include a number';
const PASSWORD_SHOULD_NOT_CONTAIN_SPACE = 'Password should not include white space';
const PASSWORD_SHOULD_CONTAIN_8_CHARS = 'Password should contain 8 characters';
const PASSWORD_SHOULD_CONTAIN_UPPER_CHARACTER = 'Password should contain at least 1 upper case letter';
const PASSWORD_SHOULD_CONTAIN_LOWER_CHARACTER = 'Password should contain at least 1 lower case letter';
const PASSWORD_SHOULD_CONTAIN_SPECIAL_CHAR = 'Password should contain at least 1 special character';

export default class Ps_GEACommRegistrationPage extends NavigationMixin(LightningElement) {
    //Component Configurable Parameters
    @api pageTitleLabel;

    @api emailLabel = 'Email';
    @api emailValidationError = 'Enter a valid email address ex: user@domain.com';

    @api firstNameLabel = 'First Name';
    @api firstNameValidationError = 'First Name is required';
    @api firstNameValidationErrorr = 'First Name Contains Special Characters. Please remove and try again.';

    @api lastNameLabel = 'Last Name';
    @api lastNameValidationError = 'Last Name is required';
    @api lastNameValidationErrorr = 'Last Name Contains Special Characters. Please remove and try again.';

    @api phoneLabel = 'Phone Number';
    @api phoneValidationError = 'Invalid Phone Number value';
    @api phoneLabelBodewell ='Use this in the future to login with a passcode';
    phonePattern = '[0-9]{3}-[0-9]{3}-[0-9]{4}|[0-9]{10}$';
    phonePatternValidationMessage = 'Please Enter a valid 10 Digit Phone Number';

    @api passwordLabel = 'Password';
    @api passwordValidationError = 'Password is required';
    @api passwordStrengthValidationError = 'Password must meet the Strength requirements';

    @api passwordConfirmationLabel = 'Re-Enter Password';
    @api passwordConfirmationIsRequiredValidationError = 'Password Confirmation is required';
    @api passwordsDontMathValidationError = 'Passwords do not match';
    //@api passwordStrengthLabel = 'Your Password must include at least: 8 characters, 1 letter, and 1 number';
    @api passwordStrengthLabel = 'Your Password must include at least: 8 characters, 1 upper and 1 lower case letter, 1 special character and 1 number';

    @api termsAndConditionsURL = 'https://www.geapplianceparts.com/store/html/terms_popup.htm';
    @api termsAndConditionsURLBodewell = 'Terms of Use';
    @api termsAndConditionsURLLabel = 'Terms and Conditions';
    @api termsAndConditionsLabel = `I agree to these `;

    @api privacyPolicyURL = 'https://www.geappliances.com/privacy/privacy_policy.htm?_ga=2.174085666.1639246577.1624274743-1708831636.1623785482';
    @api privacyPolicyURLBodewell = 'Privacy Statement';
    @api privacyPolicyURLLabel = 'GE Appliances Privacy Policy';
    @api privacyPolicyLabel = 'GE Appliances takes your privacy seriously. All information you provide shall be held in strict accordance with the ';

    @api submitButtonLabel = 'CREATE ACCOUNT';
    @api submitButtonLabelOnLoading = 'CREATING YOUR ACCOUNT, PLEASE WAIT...';

    @api signInLabel = 'Sign in here';
    @api signInText = "Have an account already?";
    signInLink = '/s/login/';

    @api
    generalErrorMessage = "Your request cannot be processed at this time. The site administrator has been alerted.";
    generalError = false;

    submitButtonLabelInternal = '';
    submitButtonLabelDefault = '';

    //Internal tracking variables
    @track data = {};

    @track emailHasError = false;
    @track firstNameHasError = false;
    @track firstNameHasErrorr = false;
    @track lastNameHasError = false;
    @track lastNameHasErrorr = false;
    @track phoneHasError = false;
    @track passwordHasError = false;
    @track passwordStrengthHasError = false;
    @track passwordConfirmationHasError = false;
    @track passwordsDontMatch = false;
    @track passwordIsStrong = false;
    @track termsAndConditionsHasError = false;
    @track termsAndConditionsChecked = false;
    @track isLoading = false;
    @track googleAuthUrl = null;
    @track fbAuthUrl = null;

    //Constants
    FORM_ELEMENT_WITH_ERRORS = 'slds-form-element slds-m-bottom_medium slds-has-error';
    FORM_ELEMENT_WITHOUT_ERRORS = 'slds-form-element slds-m-bottom_medium';
    TERMS_AND_CONDITIONS_WITH_ERROR = 'slds-m-top_medium slds-m-bottom_medium terms-and-conditions-required';
    TERMS_AND_CONDITIONS_WITHOUT_ERROR = 'slds-m-top_medium slds-m-bottom_medium';

    currentPageReference = null;
    urlLanguage = null;
    urlRedirectURL = null;
    urlState = null;
    bwcmetadta = null;

    recaptchaResponse;
    _setRecaptchaResponse;
    @api brand = 'GEA';
    phoneNumberHasError;
    render() {
        if (this.brand == "GEA") {
          return GEA;
        } else if (this.brand == "Bodewell") {
            return Bodewell;
          }
        }

        facebookImage =facebookImage;
        googleImage = googleImage;


    connectedCallback() {
        this.submitButtonLabelDefault = this.submitButtonLabel;
        this.submitButtonLabelInternal = this.submitButtonLabel;
        if(this.brand == "Bodewell"){
            this.privacyPolicyURLLabel ='Privacy Policy';
        }
        this.getBwcMyaMetadata();
    }

    onVerified(event){
        this.recaptchaResponse = event.detail.response;
        this.generalError = false;
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            console.log('currentPageReference',currentPageReference);
            console.log('currentPageReference',currentPageReference.state.redirectURL);
            this.urlLanguage = currentPageReference.state.language || null;
            this.urlRedirectURL = currentPageReference.state.redirectURL || null;
            this.urlState = currentPageReference.state.state || null;
            this.setSignInLink();
        }
    }

    getBwcMyaMetadata() {
        getBwcMyaMetaData()
            .then(response => {
                this.bwcmetadta = response;
                this.googleAuthUrl = this.bwcmetadta.Google_auth_url__c;
                this.fbAuthUrl = this.bwcmetadta.Facebook_auth_url__c;
            }).catch(error => {
                console.error('error : ', error);
            });
    }

    setSignInLink(){
        this[NavigationMixin.GenerateUrl]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Login'
            }
        }).then((url) => {
            this.signInLink = url;
        });
    }

    onInputChanged(event) {
        this.data[event.target.name] = event.target.value;
    }
    onInputChangedphone(event) {
        var a = event.target.value;
         var b = a.replace(/[&\/\\#, +()$~%.'":*?<>{}-]/g, "");
         this.data[event.target.name] = b;
         console.log(b);
         console.log(a);
         if( this.brand == "Bodewell") {
         this.isPhoneValid();
          }
    }

    onPasswordChanged(event) {
        this.data[event.target.name] = event.target.value;

        if(this.data.passwordConfirmation && this.data.password !== this.data.passwordConfirmation)
            this.passwordsDontMatch = true;
        else this.passwordsDontMatch = false;
    }

    onPasswordConfirmationChanged(event) {
        this.data.passwordConfirmation = event.target.value;

        if(this.data.passwordConfirmation !== this.data.password) this.passwordsDontMatch = true;
        else this.passwordsDontMatch = false;
    }

    onTermAndConditionsChanged(event) {
        this.termsAndConditionsChecked = event.target.checked;
    }

    register() {
        if(this.validateInputs()) {
            return;
        }

        this.setGeneralError(false);

        this.registeringUser(true);

        const inputParameters = {
            'email': this.data.email,
            'firstName': this.data.firstName,
            'lastName': this.data.lastName,
            'mobilePhone': this.data.phone,
            'password': this.data.password,
            'timeZone': Intl.DateTimeFormat().resolvedOptions().timeZone,
            'language': this.urlLanguage,
            'redirectURL': this.urlRedirectURL,
            'state': this.urlState,
            'recaptchaResponse': this.recaptchaResponse
        }

        let registrationErrorMessage = null;

        registerUser({
            'registrationParameters': inputParameters
        })
            .then(result => {
                const data = JSON.parse(result);
                console.log(data);

                if(data && data.succeed === true) {

                    this[NavigationMixin.GenerateUrl]({
                        type: 'standard__webPage',
                        attributes: {
                            url: data.loginPageReferenceURL
                        }
                    }).then(generatedUrl => {
                        console.log('test -- generatedUrl',generatedUrl);
                        window.location.replace(generatedUrl);

                    });
                    return;
                }

                this.registeringUser(false);
                this.setGeneralError( true);

                this.submitButtonLabelInternal = data.message;
                registrationErrorMessage = data?.message;
            })
            .catch(error => {
                this.registeringUser(false);
                this.setGeneralError( true);
                registrationErrorMessage = error?.body?.message;
            })
            .finally(() => {
                let registrationCompletedEvent = new CustomEvent(
                    "gtm__registrationCompleted",
                    {
                        detail: {
                            registrationError: registrationErrorMessage
                        }
                    }
                );
                document.dispatchEvent(
                    registrationCompletedEvent,
                    {
                        bubbles: true,
                        composed: true
                    }
                );
            });
    }

    registerBodewell() {
        if(this.validateInputs()) {
            return;
        }
        if(!this.urlRedirectURL) {
            this.urlRedirectURL = (this.bwcmetadta != null) ? this.bwcmetadta.Self_register_redirection_URL__c : null;
        }

        this.setGeneralError(false);

        this.registeringUser(true);

        const inputParameters = {
            'email': this.data.email,
            'firstName': this.data.firstName,
            'lastName': this.data.lastName,
            'mobilePhone': this.data.phone,
            'password': this.data.password,
            'timeZone': Intl.DateTimeFormat().resolvedOptions().timeZone,
            'language': this.urlLanguage,
           'redirectURL': this.urlRedirectURL,

            'state': this.urlState,
            'recaptchaResponse': this.recaptchaResponse
        }

        let registrationErrorMessage = null;

        registerUser({
            'registrationParameters': inputParameters
        })
            .then(result => {
                const data = JSON.parse(result);
                console.log(data);

                if(data && data.succeed === true) {

                    this[NavigationMixin.GenerateUrl]({
                        type: 'standard__webPage',
                        attributes: {
                            url: data.loginPageReferenceURL
                        }
                    }).then(generatedUrl => {
                        console.log('test -- generatedUrl',generatedUrl);
                        window.location.replace(generatedUrl);

                    });
                    return;
                }

                this.registeringUser(false);
                this.setGeneralError( true);

                this.submitButtonLabelInternal = data.message;
                registrationErrorMessage = data?.message;
            })
            .catch(error => {
                this.registeringUser(false);
                this.setGeneralError( true);
                registrationErrorMessage = error?.body?.message;
            })
            .finally(() => {
                let registrationCompletedEvent = new CustomEvent(
                    "gtm__registrationCompleted",
                    {
                        detail: {
                            registrationError: registrationErrorMessage
                        }
                    }
                );
                document.dispatchEvent(
                    registrationCompletedEvent,
                    {
                        bubbles: true,
                        composed: true
                    }
                );
            });
    }


    registeringUser(loading) {
        this.isLoading = loading;
    }

    setGeneralError(isError) {
        this.generalError = isError;
    }

    validateInputs() {
        const fields = [
            { name: 'email', validationVarName: 'emailHasError' },
            { name: 'firstName', validationVarName: 'firstNameHasError' },
            { name: 'lastName', validationVarName: 'lastNameHasError' },
            { name: 'phone', validationVarName: 'phoneHasError' },
            { name: 'password', validationVarName: 'passwordHasError' },
            { name: 'passwordConfirmation', validationVarName: 'passwordConfirmationHasError' },
        ];
        
        for (let i = 0; i < fields.length; i++) {
            const field = fields[i];
            const input = this.template.querySelector(`[data-id="${field.name}"]`);
            input.reportValidity();
            this[field.validationVarName] = !input.checkValidity();
        }

        this.passwordsDontMatch = this.data.password !== this.data.passwordConfirmation;
        this.termsAndConditionsHasError = !this.termsAndConditionsChecked;

        this.validatePasswordRequirements();
		this.validateUserNameCharacter();
        this.validateUserNameCharacterlastname();
        this.validatePhoneNumber();
        return this.passwordStrengthHasError || this.passwordHasError || this.firstNameHasErrorr ||this.passwordConfirmationHasError || this.passwordsDontMatch || this.emailHasError || this.firstNameHasError || this.lastNameHasError  || this.lastNameHasErrorr || this.termsAndConditionsHasError || this.phoneNumberHasError;
    }

    validatePhoneNumber(){
         this.phoneNumberHasError = false;
        if( this.brand == "Bodewell") {
            this.phoneNumberHasError = !this.isPhoneValid();
          }
    }

    isPhoneValid() {
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

    validatePasswordRequirements(){
        this.passwordStrengthHasError = false;
        if(this.validatePasswordStrenght()) return;
        if(this.validatePasswordStrengthLowerCharacter()) return;
        if(this.validatePasswordStrengthUpperCharacter()) return;
        //if(this.validatePasswordStrenghtCharacter()) return;
        if(this.validatePasswordStrenghtNumber()) return;
        if(this.validatePasswordStrengthSpecialCharacter()) return;
        this.validatePasswordStrenghtWhiteSpace();
    }

    validatePasswordStrenght() {
        if(!this.data.password || this.data.password.length < 8) {
            this.passwordStrengthHasError = true;
            this.passwordStrengthValidationError = PASSWORD_SHOULD_CONTAIN_8_CHARS;
        }
    }

    validatePasswordStrenghtNumber() {
        var hasNumber = /\d/;
        if(!hasNumber.test(this.data.password)) {
            this.passwordStrengthValidationError = PASSWORD_SHOULD_CONTAIN_NUMBER;
            this.passwordStrengthHasError = true;
        }

        return this.passwordStrengthHasError;
    }

    validatePasswordStrengthLowerCharacter() {
        var hasCharacter = /[a-z]/g;
        if(!hasCharacter.test(this.data.password)) {
            this.passwordStrengthValidationError = PASSWORD_SHOULD_CONTAIN_LOWER_CHARACTER;
            this.passwordStrengthHasError = true;
        }
        
        return this.passwordStrengthHasError;
    }
    validatePasswordStrengthUpperCharacter() {
        var hasCharacter = /[A-Z]/g;
        if(!hasCharacter.test(this.data.password)) {
            this.passwordStrengthValidationError = PASSWORD_SHOULD_CONTAIN_UPPER_CHARACTER;
            this.passwordStrengthHasError = true;
        }
        
        return this.passwordStrengthHasError;
    }
    validatePasswordStrenghtCharacter() {
        var hasCharacter = /[a-zA-Z]/g;
        if(!hasCharacter.test(this.data.password)) {
            this.passwordStrengthValidationError = PASSWORD_SHOULD_CONTAIN_CHARACTER;
            this.passwordStrengthHasError = true;
        }
        
        return this.passwordStrengthHasError;
    }

    validatePasswordStrengthSpecialCharacter() {
        var hasCharacter = /[$&+,:;=?@#|'<>.^*()%!-]/;  // /[@$&+,:]/; 
        if(!hasCharacter.test(this.data.password)) {
            this.passwordStrengthValidationError = PASSWORD_SHOULD_CONTAIN_SPECIAL_CHAR;
            this.passwordStrengthHasError = true;
        }
        
        return this.passwordStrengthHasError;
    }

    validatePasswordStrenghtWhiteSpace() {
        var hasWhiteSpace = /\s/;
        if(hasWhiteSpace.test(this.data.password)) {
            this.passwordStrengthValidationError = PASSWORD_SHOULD_NOT_CONTAIN_SPACE;
            this.passwordStrengthHasError = true;
        }
        
        return this.passwordStrengthHasError;
    }
	//Check the username field charcter pattern
	validateUserNameCharacter() {
        console.log('Inside ValidateUserNameCharater');
        var hasCharacter = /[@!#$%^&*(){}<>?/";:-]/g;
        
        if(this.data.firstName == null || this.data.firstName == ""){
           this.firstNameHasErrorr = false;
        }
        else if(hasCharacter.test(this.data.firstName)) {
            console.log('Inside if: firstNameHasErrorr'+this.firstNameHasErrorr);
            this.firstNameHasErrorr = true;
        }
       else{
           this.firstNameHasErrorr = false;
            console.log('Inside else: firstNameHasErrorr'+this.firstNameHasErrorr);
		}
        console.log('firstNameHasErrorr'+this.firstNameHasErrorr);
        return this.firstNameHasErrorr;
    }
    validateUserNameCharacterlastname() {
        console.log('Inside ValidateUserNameCharaterlastname');
        var hasCharacterln = /[@!#$%^&*(){}<>?/";:-]/g;
        
        if(this.data.lastName == null || this.data.lastName == ""){
           this.lastNameHasErrorr = false;
        }
        else if(hasCharacterln.test(this.data.lastName)) {
            console.log('Inside if: lastNameHasErrorr'+this.lastNameHasErrorr);
            this.lastNameHasErrorr = true;
        }
       else{
           this.lastNameHasErrorr = false;
            console.log('Inside else: lastNameHasErrorr'+this.lastNameHasErrorr);
		}
        console.log('lastNameHasErrorr'+this.lastNameHasErrorr);
        return this.lastNameHasErrorr;
    }

    get emailContainerClass() {
        return this.emailHasError ? this.FORM_ELEMENT_WITH_ERRORS : this.FORM_ELEMENT_WITHOUT_ERRORS;
    }

    get firstNameContainerClass() {
        return this.firstNameHasError ? this.FORM_ELEMENT_WITH_ERRORS : this.FORM_ELEMENT_WITHOUT_ERRORS;
    }

    get lastNameContainerClass() {
        return this.lastNameHasError ? this.FORM_ELEMENT_WITH_ERRORS : this.FORM_ELEMENT_WITHOUT_ERRORS;
    }

    get phoneContainerClass() {
        return this.phoneHasError ? this.FORM_ELEMENT_WITH_ERRORS : this.FORM_ELEMENT_WITHOUT_ERRORS;
    }

    get passwordContainerClass() {
        return this.passwordHasError ? this.FORM_ELEMENT_WITH_ERRORS : this.FORM_ELEMENT_WITHOUT_ERRORS;
    }

    get passwordConfirmationContainerClass() {
        return this.passwordConfirmationHasError || this.passwordsDontMatch ? this.FORM_ELEMENT_WITH_ERRORS : this.FORM_ELEMENT_WITHOUT_ERRORS;
    }

    get termsAndConditionsClass() {
        return this.termsAndConditionsHasError ? this.TERMS_AND_CONDITIONS_WITH_ERROR : this.TERMS_AND_CONDITIONS_WITHOUT_ERROR;
    }
}