import { LightningElement, api, track } from 'lwc';
import requestCoupon from '@salesforce/apex/BWC_StoreRequestController.requestCoupon';
import UserId from '@salesforce/user/Id';
import PromoSuccessLabel from '@salesforce/label/c.BWC_Promotion_Success';
// Apex methods
import getUserDetails from '@salesforce/apex/MYA_UserDetailsController.getUserDetails';
// Guest flag
import Is_Guest from '@salesforce/user/isGuest';

export default class Bwc_StoreReferalForm extends LightningElement {

    @api storeInfo;
    @api offerMode;
    showThankYou = false;
    meridiumValue = 'AM';
    userId = UserId;
    isGuest = Is_Guest;
    form = {};
    sendtext = false;
    termsAgreed = false;
    onSubmit = false;
    formSubmit = false;
    productId;
    //promoSuccessLabel = PromoSuccessLabel;
    promoSuccessLabelForAppointment = 'A {store} associate will contact you to confirm a fixed date and time for your appointment.'
    contact;
    @track contactFirstName;
    @track contactLastName;
    @track contactEmail;
    @track hasUserInfo = false;

    getUserInformations() {
        getUserDetails({ UserId: this.userId })
            .then(result => {
                this.contact = result[0];
                this.contactFirstName = this.contact.FirstName;
                if (this.contactFirstName) {
                    this.form.firstName = this.contactFirstName;
                }
                this.contactLastName = this.contact.LastName;
                if (this.contactLastName) {
                    this.form.lastName = this.contactLastName;
                }
                this.contactEmail = this.contact.Email;
                if (this.contactEmail) {
                    this.form.email = this.contactEmail;
                }
                //this.hasUserInfo = true; // flag for readonly mode
                console.log('getUserDetails -> this.contact :', this.contact);
            })
            .catch(error => {
                this.error = error;
                console.error('getUserDetails -> error response :', error);
            });
    }

    get meridiumOptions() {
        return [
            { label: 'AM', value: 'AM' },
            { label: 'PM', value: 'PM' }
        ];
    }

    get termsUnchecked() {
        if (!this.termsAgreed && this.onSubmit) {
            return true;
        } else {
            return false;
        }
    }

    connectedCallback() {
        this.productId = localStorage.getItem('productId');
        console.log('Bwc_StoreReferalForm.productId: ', this.productId);
        console.log('Bwc_StoreReferalForm.storeInfo: ', JSON.stringify(this.storeInfo));
        console.log('getUserDetails -> this.isGuest :', this.isGuest);
        if(!this.isGuest) {
            this.getUserInformations();
        }
    }

    handleChange(event) {
        this.onSubmit = false;
        if (event.target.name == 'firstName') {
            this.form.firstName = event.target.value;
        }
        if (event.target.name == 'lastName') {
            this.form.lastName = event.target.value;
        }
        if (event.target.name == 'email') {
            this.form.email = event.target.value;
        }
        if (event.target.name == 'phone') {
            this.form.phone = event.target.value;
        }
        if (event.target.name == 'date') {
            this.form.date = event.target.value;
        }
        if (event.target.name == 'time') {
            this.form.time = event.target.value;
        }
        if (event.target.name == 'sendtext') {
            this.sendtext = !this.sendtext;
            this.form.sendtext = this.sendtext;            
            let inputFields = this.template.querySelectorAll('.phone-validate');
            inputFields[0].reportValidity();
        }
        if (event.target.name == 'termsAgreed') {
            this.termsAgreed = !this.termsAgreed;
            this.form.termsAgreed = this.termsAgreed
        }
    }

    handleStoreInfoClose(e) {
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleRequest() {
        this.onSubmit = true;
        if (!this.isInputValid()) {
            return;
        }
        if (!this.termsAgreed) {
            return;
        }
       this.requestOffer();
    }

    requestOffer() {        
        this.formSubmit = true;
        requestCoupon({
            firstName: this.form.firstName,
            lastName: this.form.lastName,
            email: this.form.email,
            phone: this.form.phone,
            appDate: this.form.date,
            appTime: this.form.time,
            sendText: this.form.sendtext,
            dealerId: this.storeInfo.id,
            productId: this.productId
        })
            .then(response => {
                if (response.success && response.data.length > 0) {
                    console.log('response.data : ', response.data); 
                    if(!this.offerMode) {
                        this.successAppointmentMessage = this.setAppointmentSuccessLabel();
                    }
                    this.successMessage = this.setSuccessLabel();                   
                    this.showThankYou = true;
                    this.formSubmit = false;
                } else {
                    console.error('error : ', response.error);
                    this.formSubmit = false;
                }
            }).catch(error => {
                console.error('error : ', error);
                this.formSubmit = false;
            });
    }

    setAppointmentSuccessLabel() {
        let customSuccessLabel = this.promoSuccessLabelForAppointment.replace('{store}', this.storeInfo.title);
        return customSuccessLabel;
    }

    setSuccessLabel() {
        let mode = this.sendtext ? 'email or text' : 'email';        
        let customLabel = PromoSuccessLabel.replace('{mode}', mode);
        customLabel = customLabel.replace('{store}', this.storeInfo.title);
        customLabel = customLabel.replace('{offer}', this.storeInfo.promoName);
        customLabel = customLabel.replace('{offername}', this.storeInfo.promoName);
        return customLabel;
    }

    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                isValid = false;
            }
            inputField.reportValidity();
        });
        return isValid;
    }
}