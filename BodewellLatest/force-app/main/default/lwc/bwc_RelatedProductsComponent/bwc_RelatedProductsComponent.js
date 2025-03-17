import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import relatedProducts from '@salesforce/apex/BWC_RelatedProductController.productDetails';

import zipCodeChannel from '@salesforce/messageChannel/zipCodeChange__c';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
export default class Bwc_RelatedProductsComponent extends LightningElement {
    @track productId;
    @track zipCode;
    @track relatedProductData;
    @track currentIndex = 0;
    @track isGreaterSize = false;

    subscription = null;
    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        if (localStorage.getItem('zipcode')) {
            this.localStorageZipCode = JSON.parse(localStorage.getItem('zipcode'));
            this.zipCode = this.localStorageZipCode.Zipcode;
        }
        console.log('this.zipCode' + this.zipCode);
        this.handleSubscribe();
    }

    handleSubscribe() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(this.messageContext, zipCodeChannel, (message) => {
            console.log('date------' + message.message);

            const fullAddress = message.message;
            this.zipCode = fullAddress.Zipcode;
            console.log('zipForRelatedProduct->' + this.zipCode);
        });
    }

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            this.productId = currentPageReference.attributes.recordId;
            console.log('productId', currentPageReference.attributes.recordId);
        }
    }

    @wire(relatedProducts, { productId: '$productId', zipCode: '$zipCode' })
    relatedProductData({ data, error }) {
        if (data) {
            console.log('relatedProductsData ->', data);
            this.relatedProductData = data;
            if(data.length >= 5){
                this.isGreaterSize = true;
            }
        }
        else {
            console.log('error->', error);
        }
    }

    handleClickProduct(){

    }

    get anchorValue() {
        return [this.productId];
    }

     get sliderStyle() {
        return `transform: translateX(-${this.currentIndex * 14}vw);`; // Adjust 20 to 100 / number of images to display
    }

    previousSlide() {
        this.currentIndex = this.currentIndex === 0 ? this.relatedProductData.length - 5 : this.currentIndex - 1;
    }

    nextSlide() {
        this.currentIndex = this.currentIndex === this.relatedProductData.length - 5 ? 0 : this.currentIndex + 1;
    }

}