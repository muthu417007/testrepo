import { LightningElement, api, wire} from 'lwc';
import {subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext} from 'lightning/messageService';
import scrollTo from '@salesforce/messageChannel/navTo__c';

export default class NavTo extends LightningElement {
    @api name;
    subscription;

    @wire(MessageContext)
    messageContext;

    // Encapsulate logic for Lightning message service subscribe and unsubsubscribe
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                scrollTo,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }
    
    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    handleMessage(message) {
        if(this.name === message.name){
            let target = this.template.querySelector(`[data-id="${this.name}"]`);
            target.scrollIntoView({ behavior: "smooth"});
        }
        
    }
}