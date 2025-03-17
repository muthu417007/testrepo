import { LightningElement, api, track } from 'lwc';
import { createMessageContext, releaseMessageContext, APPLICATION_SCOPE, subscribe, unsubscribe } from 'lightning/messageService';
import orderEventMC from "@salesforce/messageChannel/orderEvents__c";
import orderSearch from "@salesforce/messageChannel/orderSearch__c";

export default class OrderDetail extends LightningElement {
    @track receivedMessage = '';
    @track customerName = '';
    @track customerAddress = '';
    @track customerPhone = '';
    @track city = '';
    @track zipcode = '';
    @track state = '';
    @track country = '';
    @track subscription = null;
    context = createMessageContext();
    @track isDisplayOrderDetail = false;
    connectedCallback() {
        this.handleSubscribe();
        this.isDisplayOrderDetail = false;
    }
    disconnectedCallback() {
        this.handleUnsubscribe();
    }
    handleSubscribe() {
        if (this.subscription) {
            return;
        }
        this.context = createMessageContext();
        this.subscription = subscribe(this.context, orderSearch, (message) => {
            console.log('message is' + message);
            this.isDisplayOrderDetail = false;
        }, { scope: APPLICATION_SCOPE });
        this.subscription = subscribe(this.context, orderEventMC, (message) => {
            this.handleMessage(message);
        }, { scope: APPLICATION_SCOPE });
    }
    handleMessage(event) {
        if (event) {
            let message = event.messageBody;
            let res = JSON.parse(message);
            let source = event.source;
            console.log('orderDetail response ' + res);
            if (res.P_OUT_HEADER_VAL_REC.DELIVER_TO_CUSTOMER_NAME) {
                this.customerName = res.P_OUT_HEADER_VAL_REC.DELIVER_TO_CUSTOMER_NAME;
                this.customerAddress = res.P_OUT_HEADER_VAL_REC.DELIVER_TO_ADDRESS1?res.P_OUT_HEADER_VAL_REC.DELIVER_TO_ADDRESS1:null+" "+res.P_OUT_HEADER_VAL_REC.DELIVER_TO_ADDRESS2?res.P_OUT_HEADER_VAL_REC.DELIVER_TO_ADDRESS2:null+" "+res.P_OUT_HEADER_VAL_REC.DELIVER_TO_ADDRESS3?res.P_OUT_HEADER_VAL_REC.DELIVER_TO_ADDRESS3:null+" "+res.P_OUT_HEADER_VAL_REC.DELIVER_TO_ADDRESS4?res.P_OUT_HEADER_VAL_REC.DELIVER_TO_ADDRESS4:null;
                this.city = res.P_OUT_HEADER_VAL_REC.DELIVER_TO_CITY;
                this.state = res.P_OUT_HEADER_VAL_REC.DELIVER_TO_STATE;
                this.country = res.P_OUT_HEADER_VAL_REC.DELIVER_TO_COUNTRY;
                this.zipcode = res.P_OUT_HEADER_VAL_REC.DELIVER_TO_ZIP;
                //this.customerPhone = res.P_OUT_HEADER_REC.ATTRIBUTE8;
            }
            else {
                this.customerName = res.P_OUT_HEADER_VAL_REC.SHIP_TO_CUSTOMER_NAME;
                this.customerAddress = this.customerAddress = res.P_OUT_HEADER_VAL_REC.SHIP_TO_ADDRESS1?res.P_OUT_HEADER_VAL_REC.SHIP_TO_ADDRESS1:null+" "+res.P_OUT_HEADER_VAL_REC.SHIP_TO_ADDRESS2?res.P_OUT_HEADER_VAL_REC.SHIP_TO_ADDRESS2:null+" "+res.P_OUT_HEADER_VAL_REC.SHIP_TO_ADDRESS3?res.P_OUT_HEADER_VAL_REC.SHIP_TO_ADDRESS3:null+" "+res.P_OUT_HEADER_VAL_REC.SHIP_TO_ADDRESS4?res.P_OUT_HEADER_VAL_REC.SHIP_TO_ADDRESS4:null;
                
                this.city = res.P_OUT_HEADER_VAL_REC.SHIP_TO_CITY;
                this.state = res.P_OUT_HEADER_VAL_REC.SHIP_TO_STATE;
                this.country = res.P_OUT_HEADER_VAL_REC.SHIP_TO_COUNTRY;
                this.zipcode = res.P_OUT_HEADER_VAL_REC.SHIP_TO_ZIP;
                //this.customerPhone = res.P_OUT_HEADER_REC.ATTRIBUTE8;


            }
            this.customerPhone = res.P_OUT_HEADER_REC.ATTRIBUTE8;
            if(res.P_OUT_HEADER_VAL_REC.SHIPPING_METHOD=='OEM ADC Truckload')
                this.customerPhone = res.P_OUT_HEADER_VAL_REC.PHONE_NUMBER;        
            
            this.isDisplayOrderDetail = true;
            
        }
    }

    handleUnsubscribe() {
        unsubscribe(this.subscription);
        this.subscription = undefined;
        releaseMessageContext(this.context);
    }
    get subscribeStatus() {
        return this.subscription ? 'TRUE' : 'FALSE';
    }
}