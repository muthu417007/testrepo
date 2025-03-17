import { LightningElement, track, api, wire } from 'lwc';
import updateUserZipcode from '@salesforce/apex/BWC_geolocateZipcodeController.updateUserZipcode';
import USER_ID from '@salesforce/user/Id';
import getAddress from '@salesforce/apex/BWC_geolocateZipcodeController.getAddress';
import getAddressBylatLong from '@salesforce/apex/BWC_geolocateZipcodeController.getZipcodeByLatLong';
import zipCodeChannel from '@salesforce/messageChannel/zipCodeChange__c';
import CART_URL from '@salesforce/label/c.BWC_CartPage';

import { subscribe,publish, MessageContext } from 'lightning/messageService';
export default class Bwc_enterZipcodeheader extends LightningElement {
    @track fullAddress;
    @track zipCode='';
    updatedZipcode;
    @api userId;
   
 
  

    zipCodeLocal;
    @track map = new Map();

    @track error;
 
    @track openModal = false;
    @track isCartPage = false;

    @track isAnotherPage=true
    isPreview = false;
      @api editMode; 
    @wire(MessageContext)
    messageContext;
    publisherMessage = '';
  subscription = null;
   // @track subscription=null;


   
isInSitePreview() {
    let url = document.URL;
    return (url.indexOf('sitepreview') > 0 
        || url.indexOf('livepreview') > 0
        || url.indexOf('live-preview') > 0 
        || url.indexOf('live.') > 0
        || url.indexOf('.builder.') > 0);
}

get hideZipCode() {
    console.log(this.isPreview +' ==='+ this.editMode);
    return  this.isPreview ;
}

    connectedCallback() {
        this.isPreview = this.isInSitePreview();
        console.log(this.isPreview +' ==='+ this.editMode);
        //check if any values were passed in
        // if (sessionStorage.getItem('zipcode')) {
        //     //An Id key is in the session Storage
        //     this.sessionStorageZipCode = JSON.parse(sessionStorage.getItem('zipcode'));
        // }

        if (localStorage.getItem('zipcode')) {
            //An Id key is in the local Storage
            this.localStorageZipCode = JSON.parse(localStorage.getItem('zipcode'));
            this.zipCodeLocal = this.localStorageZipCode.Zipcode;
            //  console.log(' this.zipCodeLocal==' + this.zipCodeLocal);
            //Clear local storage after getting the values
            this.zipCode = this.zipCodeLocal;
            if (this.zipCode) {
                updateUserZipcode({ userId: USER_ID, zipCode: this.zipCode })
                    .then(result => {
                        console.log('user result' + JSON.stringify(result));
                    })
                    .catch(error => {
                        // console.log('user error' + error);
                    })
            }
        }
        // console.log(' sessionStorageOptionId' + JSON.stringify(this.sessionStorageZipCode));
        // console.log(' localStorageOptionId' + JSON.stringify(this.localStorageZipCode));
        if (this.zipCodeLocal === null || this.zipCodeLocal===undefined) {
            //  console.log(' if');
            this.getLocationCord();
        }
        else {
            // console.log(' else');
            this.zipCode = this.zipCodeLocal;
        }

        //cartPage conditional check
        const cartPageURL = CART_URL; 
        const currentURL = `'${window.location.pathname}'`;
    
                
        if (currentURL === cartPageURL) {
            this.isCartPage = true;
            this.isAnotherPage =false;
        }

       // this.subscribeZipChange();
       this.handleSubscribe();


    }
   
    
  handleSubscribe() {
    if (this.subscription) {
      return;
    }
    this.subscription = subscribe(this.messageContext, zipCodeChannel, (message) => {
      console.log('date------' + message.message);
if(message.message!==undefined)
{
    const fullAddress = message.message;
    this.zipCode = fullAddress.Zipcode;
}
   
     
    });
  }
    handleOpenModal() {
        this.openModal = true;
        console.log("openModal in parent");
    }

   /* subscribeZipChange() {

        if (this.subscription) {
            return;
        }
        this.subscription =
            subscribe(this.messageContext, bwc_popUpZipCode, (flagVal) => {
                
                // setTimeout(() => {

                    console.log("Modal Call from subscriber: " + JSON.stringify(flagVal.isFlagTrue));

                    this.handleZipCode(flagVal.isFlagTrue);
                    console.log("Zip Sub called");

                // }, 1000);

            },{ scope: APPLICATION_SCOPE });

    }

    handleZipCode(flagValue) {
        // let flagCondition=flagVal;
        if (flagValue === true) {
            this.openModal = true;
        }
    } */

