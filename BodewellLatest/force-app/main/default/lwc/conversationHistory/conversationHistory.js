import { LightningElement, api, wire, track } from 'lwc';
import getMessagingSeesions from '@salesforce/apex/MessagingController.getMessagingSeesions';

export default class ConversationHistory extends LightningElement {
    @api recordId;
    @track messageSessions = [];
    loaded = false;

    @wire(getMessagingSeesions, {
        caseId: '$recordId'
    })
    wiredMessages(value) {
        if(value.data){
            this.messageSessions = value.data;
            this.loaded = true;
            console.log('messages: ' + JSON.stringify(this.messageSessions));
        }
    }

}