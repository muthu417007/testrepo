import { LightningElement, wire,track } from 'lwc';
import getBodewellOrdersItems from '@salesforce/apex/BWC_OrderConfirmationController.getBodewellOrderSummaryItems';
import getOrderDeliveryGroupSummary from '@salesforce/apex/BWC_OrderConfirmationController.getOrderDeliveryGroupSummary';
import ProductServices from '@salesforce/apex/BWC_OrderConfirmationController.getProductServiceType';
import { CurrentPageReference } from 'lightning/navigation';
import getBuyerGroup from '@salesforce/apex/BWC_CartController.getBuyerGroup';
import UserAccountIdFIELD from '@salesforce/schema/User.AccountId';
import User_Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import getConsumerZipcode from '@salesforce/apex/BWC_CartController.getConsumerZipcode';
import BWC_UI from '@salesforce/resourceUrl/BodewellTheme';
//import getProductSeggregation from '@salesforce/apex/BWC_OrderItemSegregation.getProductSegregation';



export default class Bwc_mya_MySummaryItems extends LightningElement {

    bodewellOrderListItems;
    rid;
    orderBillingDetails;
    skuProduct;
    zipcode;
    bodewellProductServices=[];
    installationFlag = false;
    wireUserResult;
    currentUser;
    accountId;
    shippingMethod;
    deliveryType;
    homeDelivery;
    ship;
    pickUp;
    zipCode;
    partsListflag;
    prodShippingListflag;
    pickupListflag;
    totalHdItems;
    productSeggregation = [];
 
    
    hdFlag = false;
    orderpickUpFlag =false;
    shipToHomeFlag = false;;
    pickUpStoreFlag = false;
    oversizedFlag = false;

    hdList=[];
    orderPickUpList=[];
    shipToHome=[];
    pickUpStore=[];
    sdsList=[];
  
    orderStatus;
    deliveredDate;
    estimatedDate;

