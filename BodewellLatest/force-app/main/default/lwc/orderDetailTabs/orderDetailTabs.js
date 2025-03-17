import { LightningElement, api, track, wire } from 'lwc';
import { createMessageContext, releaseMessageContext, APPLICATION_SCOPE, subscribe, unsubscribe } from 'lightning/messageService';
import orderEventMC from "@salesforce/messageChannel/orderEvents__c";
import orderSearch from "@salesforce/messageChannel/orderSearch__c";
import HomeDepotNotes from '@salesforce/apex/THD_MDO_OrdersData.homeDepotNotes';
//Agent S
import { updateRecord } from 'lightning/uiRecordApi';
import getOrderDetails from '@salesforce/apex/BWC_PartsSearchController.getOrderStatus';
import STATUS_FIELD from "@salesforce/schema/Order.Status";
import ID_FIELD from "@salesforce/schema/Order.Id";
//Agent E

export default class OrderDetailTabs extends LightningElement {
    @track ep = '';
    @track hastrackingno = false;
    @track ordernumber = '';
    @track homedelivery = false;
    @track ordersummary = [];
    @track deliverydata = [];
    @track ordercolumns = [];
    @track shippingdata = [];
    @track deliverycolumns = [];
    @track shippingcolumns = [];
    @track receivedMessage = '';
    @track tracktrace = [];
    @track tracktracecolumns = [];
    @track subscription = null;
    @track homedeliveryurl = '';
    @track HDurls = [];
    @api orderpayload; //New Change
    @api invokedByOrderSummary; //New Change
    //Agent S
    @api recordId;
    @track orderId;
    @track orderStatus;
    //Agent E
    context = createMessageContext();
    @track isDisplayOrderDetail = false;
    connectedCallback() {
        HomeDepotNotes()
            .then((res) => {
                for (let t = 0; t < res.length; t++) {
                    if (res[t].Name == 'HomeDelivery')
                        this.homedeliveryurl = res[t].Url;
                    else
                        this.ep = res[t].Url;
                }
                this.handleSubscribe();
                //this.ep = 'https://deliveryinfo.geappl.io/results.html';
                //console.log(res[0].Name + 'HDO endpoint is ' + res.length);
            });
        this.isDisplayOrderDetail = false;
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
            console.log('message is' ,message);
            this.isDisplayOrderDetail = false;
        }, { scope: APPLICATION_SCOPE });
        this.subscription = subscribe(this.context, orderEventMC, (message) => {
            this.handleMessage(message);
        }, { scope: APPLICATION_SCOPE });
        console.log('Order Payload Is > ', this.orderpayload.messageBody);
        if (this.invokedByOrderSummary) {
            this.handleMessage({ messageBody: this.orderpayload.messageBody });
        }
    }
    async handleMessage(event) {
        if (event) {
            console.log('Message Body in Order Detail Tabs > ', event.messageBody);
            //Agent S
            if(this.invokedByOrderSummary){
                const data = await getOrderDetails({orderSummaryId: this.recordId})
                this.orderId = data[0].OriginalOrder.Id;
                this.orderStatus = data[0].OriginalOrder.Status;
            }
            //Agent E
            let message = event.messageBody;
            let res = JSON.parse(message);
            let source = event.source;
            this.ordersummary = res.P_OUT_LINE_TBL.P_OUT_LINE_TBL_ITEMS;
            this.deliverydata = res.P_OUT_LINE_VAL_TBL.P_OUT_LINE_VAL_TBL_ITEMS;
            this.shippingdata = res.P_SHIP_SET_INFO_TAB.P_SHIP_SET_INFO_TAB_ITEMS;
            this.homedelivery = false;
            this.hastrackingno = false;
            this.HDurls = [];
            //let columns=Object.keys(this.ordersummary[0]);
            if (this.ordersummary != null) {
                for (let x = 0; x < this.ordersummary.length; x++) {
                    this.deliverydata[x]["LINE_NUMBER"] = this.ordersummary[x]["LINE_NUMBER"];
                    this.ordersummary[x]["SHIPPING_METHOD"] = this.deliverydata[x]["SHIPPING_METHOD"];
                    this.ordersummary[x]["INVENTORY_ITEM"] = this.deliverydata[x]["INVENTORY_ITEM"];
                    if (this.ordersummary[x]["CUSTOMER_JOB"] != null) {
                        this.hastrackingno = true;
                        this.ordersummary[x]["TrackingLabel"] = 'Click here';
                        this.ordersummary[x]["Trackurl"] = this.ep + '?GEMSNO=' + this.ordersummary[x]["CUSTOMER_JOB"];
                    }
                }
                for (let x = 0; x < this.ordersummary.length; x++) {
                    if ("SHIP_SET_DETAILS" in this.shippingdata[x] && this.shippingdata[x].SHIP_SET_DETAILS != null)
                        this.ordersummary[x]["SHIP_SET"] = this.shippingdata[x].SHIP_SET_DETAILS.SHIP_SET;
                }
            }
            this.ordercolumns = [
                { label: 'Line', fieldName: 'LINE_NUMBER' },
                /*{
                    label: 'Tracking ID',
                    initialWidth:150,
                    fieldName: 'CUSTOMER_JOB',
                    type: 'url',
                    typeAttributes: {
                        label: { fieldName: 'TrackingLabel' },
                        target: '_blank'
                    }
                },  */
                { label: 'Tracking Number', fieldName: 'CUSTOMER_JOB', initialWidth: 150 },
                { label: 'Ordered Item', fieldName: 'ORDERED_ITEM', initialWidth: 150 },
                { label: 'Qty', fieldName: 'ORDERED_QUANTITY' },
                { label: 'Status', fieldName: 'FLOW_STATUS_CODE', initialWidth: 150 },
                { label: 'Ship Method', fieldName: 'SHIPPING_METHOD', initialWidth: 150 },
                { label: 'GED', fieldName: 'CUSTOMER_SHIPMENT_NUMBER' },
                { label: 'Ship Set', fieldName: 'SHIP_SET' },
                { label: 'Item Description', fieldName: 'INVENTORY_ITEM', initialWidth: 200 }
            ];
            this.shippingcolumns = [
                { label: 'Line', fieldName: 'LINE_NUMBER' },
                { label: 'Ordered Item', fieldName: 'ORDERED_ITEM', initialWidth: 150 },
                { label: 'Request Date', fieldName: 'REQUEST_DATE' },
                { label: 'Schedule Arrival Date', fieldName: 'SCHEDULE_ARRIVAL_DATE' },
                { label: 'Schedule Ship Date', fieldName: 'SCHEDULE_SHIP_DATE' },
                { label: 'Serial No.', fieldName: 'SERIAL_NUMBER' },
                { label: 'Shipped Quantity', fieldName: 'SHIPPED_QUANTITY', initialWidth: 100 },
                { label: 'Reserved Quantity', fieldName: 'RESERVED_QUANTITY', initialWidth: 100 },
                { label: 'Shipping Instructions', fieldName: 'SHIPPING_INSTRUCTIONS', initialWidth: 160 }

            ]
            this.deliverycolumns = [
                { label: 'Line', fieldName: 'LINE_NUMBER' },
                { label: 'Ordered Item', fieldName: 'ORDERED_ITEM', initialWidth: 150 },
                { label: 'Customer Name', fieldName: 'SHIP_TO_CUSTOMER_NAME', initialWidth: 160 },
                { label: 'Number', fieldName: 'SHIP_TO_CUSTOMER_NUMBER' },
                { label: 'Address', fieldName: 'Address', initialWidth: 180 },
                { label: 'Location', fieldName: 'SHIP_TO_LOCATION' },
                { label: 'City', fieldName: 'SHIP_TO_CITY' },
                { label: 'Zipcode', fieldName: 'SHIP_TO_ZIP' },
                { label: 'Contact', fieldName: 'SHIP_TO_CONTACT' },
                //{ label: 'Agent Contact', fieldName: 'ATTRIBUTE8',initialWidth:180 },

            ]
            this.tracktracecolumns = [
                { label: 'Line', fieldName: 'LINE_NUMBER' },
                { label: 'Tracking Number', fieldName: 'CUSTOMER_JOB' },
                {
                    label: 'URL',
                    initialWidth: 150,
                    fieldName: 'Trackurl',
                    type: 'url',
                    typeAttributes: {
                        label: { fieldName: 'TrackingLabel' },
                        target: '_blank'
                    }
                },
            ]
            if (this.ordersummary != null) {
                for (let t = 0; t < this.ordersummary.length; t++) {
                    if (this.ordersummary[t].SCHEDULE_SHIP_DATE) {
                        const sdate = new Date(this.ordersummary[t].SCHEDULE_SHIP_DATE);
                        const shipdate = sdate.toLocaleString('en-US', {
                            timeZone: 'America/New_York',
                        }).split(",")[0];
                        this.ordersummary[t].SCHEDULE_SHIP_DATE = shipdate;
                    }
                    if (this.ordersummary[t].SCHEDULE_ARRIVAL_DATE) {
                        const adate = new Date(this.ordersummary[t].SCHEDULE_ARRIVAL_DATE);
                        const arrivaldate = adate.toLocaleString('en-US', {
                            timeZone: 'America/New_York',
                        }).split(",")[0];
                        this.ordersummary[t].SCHEDULE_ARRIVAL_DATE = arrivaldate;
                    }
                    if (this.ordersummary[t].REQUEST_DATE) {
                        const rdate = new Date(this.ordersummary[t].REQUEST_DATE);
                        const reqdate = rdate.toLocaleString('en-US', {
                            timeZone: 'America/New_York',
                        }).split(",")[0];
                        this.ordersummary[t].REQUEST_DATE = reqdate;
                    }
                    if (this.ordersummary[t].FROM_SERIAL_NUMBER.FROM_SERIAL_NUMBER_ITEMS != null) {
                        this.ordersummary[t].SERIAL_NUMBER = this.ordersummary[t].FROM_SERIAL_NUMBER.FROM_SERIAL_NUMBER_ITEMS[0].FM_SERIAL_NUMBER;
                    }
                }
            }
            if (this.deliverydata != null) {

                for (let x = 0; x < this.deliverydata.length; x++) {
                    this.deliverydata[x]["Address"] = this.deliverydata[x].SHIP_TO_ADDRESS1 ? this.deliverydata[x].SHIP_TO_ADDRESS1 + "," : null + "" + this.deliverydata[x].SHIP_TO_ADDRESS2 ? this.deliverydata[x].SHIP_TO_ADDRESS2 + "," : null + "" + this.deliverydata[x].SHIP_TO_ADDRESS3 ? this.deliverydata[x].SHIP_TO_ADDRESS3 + "," : null + "" + this.deliverydata[x].SHIP_TO_ADDRESS4 ? this.deliverydata[x].SHIP_TO_ADDRESS4 : null;//this.deliverydata[x].SHIP_TO_ADDRESS1 ? this.deliverydata[x].SHIP_TO_ADDRESS2 ? this.deliverydata[x].SHIP_TO_ADDRESS3 ? this.deliverydata[x].SHIP_TO_ADDRESS4 ? this.deliverydata[x].SHIP_TO_ADDRESS1 + ', ' + this.deliverydata[x].SHIP_TO_ADDRESS2 + ', ' + this.deliverydata[x].SHIP_TO_ADDRESS3 + ', ' + this.deliverydata[x].SHIP_TO_ADDRESS4 : this.deliverydata[x].SHIP_TO_ADDRESS1 + ', ' + this.deliverydata[x].SHIP_TO_ADDRESS2 + ', ' + this.deliverydata[x].SHIP_TO_ADDRESS3 : this.deliverydata[x].SHIP_TO_ADDRESS1 + ', ' + this.deliverydata[x].SHIP_TO_ADDRESS2 : this.deliverydata[x].SHIP_TO_ADDRESS1 : null;
                    this.deliverydata[x]["ATTRIBUTE8"] = res.P_OUT_HEADER_REC.ATTRIBUTE8;
                    this.deliverydata[x]["ORDERED_ITEM"] = this.ordersummary[x].ORDERED_ITEM;
                }
            }
            if (res.P_OUT_HEADER_VAL_REC.SHIPPING_METHOD == 'OEM ADC Truckload')
                this.deliverycolumns.push({ label: 'Agent Contact', fieldName: 'ATTRIBUTE8', initialWidth: 180 });
            if (res.P_OUT_HEADER_VAL_REC.SHIPPING_METHOD == 'Home Delivery') {
                const HDphones = res.P_OUT_HEADER_REC.ATTRIBUTE8.split(",");
                const zipcode = res.P_OUT_HEADER_VAL_REC.SHIP_TO_ZIP.split("-")[0];
                for (let i = 0; i < HDphones.length; i++) {
                    this.HDurls[i] = this.homedeliveryurl + '?phoneNumber=' + HDphones[i] + '&zipCode=' + zipcode;
                }
                this.homedelivery = true;
            }
            this.isDisplayOrderDetail = true;
            //Agent S
            if(this.invokedByOrderSummary){
                if(this.orderStatus.toLowerCase() !== res.P_OUT_HEADER_REC.FLOW_STATUS_CODE.toLowerCase()){
                    this.updateOrderStatus(res.P_OUT_HEADER_REC.FLOW_STATUS_CODE);
                }
            }
            //Agent E
        }
    }

    //Agent S
    updateOrderStatus(status){
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.orderId;
        fields[STATUS_FIELD.fieldApiName] = status;

        const recordInput = {
            fields: fields
        };
      
        updateRecord(recordInput).then((record) => {
            console.log('Record updated->');
        });
        
    }
    //Agent E

    handleUnsubscribe() {
        unsubscribe(this.subscription);
        this.subscription = undefined;
        releaseMessageContext(this.context);
    }
    get subscribeStatus() {
        return this.subscription ? 'TRUE' : 'FALSE';
    }

}