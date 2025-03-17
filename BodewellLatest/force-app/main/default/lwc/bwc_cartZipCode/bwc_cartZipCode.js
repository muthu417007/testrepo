import { LightningElement, wire, track, api } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import bwc_cartZipCode from '@salesforce/messageChannel/bwc_cartZipCode__c';
import zipCodeChannel from '@salesforce/messageChannel/zipCodeChange__c';
import LightningAlert from "lightning/alert";

export default class Bwc_cartZipCode extends LightningElement {
    subscription;
    subscription2;
    pickUpFlag = false;
    @track zip = '';
    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        if (localStorage.getItem('zipcode')) {
            this.localStorageZipCode = JSON.parse(localStorage.getItem('zipcode'));
            this.zip = this.localStorageZipCode.Zipcode;
            console.log('bwc_cartZipCode CC ' + this.zip);
        }
        this.subscribeToCart();
        this.handleSubscribe();

    }

    //onclick on zip, zip Pop Up should open, parent - bwc_enterZipcodeheader
    handleZipClick() {
        this.dispatchEvent(
            new CustomEvent('openmodal'),
            { bubbles: true, composed: true });
        // console.log("event dispatched");
    }

    //subscriber to check if products are under orderPickUp or not
    subscribeToCart() {
        if (this.subscription) {
            return;
        }

        let previousZip = null;        
        let initialLoadComplete = false;
        let previousHDListEmpty = false;
        let previousPickupListEmpty = false;

        this.subscription = subscribe(this.messageContext, bwc_cartZipCode, (zipCodeInfo) => {
            console.log("ZipCodeInfo@@", JSON.stringify(zipCodeInfo));
            const currentHDListEmpty = !zipCodeInfo.hdList || zipCodeInfo.hdList.length === 0;
            const currentPickupListEmpty = !zipCodeInfo.pickupList || zipCodeInfo.pickupList.length === 0;
            const currentZip = zipCodeInfo.zip;
        
            console.log('::this.zip,previousZip,currentZip,previousHDListEmpty,previousPickupListEmpty,currentHDListEmpty,currentPickupListEmpty,initialLoadComplete', this.zip, previousZip, currentZip, previousHDListEmpty, previousPickupListEmpty,currentHDListEmpty,currentPickupListEmpty, initialLoadComplete);
            if(previousZip === null){
                previousHDListEmpty=!zipCodeInfo.hdList || zipCodeInfo.hdList.length === 0;
                previousPickupListEmpty = !zipCodeInfo.pickupList || zipCodeInfo.pickupList.length === 0;
            } 
            else if (previousZip !== null && previousZip !== currentZip && initialLoadComplete) {
                // currentHDList=zipCodeInfo.hdList; previousHDListEmpty = 
                if (currentHDListEmpty && currentPickupListEmpty && (!previousHDListEmpty || !previousPickupListEmpty)) {
                    LightningAlert.open({
                        message: "We do not offer a local Home Delivery or a Pick up location in your zip code.Please visit a local appliance retailer.",
                        theme: "error",
                        label: ""
                    });
                    
                }          

            }

            this.zip = currentZip;
            this.hdlist = zipCodeInfo.hdList;
            this.pickuplist = zipCodeInfo.pickupList;

            previousZip = currentZip;              
            previousHDListEmpty = currentHDListEmpty;
            previousPickupListEmpty = currentPickupListEmpty;          
            initialLoadComplete = true;

            if (zipCodeInfo.productFlag === false) {

                this.pickUpFlag = true;
                // console.log("flag@@"+this.pickUpFlag);
            }
            else
                this.pickUpFlag = false;

        });
    }

    unsubscribeFromCart() {
        if (this.subscription) {
          unsubscribe(this.subscription);
          this.subscription = null;
        }
      }

    //subscriber to update the updated zip from Zip Pop Up   
    handleSubscribe() {
        if (this.subscription2) {
            return;
        }
        //this.context = createMessageContext();

        this.subscription2 = subscribe(this.messageContext, zipCodeChannel, (message) => {
            const fullAddress = message.message;
            this.zip = fullAddress.Zipcode;
            console.log('ZIP CODE subscribe from bwc_cartZipCode------ ' + this.zip);


        });
    }
}