    productService;
    productServiceType;
    productServiceName;
    productServicePrice


HOME_DELIVERY = BWC_UI + '/icons/checkout-icons/in-home-delivery.svg'; 
FEDEX_SHIPPING = BWC_UI + '/icons/checkout-icons/Fedex-shipping.svg';
FREIGHT_SHIPPED = BWC_UI + '/icons/checkout-icons/Freight-shipped.svg';
ORDER_PICKUP = BWC_UI + '/icons/checkout-icons/Order-Pick-Up.svg';
PRODUCT_SHIPPED = BWC_UI + '/icons/checkout-icons/Products-shipped.svg';
PART_SHIPPED = BWC_UI + '/icons/checkout-icons/Parts-shipped.svg';

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.rid = currentPageReference.state.recordid;
            console.log('this.rid ', this.rid);

        }
    }



    connectedCallback() {
        console.log('User_Id', User_Id);
    }

    @wire(getRecord, { recordId: User_Id, fields: [UserAccountIdFIELD] })
    currentUserInfo({ error, data }) {
        console.log('data test', data);
        if (data) {

            this.accountId = data.fields.AccountId.value;
            console.log('data===' + this.accountId);

        } else if (error) {
            this.error = error;
        }
    }

    @wire(getConsumerZipcode, { accountId: '$accountId' })
    getConsumerZip({ error, data }) {
        if (data) {
            console.log('zip and state ' + JSON.stringify(data));
            this.zipCode = data.PostalCode;
            console.log('zipcode and state are ' + this.zipCode);

        } else if (error) {
            console.log('error occured ' + error);
        }
    }

  /*  @wire(getProductSeggregation, { zipCode: '$zipCode', orderItemIdList: '$rid' })
    BodewellProductSeggregation(result) {
        if (result) {
            console.log('result- new->', result);
            console.log('result-->', result.data['hd']);
            if(result.data['hd']!==undefined || result.data['hd']!=null){
               
                    this.hdFlag = true;
                    console.log('this.hdFlag', this.hdFlag);
                    let hdList = [];
                    for (let x = 0; x < result.data['hd'].length; x++) {
                        let objInstance = {};
    
                        objInstance['BWC_Main_Image__c'] = result.data['hd'][x].Product2.BWC_Main_Image__c;
                        objInstance['BWC_Product_Marketing_Description__c'] = result.data['hd'][x].Product2.BWC_Product_Marketing_Description__c;
                        hdList.push(objInstance);
                    }
                    console.log('hdList-->', hdList);
                
            }
        if(result.data['sps']!==undefined || result.data['sps']!=null){
           
                this.spsFlag = true;
                console.log('this.spsFlag', this.spsFlag);
                let spsList = [];
                for (let x = 0; x < result.data['sds'].length; x++) {
                    let objInstance = {};

                    objInstance['BWC_Main_Image__c'] = result.data['hd'][x].Product2.BWC_Main_Image__c;
                    objInstance['BWC_Product_Marketing_Description__c'] = result.data['hd'][x].Product2.BWC_Product_Marketing_Description__c;
                    hdList.push(objInstance);
                }
                console.log('spsFlag-->', spsList);
            }
            if(result.data['sps fee']!==undefined || result.data['sps fee']!=null){
                this.spsFeeList = true;
                console.log('this.spsFeeList', this.spsFeeList);
                let spsFeeList = [];
                for (let x = 0; x < result.data['sps fee'].length; x++) {
                    let objInstance = {};

                    objInstance['BWC_Main_Image__c'] = result.data['hd'][x].Product2.BWC_Main_Image__c;
                    objInstance['BWC_Product_Marketing_Description__c'] = result.data['hd'][x].Product2.BWC_Product_Marketing_Description__c;
                    hdList.push(objInstance);
                }
                console.log('spsFeeList-->', spsFeeList);
            }
           if(result.data['will call']!==undefined || result.data['will call']!=null) {
                this.willCallFlag = true;
                console.log('this.willCallFlag', this.spsFeeList);
                let spsFeeList = [];
                for (let x = 0; x < result.data['will call'].length; x++) {
                    let objInstance = {};

                    objInstance['BWC_Main_Image__c'] = result.data['hd'][x].Product2.BWC_Main_Image__c;
                    objInstance['BWC_Product_Marketing_Description__c'] = result.data['hd'][x].Product2.BWC_Product_Marketing_Description__c;
                    hdList.push(objInstance);
                }
                console.log('willCallFlag-->', spsFeeList);
            }

        }



         if(result === null){
              console.log("API is not working");
          } 
        this.productSeggregation = result.data;

        console.log('Bodewell Product Seggregation', this.productSeggregation);

    }*/


    bodewellOrderListItems;
    @wire(getBodewellOrdersItems, { orderRefNumber: '$rid' })
    BodewellOrderListItems(result) {
        console.log('this.bodewellOrders in get order list result', result.data);
        console.log('bodewell orders');
        this.isLoading = true;
        if (result) {
            this.bodewellOrderListItems = result.data;
            console.log('this.bodewellOrders in my summary items ', this.bodewellOrderListItems);
            this.getProductSegreggation();
        }
    }
    getProductServiceDetails(cartItemId) {
       ProductServices({ cartItemId: cartItemId  })
            .then((res) => {
                console.log('Product services', res);
                this.productService = res;
                console.log('this.productService' ,this.productService);
                this.productServiceType = this.productService.BWC_Service_Type__c;
                this.productServiceName = this.productService.Name;
                this.productServicePrice = this.productService.BWC_Service_Price__c;
                console.log('this.productServiceName',this.productServiceName);
                console.log('this.productServicePrice',this.productServicePrice);

                if(this.productServiceType === 'Installation'){
                    this.installationFlag=true;
                  console.log("installationFlag",this.installationFlag);
                }
                else{
                    this.installationFlag=false;
                    console.log("installationFlag",this.installationFlag);
                } 
                
            }).catch((error) => {
                console.error(error);
            });
    } 
    
    getProductSegreggation(){
        /*for (const Ord of this.bodewellOrderListItems) {
            this.shippingMethod = Ord.BWC_Shipping_Method__c;
            this.deliveryType = Ord.Product2.BWC_Delivery_Type__c;
            this.deliveredDate = Ord.BWC_Original_Ship_Date__c;
            this.estimatedDate = Ord.BWC_Original_Ship_Date__c;
          //  this.orderStatus = this.setOrderStatus(Ord);
        console.log('this.deliveryType in My Summary items', this.deliveryType);
        console.log('this.shippingMethod in My Summary items ', this.shippingMethod);
        console.log('this.deliveredDate in My Summary items ', this.deliveredDate); */
        this.bodewellOrderListItems = this.bodewellOrderListItems.map((item) => {
            console.log("Item Order" + JSON.stringify(item));
      
    if(item.BWC_Shipping_Method__c){

        if((item.BWC_Shipping_Method__c==="Home Delivery"))
            {
            this.hdFlag =true;
            let objInstance = {};
            objInstance['BWC_Main_Image__c'] = item.Product2.BWC_Main_Image__c;
            objInstance['BWC_Product_Marketing_Description__c'] = item.Product2.BWC_Product_Marketing_Description__c;
            objInstance['Base_Model__c'] = item.Product2.Base_Model__c;
            objInstance['TotalPrice'] = item.TotalPrice;
            this.hdList.push(objInstance);
            console.log('hdList-->');
            console.log('item.cart_Item_Id__c in home delivery',item.cart_Item_Id__c);
            this.getProductServiceDetails(item.cart_Item_Id__c);
            console.log('Order STatus',item.Order.Status);
            if(item.Order.Status==='Booked'){
                this.deliveredDate = 'Schedule Delivery Date: ' + item.BWC_Original_Ship_Date__c;
                console.log('this.deliveredDate', this.deliveredDate);
               }
               else if(item.Order.Status==='Closed'){
                console.log('this.deliveredDate', this.deliveredDate);
                this.deliveredDate = 'Delivered' + item.BWC_Original_Ship_Date__c;
               }

         } 
        if(item.BWC_Shipping_Method__c=== "Will Call" || item.BWC_Shipping_Method__c=== "SDS Will Call")
         {
            this.orderpickUpFlag =true;
            let objInstance = {};
            objInstance['BWC_Main_Image__c'] = item.Product2.BWC_Main_Image__c;
            objInstance['BWC_Product_Marketing_Description__c'] = item.Product2.BWC_Product_Marketing_Description__c;
            objInstance['Base_Model__c'] = item.Product2.Base_Model__c;
            objInstance['TotalPrice'] = item.TotalPrice;
            this.orderPickUpList.push(objInstance);
            console.log('orderPickUpList-->');
            console.log('bodewell orders in orderpickup');
            console.log('item.cart_Item_Id__c in orderpickup',item.cart_Item_Id__c);
            this.getProductServiceDetails(item.cart_Item_Id__c);
            let location=JSON.parse(item.BWC_Pickup_Location__c);
            if(location)
            { this.pickupLocation=location.address+', '+location.city+', '+location.state+', '+location.zipcode
            this.pickupPhone=location.phone;

            }

            if(item.Order.Status==='Booked'){
                this.estimatedDate = 'Estimated Pick-Up date' + item.BWC_Original_Ship_Date__c;
                console.log('this.estimatedDate', this.estimatedDate);
               }
               else if(item.Order.Status==='Closed'){
                this.estimatedDate = 'Picked Up' + item.BWC_Original_Ship_Date__c;
                console.log('this.estimatedDate', this.estimatedDate);
               }
           
         }
         if(item.BWC_Shipping_Method__c.includes("FedEx"))
         {
            this.shipToHomeFlag=true;
            let objInstance = {};
            objInstance['BWC_Main_Image__c'] = item.Product2.BWC_Main_Image__c;
            objInstance['BWC_Product_Marketing_Description__c'] = item.Product2.BWC_Product_Marketing_Description__c;
            objInstance['Base_Model__c'] = item.Product2.Base_Model__c;
            objInstance['TotalPrice'] = item.TotalPrice;
            this.shipToHome.push(objInstance);
            console.log('Ship To home-->');
            console.log('bodewell orders in shipToHome');
            console.log('item.cart_Item_Id__c in ship to home',item.cart_Item_Id__c);
            this.getProductServiceDetails(item.cart_Item_Id__c);
         }
        /* if(item.BWC_Shipping_Method__c.includes("Will Call") && item.Product2.deliveryType.includes("sds")){
            this.pickUpStoreFlag=true;
            let objInstance = {};
            objInstance['BWC_Main_Image__c'] = item.Product2.BWC_Main_Image__c;
            objInstance['BWC_Product_Marketing_Description__c'] = item.Product2.BWC_Product_Marketing_Description__c;
            objInstance['Base_Model__c'] = item.Product2.Base_Model__c;
            objInstance['TotalPrice'] = item.TotalPrice;
            this.pickUpStore.push(objInstance);
            console.log('Pick Up in Store-->');
         } */

         if(item.BWC_Shipping_Method__c==="SDS Delivery"){
            this.oversizedFlag =true;
            let objInstance = {};
            objInstance['BWC_Main_Image__c'] = item.Product2.BWC_Main_Image__c;
            objInstance['BWC_Product_Marketing_Description__c'] = item.Product2.BWC_Product_Marketing_Description__c;
            objInstance['Base_Model__c'] = item.Product2.Base_Model__c;
            objInstance['TotalPrice'] = item.TotalPrice;
            this.sdsList.push(objInstance);
            console.log('sdsList-->');
            console.log('bodewell orders in over sized ');
            console.log('item.cart_Item_Id__c in over size',item.cart_Item_Id__c);
            this.getProductServiceDetails(item.cart_Item_Id__c);
         } 
        }
    })
    }

    /* if(this.bodewellOrderListItems){
             this.skuProduct = this.bodewellOrderListItems.StockKeepingUnit;
             console.log('this.skuProduct in My Summary items ',this.skuProduct);
              this.skuProduct = GSE23GGKWW;
                   this.zipcode = '40222';
             }  */


    @wire(getBuyerGroup, { acctId: '$accountId' })
    buyerGroups({ data, error }) {

        if (data) {
            console.log("buyerGroups data" + JSON.stringify(data));
            console.log("buyerGroups acctId" + this._accountId);
            //considering user belongs to only one buyer group at a time

            if (data[0].BuyerGroup != undefined && data[0].BuyerGroup.Name != undefined) {
                if (data[0].BuyerGroup.Name === 'Member') {
                    this.isMember = true;

                }
                else {
                    this.isMember = false;

                }
            }


        }
        else if (error) {
            console.log('buyerGroups error ' + JSON.stringify(error));
        }
    }

    @wire(getOrderDeliveryGroupSummary, { orderSummaryId: '$rid' })
    BodewellShippingSummary(result) {
        console.log('this.bodewell Summary Orders', result.data.DeliverToPostalCode);
        if (result) {
            console.log('bodewell orders');
            this.orderBillingDetails = result.data;
            console.log('this.bodewell Summary Orders line no 25 ', this.orderBillingDetails);
        }
    }


    /* @wire(getProductServices,{skuProduct: this.skuProduct, zipcode: this.zipcode})
     BodewellProductServices({data,err}) {
      if(data) {
          
          console.log('this.zipcode in in My Summary items ',data);
          this.bodewellProductServices = data;
          console.log('this.bodewellProductServices',this.bodewellProductServices);
      }
   
      if(err){
          console.log(err)
      }
   
   }  */
}