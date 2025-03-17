import { LightningElement, api, wire, track } from 'lwc';
import { MessageContext, APPLICATION_SCOPE, publish } from 'lightning/messageService';
import apiDataChannel from "@salesforce/messageChannel/apidatachannel__c";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createMessageContext, releaseMessageContext, subscribe, unsubscribe } from 'lightning/messageService';
import uid from '@salesforce/user/Id';

export default class RelatedFaqs extends LightningElement {

    isFaqsDisplayed=false;
    subscription = null;
    context = createMessageContext();;
    connectedCallback(){
        this.isFaqsDisplayed=true;
        this.handleSubscribe();
    }

    handleSubscribe() {
        if (this.subscription) {
            return;
        }
        this.context = createMessageContext();
        this.subscription = subscribe(this.context, apiDataChannel, (message) => {
            console.log('FAQs component is ' + message);
            let msg = message.messageBody;
            let dt=msg.record;
        }, { scope: APPLICATION_SCOPE });
    }
}