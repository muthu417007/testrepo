import { LightningElement, api, wire, track } from 'lwc';
import OrdersAPIData from '@salesforce/apex/THD_MDO_OrdersData.ordersData';
import OrderDetailAPIData from '@salesforce/apex/THD_MDO_OrdersData.orderDetails';
import { MessageContext, APPLICATION_SCOPE, publish } from 'lightning/messageService';
import orderEventMC from "@salesforce/messageChannel/orderEvents__c";
import orderSearch from "@salesforce/messageChannel/orderSearch__c";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createMessageContext, releaseMessageContext, subscribe, unsubscribe } from 'lightning/messageService';
import { NavigationMixin } from 'lightning/navigation';
export default class OrdersData extends LightningElement {
  @api invokedByOrderSummary;
  @api ordrnumber;
  @api flexipageRegionWidth;
  @api payload;
  @wire(MessageContext)
  context;
  @track displyflag = true;
  order_cols = [];
  @track orderslength = 0;
  order_columns = [];
  @track orderdata = [];
  @track orderrecords = [];
  @track order_colOptions = [];
  @track OrdersLoading = false;
  @track error = null;
  @track expandview = false;
  @track splitview = true;
  @track subscription = null;
  @track orderscache = {};

  defaultSortDirection = 'asc';
  sortDirection = 'asc';
  sortedBy;
  contextsubscribe = createMessageContext();

  async connectedCallback() {
    this.displyflag = !this.invokedByOrderSummary;
    console.log('order data subscription');
    console.log('InvokedByOrder Summary In OrdersData > ',this.invokedByOrderSummary);
    await this.handleSubscribe();

  }
  disconnectedCallback() {
    this.handleUnsubscribe();
  }

  handlePublish(event) {
    //let orderno=event.target.dataset.item;
    /*await this[NavigationMixin.Navigate]({
      type: 'standard__navItemPage',
      attributes: {
          apiName: 'Test'
      }
      
    });*/
    console.log('Inside Handle Publish  > ');
    let orderno = event.currentTarget.dataset.value;
    this.orderDetailAPICall(orderno);
  }
  /*this.invokeWorkspaceAPI('isConsoleNavigation').then(isConsole => {
    if (isConsole) {
      console.log('inside invoke method');
      this.invokeWorkspaceAPI('getFocusedTabInfo').then(focusedTab => {
        console.log('inside workspace API 2');
        this.invokeWorkspaceAPI('openSubtab', {
          parentTabId: focusedTab.tabId,
          recordId: orderno,
          focus: true
        }).then(tabId => {
          console.log("Solution #2 - SubTab ID: ", tabId);
        });
      });
    }
  });*/
  orderDetailAPICall(orderNumber) {
    this.OrdersLoading = true;
    let orderno = orderNumber;
    console.log('Inside orderDetailAPICall orderNumber > ',orderNumber);
    if ('"' + orderno + '"' in this.orderscache) {
      console.log("order no.-" + orderno);
      let cacheres = this.orderscache['"' + orderno + '"'];
      this.OrdersLoading = false;
      this.expandview = false;
      //this.orderscache['"'+orderno+'"']=jsonResponse1;
      let jsonResponse = JSON.stringify(cacheres);
      //console.log('res is '+result);
      let payload = {
        source: "LWC",
        messageBody: jsonResponse
      };
      console.log('payload published success:cache');
      publish(this.context, orderEventMC, payload);
      this.dispatchEvent(new CustomEvent('eventpublished', {
        detail: payload
      }));
    }
    else {
      console.log('order number');
      //this.orderscache['"'+orderno+'"']="Hi";

      OrderDetailAPIData({ orderNumber: orderno })
        .then((jsonData) => {
          //console.log('orderdetailresponse received '+jsonResponse);
          this.OrdersLoading = false;
          this.expandview = false;
          let jsonResponse1 = JSON.parse(jsonData);
          console.log('resp ::- ' + jsonResponse1);
          var result = this.orderdata.filter((x) => x.ORDER_NUMBER == orderno);
          console.log('orderno ' + result[0].ORDER_NUMBER);
          jsonResponse1.P_OUT_HEADER_VAL_REC["PHONE_NUMBER"] = result[0].PHONE_NUMBER;
          jsonResponse1["ORDERSLIST_LINES_DATA"] = result;
          console.log('phone no;' + jsonResponse1.P_OUT_HEADER_VAL_REC["PHONE_NUMBER"]);
          //jsonResponse1.P_OUT_HEADER_REC["PHONE_NUMBER"]=result[0].PHONE_NUMBER;
          /*if("TRACKING_NUMBER" in result[0])
          
            jsonResponse1["ORDERSLIST_LINES_DATA"]=result;
          else
          jsonResponse1.P_OUT_HEADER_REC["TRACKING_NUMBER"]=null;*/
          //jsonResponse.P_OUT_LINE_VAL_TBL.P_OUT_LINE_VAL_TBL_ITEMS[0]["ORDER_NUMBER"]=result[0].ORDER_NUMBER;
          /*if("ORDER_STATUS" in result[0])
            jsonResponse1.P_OUT_HEADER_REC["ORDER_STATUS"]=result[0].ORDER_STATUS;
          else
          jsonResponse1.P_OUT_HEADER_REC["ORDER_STATUS"]=null;*/
          //jsonResponse.P_OUT_LINE_VAL_TBL.P_OUT_LINE_VAL_TBL_ITEMS[0]["CUST_PO_NUMBER"]=result[0].CUST_PO_NUMBER;
          //jsonResponse.P_OUT_LINE_VAL_TBL.P_OUT_LINE_VAL_TBL_ITEMS[0]["REQUEST_DATE"]=result[0].REQUEST_DATE;
          this.orderscache['"' + orderno + '"'] = jsonResponse1;
          let jsonResponse = JSON.stringify(jsonResponse1);
          //console.log('res is '+result);
          let payload = {
            source: "LWC",
            messageBody: jsonResponse
          };
          console.log('payload published success');
          this.dispatchEvent(new CustomEvent('eventpublished', {
            detail: payload
          }));
          publish(this.context, orderEventMC, payload);
        })
        .catch((error) => {
          console.log('error occured while calling orderdetail ' + error);
        })
    }


  }

