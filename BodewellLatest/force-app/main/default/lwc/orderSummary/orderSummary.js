import { LightningElement, api, track } from 'lwc';
import { createMessageContext, releaseMessageContext, APPLICATION_SCOPE, subscribe, unsubscribe } from 'lightning/messageService';
import orderEventMC from "@salesforce/messageChannel/orderEvents__c";
import orderSearch from "@salesforce/messageChannel/orderSearch__c";

export default class OrderSummary extends LightningElement {
    @api orderpayload;  //New Change
    @api invokedByOrderSummary; //New Change
    @api flexipageRegionWidth;
    @track orderno = '';
    @track customername='';
    @track refno='';
    @track accountdescription='';
    @track accno='';
    @track summarycols = [];
    @track summarydata = [];
    @track phone = '';
    @track shipmethod='';
    @track ordertype='';
    @track ordersource='';
    @track orderdate='';
    @track creationdate='';
    @track requester='';
    @track warehouse='';
    @track reqdate = '';
    @track customerpo = '';
    @track storeno = '';
    @track description = '';
    @track orderstatus = '';
    @track receivedMessage = '';
    @track subscription = null;
    context = createMessageContext();
    @track isDisplayOrderDetail = false;
    connectedCallback() {
        this.isDisplayOrderDetail = false;
        this.handleSubscribe();
    }
    disconnectedCallback() {
        this.handleUnsubscribe();
    }
    handleSubscribe() {
        console.log('inside handler');
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
        if(this.invokedByOrderSummary){
            this.handleMessage({messageBody: this.orderpayload?.messageBody});
        }
    }
    handleMessage(event) {
        if (event) {
            let message = event.messageBody;
            let res = JSON.parse(message);
            let source = event.source;
            this.summarydata = res.ORDERSLIST_LINES_DATA;
            for(let t=0;t<this.summarydata.length;t++){
                this.summarydata[t]["ORDER_SOURCE"]=res.P_OUT_HEADER_VAL_REC.ORDER_SOURCE;
                this.summarydata[t]["CREATION_DATE"]=res.P_OUT_HEADER_REC.CREATION_DATE ? new Date(res.P_OUT_HEADER_REC.CREATION_DATE).toLocaleString('en-US', { timeZone: 'America/New_York', }).split(",")[0] : res.P_OUT_HEADER_REC.CREATION_DATE;
                    
            }
            this.summarycols = [
                { label: 'GEA Order Number(cso)', fieldName: 'ORDER_NUMBER',initialWidth:150 },
                { label: 'Customer Name', fieldName: 'CUSTOMER_NAME',initialWidth:150 },
                { label: 'PO No.', fieldName: 'CUST_PO_NUMBER',initialWidth:150 },
                { label: 'Reference No.', fieldName: 'REFERENCE_NUMBER',initialWidth:150 },
                { label: 'Phone No.', fieldName: 'PHONE_NUMBER' },
                { label: 'Store No.', fieldName: 'STORE_NUMBER' },
                { label: 'Order Status', fieldName: 'ORDER_STATUS',initialWidth:110 },
                { label: 'Order Type', fieldName: 'ORDER_TYPE' },
                { label: 'Order Source', fieldName: 'ORDER_SOURCE' },
                { label: 'Ordered Date', fieldName: 'ORDERED_DATE',initialWidth:150 },
                { label: 'Request Date', fieldName: 'REQUEST_DATE' },
                { label: 'Creation Date', fieldName: 'CREATION_DATE' }
            ];

            this.orderno = res.P_OUT_HEADER_REC.ORDER_NUMBER;
            this.customername=this.summarydata[0].CUSTOMER_NAME;
            this.phone=res.P_OUT_HEADER_REC.ATTRIBUTE8;
            if(res.P_OUT_HEADER_VAL_REC.SHIPPING_METHOD=='OEM ADC Truckload')
                this.phone = res.P_OUT_HEADER_VAL_REC.PHONE_NUMBER;        
            
            this.refno=this.summarydata[0].REFERENCE_NUMBER;
            this.requester=res.P_OUT_HEADER_REC.ATTRIBUTE2;
            if(res.P_OUT_HEADER_REC.WAREHOUSE_NAME?.includes("-")){
                this.warehouse=res.P_OUT_HEADER_REC.WAREHOUSE_NAME.split("-")[1];}
            else{
                this.warehouse=res.P_OUT_HEADER_REC.WAREHOUSE_NAME;}
            this.accno=res.P_OUT_HEADER_VAL_REC.CUSTOMER_NUMBER;
            this.accountdescription=res.P_OUT_HEADER_VAL_REC.ACCOUNT_DESCRIPTION;
            this.ordersource=this.summarydata[0].ORDER_SOURCE;
            this.ordertype=this.summarydata[0].ORDER_TYPE;
            this.orderdate=this.summarydata[0].ORDERED_DATE;
            this.creationdate=this.summarydata[0].CREATION_DATE;
            this.reqdate = this.summarydata[0].REQUEST_DATE;
            this.customerpo = this.summarydata[0].CUST_PO_NUMBER;
            this.storeno = this.summarydata[0].STORE_NUMBER;
            this.orderstatus = this.summarydata[0].ORDER_STATUS;
            this.shipmethod=res.P_OUT_HEADER_VAL_REC.SHIPPING_METHOD;
            this.description = res.P_OUT_HEADER_VAL_REC.ACCOUNT_DESCRIPTION;
            console.log('values are' + res.P_OUT_HEADER_REC.ORDER_NUMBER);
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