    getLocationCord() {
        if (navigator.geolocation) {


            navigator.geolocation.getCurrentPosition(position => {
                this.searchCoordinates = position.coords.latitude + ',' + position.coords.longitude;
                getAddressBylatLong({ latLong: this.searchCoordinates })
                    .then(result => {
                        // console.log('zipcode result===' + result);

                        this.apiResponseParser(result);

                    })
                    .catch(error => {
                        // console.log(error);
                    })



            }, error => {
                console.log('location denied===' + error.message);

this.openModal=true;
                updateUserZipcode({ userId: USER_ID, zipCode: '40222' })
                    .then(result => {
                        console.log('user result' + JSON.stringify(result));
                    })
                    .catch(error => {
                        // console.log('user error' + error);
                    })

            });
        }
        else{
            console.log('location denied===' + error.message);

            this.openModal=true;
        }

    }

    closeModal(event) {
        this.openModal = false;
        this.error = '';
        if(this.localStorageZipCode.Zipcode!==undefined)
        {
            this.zipCode = this.localStorageZipCode.Zipcode;
        }
      
    }
    openModalHandel(event) {
        this.openModal = true;
    }
    changeZipCodeHandler(event) {
        this.updatedZipcode = this.template.querySelector('input').value;
        //console.log("this.updatedZipcode===" + this.updatedZipcode);
        this.zipCode = this.updatedZipcode;
        getAddress({ zipCode: this.updatedZipcode })
            .then(result => {

                this.apiResponseParser1(result);


            })
            .catch(error => {
                // console.log(error);
            })



    }


    apiResponseParser(response) {
        const jsonObject = JSON.parse(response);
        if (jsonObject.status === 'OK') {
            let addressComponents = jsonObject.results[0].address_components;
            for (let key in addressComponents) {
                if (addressComponents[key].types.includes('postal_code')) {
                    // Add values to the map
                    this.map.set('Zipcode', addressComponents[key].long_name);


                }
                if (addressComponents[key].types.includes('locality')) {
                    this.map.set('City', addressComponents[key].long_name);

                }
                if (addressComponents[key].types.includes('administrative_area_level_1')) {
                    this.map.set('State', addressComponents[key].long_name);

                }
                if (addressComponents[key].types.includes('country')) {
                    this.map.set('Country', addressComponents[key].long_name);

                }





            }

            // console.log('this.this.map' + this.map);
            var obj = Object.fromEntries(this.map);
            var jsonString = JSON.stringify(obj);
            this.fullAddress = JSON.parse(jsonString);
            this.zipCode = this.fullAddress.Zipcode;
            if (this.zipCode) {
                updateUserZipcode({ userId: USER_ID, zipCode: this.zipCode })
                    .then(result => {
                        console.log('user result' + JSON.stringify(result));
                    })
                    .catch(error => {
                        // console.log('user error' + error);
                    })
            }

        }

    }

    apiResponseParser1(response) {
        const jsonObject = JSON.parse(response);
        if (jsonObject.status === 'OK') {

            this.error = '';
            this.openModal = false;
            let addressComponents = jsonObject.results[0].address_components;
            for (let key in addressComponents) {
                if (addressComponents[key].types.includes('postal_code')) {
                    // Add values to the map
                    this.map.set('Zipcode', addressComponents[key].long_name);


                }
                if (addressComponents[key].types.includes('locality')) {
                    this.map.set('City', addressComponents[key].long_name);

                }
                if (addressComponents[key].types.includes('administrative_area_level_1')) {
                    this.map.set('State', addressComponents[key].long_name);

                }
                if (addressComponents[key].types.includes('country')) {
                    this.map.set('Country', addressComponents[key].long_name);

                }





            }

            // console.log('this.this.map' + this.map);
            var obj = Object.fromEntries(this.map);
            var jsonString = JSON.stringify(obj);
            this.fullAddress = JSON.parse(jsonString);
            this.zipCode = this.fullAddress.Zipcode;
            //  console.log('address' + this.fullAddress);
            // this.sendCodeToParent();
            this.sendCodeToParentUpdatedZip();
            //set sessionStorage and localStorage values
            sessionStorage.setItem('zipcode', JSON.stringify(this.fullAddress))
            localStorage.setItem('zipcode', JSON.stringify(this.fullAddress));

            if (this.zipCode) {
                updateUserZipcode({ userId: USER_ID, zipCode: this.zipCode })
                    .then(result => {
                        console.log('user result' + JSON.stringify(result));
                    })
                    .catch(error => {
                        // console.log('user error' + error);
                    })
            }

        }
        else {
            this.error = 'Enter Valid Zip Code';
        }

    }
    sendCodeToParentUpdatedZip() {
        //console.log('message dispatched New');
        let message = { message: this.fullAddress };
        publish(this.messageContext, zipCodeChannel, message);

    }
}