import { LightningElement, api, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import scrollTo from '@salesforce/messageChannel/navTo__c';

export default class NavDownBtn extends LightningElement {
    @api navToName;
    @api label;

    @wire(MessageContext)
    messageContext;

    navTo(){
        const payload = { name: this.navToName };
        publish(this.messageContext, scrollTo, payload);
    }
}