import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import bannerImageResource from '@salesforce/resourceUrl/BannerImage';
import PRODUCTIDMEMBER from "@salesforce/label/c.BWC_Product_Id_For_Member";
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id'; //this is how you will retreive the USER ID of current in user.
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import PHONE_FIELD from '@salesforce/schema/User.Phone';
import UserContactIdField from "@salesforce/schema/User.ContactId";

import ACCOUNT_ID from '@salesforce/schema/User.AccountId';
import getOrderDeliveryGroupSummary from '@salesforce/apex/BWC_OrderConfirmationController.getOrderDeliveryGroupSummary';
import getBodewellOrdersItems from '@salesforce/apex/BWC_OrderConfirmationController.getBodewellOrdersItems';

import getContactPointByContactId from '@salesforce/apex/BWC_OrderConfirmationController.getContactPointByContactId';
   /**
 * @description A component to display order confirmation details on page
 */
export default class Bwc_orderConfirmationPage extends LightningElement {

    proPlanText='If you purchased a Bodewell Care Protection Plan, your contract information and terms and conditions will be delivered to the email address you provided on this order.';
    @track UserPhone;
    @track AccountId;
    orderDeliveryDetails;
    homeDeliveryItem = false;
    pickUpItem = false;
    partsItem = false;
    sdsItem = false;
    prodItem = false;
    contactId;
    zipCode;
    isMemberPresent;
    @track subTotal = 0;
    @track shippingAmount = 0;
    @track couponAmount = 0;
    @track homeDeliveryAmount = 0;
    @track totalUSD = 0;
    @track totalUsdPaid = 0;

    bannerImage = bannerImageResource;
    cartData;
    cartCustom;

    orderNumber;
    @track orderSummaryIdInstance;
    orderSummaryDetailArray = [];
    @track item = [];
    orderNumberInstance;
    addressObjectInstance = {};
    billingAddressObject = {};
    