  listView() {
    this.expandview = true;
  }
  handleOnselect(event) {
    const val = event.detail.value;
    console.log('actual value is ' + val);
    if (val == 'completeview') {
      this.expandview = true;
    }
    else {
      this.expandview = false;
      this.splitview = true;

    }

  }
  handleLoading() {
    this.OrdersLoading = true;
  }
  handleDoneLoading() {
    this.OrdersLoading = false;
  }
  /*invokeWorkspaceAPI(methodName, methodArgs) {
    return new Promise((resolve, reject) => {
      console.log('API Defination');
      const apiEvent = new CustomEvent("internalapievent", {
        bubbles: true,
        composed: true,
        cancelable: false,
        detail: {
          category: "workspaceAPI",
          methodName: methodName,
          methodArgs: methodArgs,
          callback: (err, response) => {
            if (err) {
              console.log('ret  errror##'+err);
                return reject(err);
            } else {
              console.log('Actual res@@#'+response);
                return resolve(response);
            }
          }
        }
      });
 
      window.dispatchEvent(apiEvent);
    });
  }*/

  handleSubscribe() {
    //this.displyflag=true;
    //this.OrdersLoading = true;
    console.log('ordersearch::', this.subscription);
    if (this.subscription) {
      return;
    }
    this.contextsubscribe = createMessageContext();
    console.log('Context Subscribe > ',this.contextsubscribe,' Order Search Is > ',orderSearch);
    this.subscription = subscribe(this.contextsubscribe, orderSearch, (message) => {
      console.log('Message In Subscribe > ',message);
      this.searchItem(message);
    }, { scope: APPLICATION_SCOPE });
    console.log('Subscription Is > ',this.subscription);
    if(this.invokedByOrderSummary){
      console.log('Payload to call > ',this.payload);
      this.searchItem(this.payload);
    }
  }

