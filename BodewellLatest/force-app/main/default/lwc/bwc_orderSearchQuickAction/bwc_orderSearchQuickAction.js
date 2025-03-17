import { api,track } from 'lwc';
import LightningModal from 'lightning/modal';

export default class Bwc_orderSearchQuickAction extends LightningModal {

    @api label;
    @api size;
    @api orderNumber;
    @api recordId;
    @track isSpinner = true;
    orderFetched;
    payload;
    evtPublished;
    orderPayload;

    handleOrderEventPublish(event){
        console.log('Event Is > ',event.detail);
        this.orderFetched = true;
        this.payload = event.detail;
        console.log('Pay Load Is > ',this.payload);
    }

    handleEventPublished(event){
        console.log('Event Published Is > ',event);
        this.evtPublished = true;
        this.orderPayload = event.detail;
        this.isSpinner = false;
        // this.orderFetched = false;
        console.log('Order Payload Is > ',this.orderPayload);
    }

    handleOrderClicked(){
        this.orderFetched = false;
    }
}