    @track error;
    @track userEmail;
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [EMAIL_FIELD, PHONE_FIELD, ACCOUNT_ID,UserContactIdField]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            this.error = error;
            console.log("error-->" + this.error);

        } else if (data) {
            this.userEmail = data.fields.Email.value;
            console.log("error-->" + this.userEmail);
            this.UserPhone =  data.fields.Phone.value;
            this.AccountId = data.fields.AccountId.value;
            this.contactId=data.fields.ContactId.value;
            console.log("AccountId", this.AccountId);
            console.log("contactId", this.contactId);
            this.getContactPointByContactID();
        }
    }
 
   
    PhoneNumber;
    getContactPointByContactID()
    {
      console.log("contactId -->" + this.contactId);
  
      getContactPointByContactId({ContactId:this.contactId})
      .then(result=>
        {
          console.log("getContactPointByContactID result-->" + JSON.stringify(result));
          this.PhoneNumber=result.Phone__c;
        })
        .catch(error=>
          {
            console.log("getContactPointByContactID error-->" + error);
          })
    }
    rid;
    @wire(CurrentPageReference)
       getStateParameters(currentPageReference) {
           if (currentPageReference) {
               if(currentPageReference.state.recordid)
               {
                  
   
                   this.rid = currentPageReference.state.recordid;
               }
               if(currentPageReference.state.orderNumber)
               {
                 
                   this.rid = currentPageReference.state.orderNumber; 
               }
               
       
               console.log('this.rid order summary ',this.rid );
               
           }
       }


 
       @wire(getOrderDeliveryGroupSummary, { orderSummaryId: '$rid'})
       BodewellShippingSummary({data , err}) {
           console.log('this.bodewell Summary Orders',data);
            if (data) {
            this.orderDeliveryDetails=data;
           
            }
            else{
          
               this.rid=this.rid+' ';
               console.log('orderDeliveryDetails==>'+JSON.stringify(err))
       
              } 
      } 


      bodewellOrderListItems;
      @wire(getBodewellOrdersItems, { Id: '$rid'})
      BodewellOrderListItems({data , err}) {
          //console.log('tthis.bodewellOrders in get order list items',this.number);
         this.isLoading = true;
         if (data) {
           this.bodewellOrderListItems=data;
           this.filterCartItems();
           console.log('this.bodewellOrders in get order list items ',this.bodewellOrderListItems);
          } 
         else {
          this.rid=this.rid+' ';
             console.log(err)
           }
     }
    
  
  
  
     
      shipToHome;
      deliveryDate;
      pickupDate;
      partsMethod;
      partsList=[];
     smallItem;
    spsMethod;
        spsList=[];
        overSizedItems;
        sdsListFreight=[];
        pickupLocation;
        pickupPhone
     
      filterCartItems() {
          this.partsList=[];
          this.spsList=[];
          this.sdsListFreight=[];
          console.log('this.bodewellOrderListItems->', JSON.stringify(this.bodewellOrderListItems));
          this.bodewellOrderListItems = this.bodewellOrderListItems.map((item) => {
              console.log("Item Order" + JSON.stringify(item));
         if(item.Product2.Id===PRODUCTIDMEMBER)
         {
          this.isMemberPresent=true;
         }
              //BWC_Shipping_Method__c, BWC_Ship_Date__c,product2.BWC_Delivery_Type__c,cartId
              if(item?.Product2?.BWC_Delivery_Type__c==='hd' && (item.OriginalOrderItem.BWC_Shipping_Method__c!=='Will Call' && item.OriginalOrderItem.BWC_Shipping_Method__c!=='SDS Will Call'))
              {
                  this.homeDeliveryItem=true;
                  this.deliveryDate=item.BWC_Original_Ship_Date__c;
                         
              }
              if(item.OriginalOrderItem.BWC_Shipping_Method__c==='Will Call' || item.OriginalOrderItem.BWC_Shipping_Method__c==='SDS Will Call')
              {
                  this.pickUpItem=true;
                     this.pickupDate=item.BWC_Original_Ship_Date__c;
                     let location=JSON.parse(item?.BWC_Pickup_Location__c);
                     if(location)
                     { this.pickupLocation=location.address+', '+location.city+', '+location.state+', '+location.zipcode
                     this.pickupPhone=location.phone;
  
                     }
                    
              }
              if(item?.Product2?.BWC_Delivery_Type__c)
              {
                  if(item.Product2.BWC_Delivery_Type__c==='sps fee')
                  {
                      this.shipToHome=true;
                      console.log('Delivery type==='+item.Product2.BWC_Delivery_Type__c);
                      this.partsItem=true;
                      this.partsMethod=item.OriginalOrderItem.BWC_Shipping_Method__c;
                         this.partsList.push(item.Product2.BWC_Product_Marketing_Description__c);
                  }
                  if(item.Product2.BWC_Delivery_Type__c==='sps')
                  {
                      this.shipToHome=true;
                      console.log('Delivery type==='+item.Product2.BWC_Delivery_Type__c);
                      this.smallItem=true;
                      this.spsMethod=item.OriginalOrderItem.BWC_Shipping_Method__c;
                         this.spsList.push(item.Product2.BWC_Product_Marketing_Description__c);
                  }
                  if(item.Product2.BWC_Delivery_Type__c==='sds')
                  {
                    
                      console.log('Delivery type==='+item.Product2.BWC_Delivery_Type__c);
                      this.overSizedItems=true;
                     
                         this.sdsListFreight.push(item.Product2.BWC_Product_Marketing_Description__c);
                  }
              
  
              }
  
             
           console.log(this.partsItem);
           console.log(this.partsMethod);
           console.log(JSON.stringify(this.partsList));
  
  
          })
       
      }
  
       
    // @wire(CurrentPageReference)
    // getPageReferenceParameters(currentPageReference) {
    //     if (currentPageReference) {
    //         console.log('mmmmmmmmmmmmm',currentPageReference.state.orderNumber);
    //         this.orderNumber = currentPageReference.state.orderNumber;
    //         console.log('nnnnnnnnnn',this.orderNumber);
    //         getOrderSummaryId({
    //             orderNumber: this.orderNumber
    //         })
    //         .then(result => {
    //             console.log('NNNNNNNNNN', result[0].Id);
    //             this.orderSummaryIdInstance = result[0].Id;
    //         })
    //         .catch(error =>{
    //             console.log('error', error);
    //         })
    //         // this.orderSummaryIdInstance = currentPageReference.attributes.recordId;
    //         // console.log('<<<<<<<<<<<<<<<<<<',currentPageReference.attributes.recordId);
    //         console.log('ID>>>'+this.orderSummaryIdInstance);        
    //     }
    // }

   
    // @wire(getBillingAddress,{orderSummaryIdInstance: '$orderSummaryIdInstance'})
    // BillingAddress({error, data}){
    //     if(data){
    //         console.log('success Address billing-->', data);
    //         this.billingAddressObject = data;
    //         console.log('22222222');
    //     }
    //     else{
    //         console.log('billing error', error);
    //     }
    // }
   
  
    // @wire(getShippingAddress,{orderSummaryIdInstance: '$orderSummaryIdInstance'})
    // ShippingAddress({error, data}){
    //     if(data){
    //         console.log('success Address shipping-->', data);
    //         this.addressObjectInstance = data;
    //         this.zipCode = data[0].DeliverToPostalCode;
    //         // this.shippingAmount = data[0].TotalLineAmount;
    //         console.log('/////////////////',data[0].DeliverToPostalCode);
    //         // console.log('""""""""""""""""""""""""""""""""', data[0].TotalLineAmount);
    //         // console.log('shipping Amount',this.shippingAmount);      
    //     }
    //     else{
    //         console.log('shipping error', error);
    //     }
    // }

    // @wire(OrderAdapter, { orderSummaryId: '$orderSummaryIdInstance' })
    // OrderAdapterMethod({ error, data }) {
    //     if (data) {
    //         console.log('OrderAdapter data-->', data);
    //         // console.log('%%%%%%%%%%%%%%%%%%',data.totalAmount);
    //         // this.subTotal = data.totalAmount;
    //         // console.log('sub total',this.subTotal);
    //     }
    //     else {
    //         console.log('error order-->', error);
    //     }
    // }

    // @wire(OrderItemsAdapter, { orderSummaryId: '$orderSummaryIdInstance' })
    // OrderItemsAdapterMethod({ error, data }) {
    //     if (data) {
    //         console.log('order data-->>>>>>>', data);
    //         //new change
    //         let orderItemSummaryList = [];
    //         //new change
    //         let itemObject = {};

    //         let orderSummaryArray = [];

    //         data.items.forEach(dataInstance => {
    //             let orderSummaryDetailObject = {};
    //             // console.log('dataInstance-->',dataInstance);
    //             orderSummaryDetailObject['Id'] = dataInstance.orderItemSummaryId;
    //             orderSummaryDetailObject['orderSummaryId'] = dataInstance.orderSummaryId;
    //             // orderSummaryDetailObject['productName'] = dataInstance.product.fields.str.text;
    //             //orderSummaryDetailObject['productSKU'] = dataInstance.product.fields.Product2.StockKeepingUnit.text;
    //             //console.log('ProoductName : ',orderSummaryDetailObject['productName']);
    //             orderSummaryDetailObject['media'] = dataInstance.product.media.url;
    //             //this.mediaurl = dataInstance.product.media.url;
    //             orderSummaryArray.push(orderSummaryDetailObject);
    //             console.log("orderSummaryArray-->", orderSummaryArray);
    //             //new change
    //             orderItemSummaryList.push(dataInstance.orderItemSummaryId);
    //             console.log('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>', orderItemSummaryList);
    //             //new change
    //         });
    //         itemObject['item'] = orderSummaryArray;
    //         console.log('itemObject-->', itemObject);
    //         getOrderSummaryDetails({
    //             orderSummaryIdObjectList: itemObject
    //         })
    //             .then(result => {
    //                 console.log('success-->', result);
    //                 this.orderSummaryDetailArray = result;
    //                 this.orderNumberInstance = result[0].orderNumberInstance;
    //             })
    //             .catch(error => {
    //                 console.log('error');
    //             });
    //         getProductDetails({
    //             orderItemSummaryList: orderItemSummaryList
    //         })
    //             .then(result => {
    //                 // console.log('orderItemSummaryList>>>>>>>>>>>>>>>>>>', result);
    //                 let updateResult = JSON.stringify(result);
    //                 console.log('++++++++++++++',updateResult);
    //                 let updateResultName = updateResult.replace("deliveryTypeInstance", "BWC_Delivery_Type__c").replace("partInstance", "BWC_Is_Part__c");
    //                 console.log('000000000000000000',updateResultName);
    //                 this.cartCustom = JSON.parse(updateResultName);
                    
    //                 console.log('{{{{{{{{{{{{{{{{{{{{{{', this.cartCustom);
    //                 // console.log('???', this.prodItem)
    //                 // this.totalUsdPaid = Number(this.subTotal) + Number(this.shippingAmount) + Number(this.homeDeliveryAmount);
    //                 // console.log('typeof',typeof this.totalUsdPaid);
    //                 // this.totalUSD = this.totalUsdPaid.toFixed(2);
    //             })
    //             .catch(error => {
    //                 console.log('error>>>>>>>>>>', error);
    //             })
    //     }
    //     else {
    //         console.log('error order-->', error);
    //     }
    // }

    // @wire(OrderDeliveryGroupsAdapter, { orderSummaryId: '$orderSummaryIdInstance' })
    // OrderDeliveryGroupsAdapterMethod({ error, data }) {
    //     if (data) {
    //         console.log('OrderDeliveryGroupsAdapter data-->', data);
    //     }
    //     else {
    //         console.log('error order-->', error);
    //     }
    // }

    // @wire(getOrderAmount, {orderSummaryId: '$orderSummaryIdInstance'})
    // getAmounts({data, error}){  
    //     if(data){
    //         console.log('Amount>>>>>>>>', data);
    //         this.subTotal = data[0].TotalAdjustedProductAmount;
    //         this.shippingAmount = data[0].TotalAdjustedDeliveryAmount;
    //         this.couponAmount = data[0].TotalAdjDistAmount;
    //         this.homeDeliveryAmount = 0;
    //         this.totalUSD = data[0].GrandTotalAmount;
    //     }
    //     else {
    //         console.log('error>>>', error);
    //     }   
    // }

    // filterCartItems(event) {
    //     console.log(event.detail.shipTypeProducts);
    //     console.log('***************', event.detail.shipTypeProducts.hdFlag);
    //     this.homeDeliveryItem = event.detail.shipTypeProducts.hdFlag;
    //     this.pickUpItem = event.detail.shipTypeProducts.pickupFlag;
    //     this.partsItem = event.detail.shipTypeProducts.partsFlag;
    //     this.sdsItem = event.detail.shipTypeProducts.sdsFlag;
    //     this.prodItem = event.detail.shipTypeProducts.prodFlag;
    //     console.log('???????????????', this.prodItem);
    // }

  

}