  searchItem(event) {
    try {
      console.log('Search Item Entered > ');
      let message = event.messageBody;
      //let flg=event.source;
      console.log('Message In Search Item is > ',message);
      let payload = message.record;
      this.order_colOptions = [];
      if(!this.invokedByOrderSummary){
        this.displyflag = true;
      }
      this.OrdersLoading = true;

      //OrdersAPIData({ poNumber: payload })
      //.then((jsonResponse) => {
      this.OrdersLoading = false;
      //let temp=JSON.parse(jsonResponse);
      let temp = JSON.parse(payload);
      let orders = temp.P_GET_HEADER_TAB.P_GET_HEADER_TAB_ITEM;
      if (orders == null) {
        this.OrderLoading = false;
      if(!this.invokedByOrderSummary){
        this.displyflag = true;
      }
        this.order_columns = [];
        this.orderdata = [];
        this.orderslength = 0;
        //this.error = error.error;

        const evt = new ShowToastEvent({
          title: 'No Orders Found.',
          message: 'No Orders Found for given input.',
          variant: 'error',
        });
        dispatchEvent(evt);
      }
      else {
        const evt = new ShowToastEvent({
          title: 'Success',
          message: 'Orders data retrived.',
          variant: 'success',
        });
        dispatchEvent(evt);

        let orderinfo = [];
        this.orderslength = orders.length;
        for (let k = 0; k < orders.length; k++) {
          let order = {
            "ORDER_NUMBER": orders[k].ORDER_NUMBER,
            "CUSTOMER_NAME": orders[k].CUSTOMER_NAME,
            "CUST_PO_NUMBER": orders[k].CUST_PO_NUMBER,

            "ORDERED_DATE": orders[k].ORDERED_DATE ? new Date(orders[k].ORDERED_DATE).toLocaleString('en-US', { timeZone: 'America/New_York', }) : orders[k].ORDERED_DATE,
            "REQUEST_DATE": orders[k].REQUEST_DATE ? new Date(orders[k].REQUEST_DATE).toLocaleString('en-US', { timeZone: 'America/New_York', }).split(",")[0] : orders[k].REQUEST_DATE,
            "ORDER_STATUS": orders[k].ORDER_STATUS,
            "STORE_NUMBER": orders[k].STORE_NUMBER,
            "PHONE_NUMBER": orders[k].PHONE_NUMBER,
            "ORDER_TYPE": orders[k].ORDER_TYPE,
            //"ORDER_SOURCE": orders[k].ORDER_SOURCE,
            "REFERENCE_NUMBER": orders[k].ORIG_SYS_DOCUMENT_REF
            //"CREATION_DATE": orders[k].CREATION_DATE ? new Date(orders[k].CREATION_DATE).toLocaleString('en-US', { timeZone: 'America/New_York', }).split(",")[0] : orders[k].CREATION_DATE
          };
          orderinfo.push(order);
          /*if("LINE_DETAILS" in orders[k] && orders[k].LINE_DETAILS!=null){
            //console.log('length of line detail items: '+orders[k].LINE_DETAILS.LINE_DETAILS_ITEM.length);
            if(orders[k].LINE_DETAILS.LINE_DETAILS_ITEM.length>0){
              //console.log('inside linedetails if block');
              //let tflag=0;
              for(let tid=0;tid<orders[k].LINE_DETAILS.LINE_DETAILS_ITEM.length;tid++){
                let ordertemp={
                  "ORDER_NUMBER": orders[k].ORDER_NUMBER,
                  "DELIVER_TO_CUSTOMER_NAME": orders[k].DELIVER_TO_CUSTOMER_NAME,
                  "CUST_PO_NUMBER": orders[k].CUST_PO_NUMBER,
                  "ORDERED_DATE": orders[k].ORDERED_DATE,
                  "REQUEST_DATE": orders[k].REQUEST_DATE,
                  "ORDER_STATUS": orders[k].ORDER_STATUS,
                  "STORE_NUMBER": orders[k].STORE_NUMBER,
                  "PHONE_NUMBER": orders[k].PHONE_NUMBER
                };
                //if(orders[k].LINE_DETAILS.LINE_DETAILS_ITEM[tid].TRACKING_NUMBER!=null){
                //  tflag=1;
                  ordertemp["TRACKING_NUMBER"]=orders[k].LINE_DETAILS.LINE_DETAILS_ITEM[tid].TRACKING_NUMBER;
                  ordertemp["SCHEDULE_SHIP_DATE"]=orders[k].LINE_DETAILS.LINE_DETAILS_ITEM[tid].SCHEDULE_SHIP_DATE;
                  orderinfo.push(ordertemp);
                }
              }
              else {
                order["TRACKING_NUMBER"]=null;
                orderinfo.push(order);
              }
              
            }
            else {
              order["TRACKING_NUMBER"]=null;
              orderinfo.push(order);
            }*/
        }

        this.order_cols = Object.keys(orders[0]);
        this.orderrecords = orders;
        orderinfo.sort(function (a, b) { return b.ORDER_NUMBER - a.ORDER_NUMBER });
        this.orderdata = orderinfo; //new data
        console.log('Orders json is' + JSON.stringify(this.orderdata));
        /*for (let i = 0; i < this.order_cols.length; i++) {
   
          this.order_colOptions.push({ label: this.order_cols[i], fieldName: this.order_cols[i], sortable: true, value: this.order_cols[i] });
        }
        this.order_columns = this.order_colOptions;*/
        this.order_columns = [
          {
            label: 'GEA Order Number(cso)', fieldName: 'ORDER_NUMBER', type: 'button', wrapText: true, sortable: true,
            typeAttributes: {
              label:
              {
                fieldName: 'ORDER_NUMBER'
              },
              variant: 'base',
              //target : '_blank'
            }
          },
          //{label:'Tracking Id', fieldName:'TRACKING_NUMBER'},
          //{label:'Schedule Ship Date', fieldName:'SCHEDULE_SHIP_DATE'},
          { label: 'Customer Name', fieldName: 'CUSTOMER_NAME', sortable: true },
          { label: 'PO Number', fieldName: 'CUST_PO_NUMBER', sortable: true },
          { label: 'Reference Number', fieldName: 'REFERENCE_NUMBER' },
          { label: 'Phone Number', fieldName: 'PHONE_NUMBER', sortable: true },
          { label: 'Store Number', fieldName: 'STORE_NUMBER', sortable: true },
          { label: 'Order Status', fieldName: 'ORDER_STATUS', sortable: true },
          { label: 'Order Type', fieldName: 'ORDER_TYPE', sortable: true },
          //{ label: 'Order Source', fieldName: 'ORDER_SOURCE', sortable: true },
          { label: 'Ordered Date', fieldName: 'ORDERED_DATE', sortable: true },
          { label: 'Request Date', fieldName: 'REQUEST_DATE', sortable: true },
          //{ label: 'Created Date', fieldName: 'CREATION_DATE', sortable: true }
        ]
        if(this.invokedByOrderSummary){
          console.log('orderDetailAPICall inside invokedByOrderSummary > ',this.invokedByOrderSummary);
          this.orderDetailAPICall(this.ordrnumber);  //New Changes
        }
      }
      // }
      // })
      /* .catch(error => {
         console.log('errors are'+error);
         this.OrderLoading = false;
         this.displyflag=false;
         this.order_columns = [];
         this.orderdata = [];
         this.error = error.error;
         const evt = new ShowToastEvent({
           title: 'Order Search Failed',
           message: this.error,
           variant: 'error',
       });
       dispatchEvent(evt);
       });*/
    }
    catch (error) {
      this.OrderLoading = false;
      if(!this.invokedByOrderSummary){
        this.displyflag = true;
      }
      this.order_columns = [];
      this.orderdata = [];
      this.orderslength = 0;

      const evt = new ShowToastEvent({
        title: 'Error',
        message: 'Order API is down',
        variant: 'error',
      });
      dispatchEvent(evt);
    }

  }

  closeModal() {
    // to close modal set isModalOpen tarck value as false
    this.expandview = false;
  }

  handleUnsubscribe() {
    unsubscribe(this.subscription);
    this.subscription = undefined;
    releaseMessageContext(this.context);
  }
  get subscribeStatus() {
    return this.subscription ? 'TRUE' : 'FALSE';
  }
  callorderdetail(event) {
    const row = event.detail.row;
    console.log("inside popup orderdetail view record");
    console.log('order no. is ::' + row.ORDER_NUMBER);
    let orderno = row.ORDER_NUMBER;
    this.orderDetailAPICall(orderno);
  }

  sortBy(field, reverse, primer) {
    const key = primer
      ? function (x) {
        return primer(x[field]);
      }
      : function (x) {
        return x[field];
      };

    return function (a, b) {
      a = key(a);
      b = key(b);
      return reverse * ((a > b) - (b > a));
    };
  }

  onHandleSort(event) {
    const { fieldName: sortedBy, sortDirection } = event.detail;
    const cloneData = [...this.orderdata];

    cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
    this.orderdata = cloneData;
    this.sortDirection = sortDirection;
    this.sortedBy = sortedBy;
  }

}