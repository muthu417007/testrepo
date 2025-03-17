import { LightningElement, track, api, wire } from 'lwc';
import getDisplayButton from '@salesforce/apex/BWC_DisplayProductButton.bwc_Available';
import getProductValues from '@salesforce/apex/BWC_ADC.getProductValues'
import zipCodeChannel from '@salesforce/messageChannel/zipCodeChange__c';
import { ProductAdapter } from 'commerce/productApi';
import { subscribe, MessageContext } from 'lightning/messageService';
export default class Bwc_displayProductButton extends LightningElement {
    @track zipCode;
    @api productId;
    @api isAvailable;
    @api error;
    @track isPurchasable;
    publisherMessage = '';
    subscription = null;

    @wire(MessageContext)
    messageContext;
    connectedCallback() {
        if (localStorage.getItem('zipcode')) {
            //An Id key is in the local Storage
            this.localStorageZipCode = JSON.parse(localStorage.getItem('zipcode'));
            this.zipCode = this.localStorageZipCode.Zipcode;
            //Clear local storage after getting the values

        }
        this.handleSubscribe();
        console.log('intoChildComponent');
    }

     @wire(getProductValues, { productId: '$productId' })
    wiredData({ error, data }) {
        if (data) {
            console.log('ProductData-->>', data);
            this.isPurchasable = data.productRecord.BWC_IsPurchasable__c;
            this.getData();

        }
        else if (error) {
            console.log('errorinProductVals??', error);
        }
    }
    getData() {
        console.log('productId>>>' + this.productId);
        console.log('zipCodeIntoGetData>>>' + this.zipCode);
        getDisplayButton({ productId: this.productId, postalCodeInstance: this.zipCode })
            .then(result => {
                console.log('res>>>' + result);
                console.log('this.isPurchasableInApexCall>>' + this.isPurchasable);
                if (this.isPurchasable == true && result == true) {
                    console.log('insideIf');
                    this.isAvailable = true;
                }
                else {
                    console.log('insideElse');
                    this.isAvailable = false;
                }
                this.sendAvailablityToParent();
            })
            .catch(error => {
                this.error = error;
                console.log('err>>' + JSON.stringify(this.error));
            })
    }
    sendAvailablityToParent() {
        console.log('availINEvent>>>' + this.isAvailable);
        const selectEvent = new CustomEvent('availableevent', {
            detail: this.isAvailable
        });
        console.log('slectedEVnt>>>' + JSON.stringify(selectEvent));
        console.log('availINEvent2>>>' + this.isAvailable);
        this.dispatchEvent(selectEvent);
    }

    handleSubscribe() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(this.messageContext, zipCodeChannel, (message) => {

            const fullAddress = message.message;
            this.zipCode = fullAddress.Zipcode;
            if (this.zipCode) {
                this.getData();
            }

        });
    }
}