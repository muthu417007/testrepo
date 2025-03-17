import { LightningElement, track, api } from 'lwc';
import updateUserZipcode from '@salesforce/apex/BWC_geolocateZipcodeController.updateUserZipcode';
import USER_ID from '@salesforce/user/Id';
export default class Bwc_enterZipCodeHomePage extends LightningElement {
    @track zipCode;
  updatedZipcode;
    @api userId;
    openModal = false;
    zipCodeLocal;
    connectedCallback() {
   //check if any values were passed in
   if(sessionStorage.getItem('zipcode')){
    //An Id key is in the session Storage
    this.sessionStorageZipCode = JSON.parse(sessionStorage.getItem('zipcode'));
//this.zipCode=this.sessionStorageZipCode.Zipcode;
    //Clear session storage after getting the Id
   
}

if(localStorage.getItem('zipcode')){
    //An Id key is in the local Storage
    this.localStorageZipCode = JSON.parse(localStorage.getItem('zipcode'));
    this.zipCodeLocal=this.localStorageZipCode.Zipcode;
    console.log(' this.zipCodeLocal=='+ this.zipCodeLocal);
    //Clear local storage after getting the values

}
console.log(' sessionStorageOptionId'+this.sessionStorageZipCode);
console.log(' localStorageOptionId'+this.localStorageZipCode);


        this.template.addEventListener('zipCodeEvent', this.handleCustomEvent.bind(this));
    }

    handleCustomEvent(event) {
        const fullAddress = event.detail;
        if(this.zipCodeLocal!==null)
        {
            this.zipCode=this.zipCodeLocal;
        }
        else
        {
            this.zipCode = fullAddress.Zipcode;
        }
      
        if (this.zipCode) {
            updateUserZipcode({ userId: USER_ID, zipCode: this.zipCode })
                .then(result => {
                console.log('user result' + result);
                })
                .catch(error => {
                   // console.log('user error' + JSON.stringify(error));
                })
        }
    }

    closeModal(event) {
        this.openModal = false;
    }
    openModalHandel(event) {
        this.openModal = true;
    }
    changeZipCodeHandler(event) {
        this.updatedZipcode = this.template.querySelector('input').value;
       // console.log("this.updatedZipcode===" + this.updatedZipcode);
   
    this.template.querySelector('c-bwc_geolocate-zipcode').sendCodeToParentUpdated(this.updatedZipcode);
        this.openModal = false;
        if (this.updatedZipcode) {
            updateUserZipcode({ userId: USER_ID, zipCode: this.updatedZipcode })
                .then(result => {
//console.log('user result' + result);
                })
                .catch(error => {
                   // console.log('user error' + error);
                })
        }
    }
 
}