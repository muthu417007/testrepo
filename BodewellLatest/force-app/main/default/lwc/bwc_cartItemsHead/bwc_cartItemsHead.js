import { LightningElement } from 'lwc';
import bwcCartPage from '@salesforce/messageChannel/bwcCartPage__c';
import basePath from '@salesforce/community/basePath';
import { subscribe,unsubscribe, createMessageContext } from 'lightning/messageService';


export default class Bwc_cartItemsHead extends LightningElement {

    cartQuantity=0;
    cartflag=false;

    context = createMessageContext();

    connectedCallback() {
        this.handleSubscribe();       
    }

     //this Navigation goes back to Home Page from Cart    
     get homeUrl() {
        return basePath;
    }

    handleSubscribe() {
        if (this.subscription) {
            return;
        }
        this.context = createMessageContext();
        this.subscription = subscribe(this.context, bwcCartPage, (message) => {

            this.receivedObjectData = message.myObjectField;
            this.cartQuantity=this.receivedObjectData.cartQuantity;
            this.cartflag=this.receivedObjectData.cartFlag;
        });
    }

    disconnectedCallback() {
        unsubscribe(this.subscription);
    }
}