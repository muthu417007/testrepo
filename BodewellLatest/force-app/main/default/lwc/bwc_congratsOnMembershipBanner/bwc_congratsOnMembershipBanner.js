import { LightningElement,wire,track } from 'lwc';
import { SessionContextAdapter } from 'commerce/contextApi';
import bwc_membershipSavings from '@salesforce/messageChannel/bwc_membershipSavings__c';
import { MessageContext, subscribe, unsubscribe } from 'lightning/messageService';

export default class Bwc_congratsOnMembershipBanner extends LightningElement {

   @wire(MessageContext)
   messageContext;
   subscription;

   @track memberSavings;
   @track _userName;

   connectedCallback() {
    this.subscription = subscribe(this.messageContext, bwc_membershipSavings, (savings) => {
       if (savings && savings.savings) {
        this.memberSavings=savings.savings;
       }
    });
   
 }
 disconnectedCallback() {
    unsubscribe(this.subscription);
  } 
    
  @wire(SessionContextAdapter)
    wireSessionContext({ data }) {
        if (data) {
            console.log(`Bwc_congratsOnMemberShip::wireSessionContext::data = ${JSON.stringify(data, null, 2)}`);
            this._userName = data.userName;
        }
    }
}