import { LightningElement,wire } from 'lwc';
import getBodewellOrdersItems from '@salesforce/apex/BWC_OrderConfirmationController.getBodewellOrdersItems';
import { CurrentPageReference } from 'lightning/navigation';
import getBuyerGroup from '@salesforce/apex/BWC_CartController.getBuyerGroup';
import { getRecord } from 'lightning/uiRecordApi';
import User_Id from '@salesforce/user/Id';
import UserAccountIdFIELD from '@salesforce/schema/User.AccountId';
import getAllRelatedCartItem from '@salesforce/apex/BWC_ProductViewServicesController.bwc_getAllRelatedCartItem';
import getCurrentCartId from '@salesforce/apex/BWC_OrderConfirmationController.getCurrentCartId';
//SHubhada Changes
import { publish, subscribe, MessageContext } from "lightning/messageService";

//Shubhada Changes
import memberChannel from '@salesforce/messageChannel/bwc_membership__c';
export default class Bwc_orderSummaryItems extends LightningElement {
    @wire(MessageContext) messageContext;
    bodewellOrderListItems;
    currencyCode='USD';
    rid;
    isMember;
    _accountId;
    zipCode;
    connectedCallback() {



        if (localStorage.getItem('zipcode')) {
          //An Id key is in the local Storage
          this.localStorageZipCode = JSON.parse(localStorage.getItem('zipcode'));
          this.zipCode = this.localStorageZipCode.Zipcode;
          //Clear local storage after getting the values
    
        }
    }
    @wire(getRecord, { recordId: User_Id, fields: [UserAccountIdFIELD] })
    currentUserInfo({ error, data }) {
        if (data) {
        
            this._accountId = data.fields.AccountId.value;
            console.log('data===' + JSON.stringify(data));

        } else if (error) {
            this.error = error;
        }
    }
    cartId;
  
    @wire(getCurrentCartId,{accountId: '$_accountId'})
    cartIdGet({error, data}){
        if(data){
            console.log('cartId->', data);
          this.cartId=data;
        }
        else{
            console.log('cartId', error);
        }
    }
   
    @wire(getBuyerGroup, { acctId: '$_accountId'})
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

    bodewellOrderListItems;
    @wire(getBodewellOrdersItems, { Id: '$rid'})
    BodewellOrderListItems({data , err}) {
        console.log('tthis.bodewellOrders in get order list items',this.number);
       this.isLoading = true;
       if (data) {
         this.bodewellOrderListItems=data;
         console.log('this.bodewellOrders in get order list items ',JSON.stringify(this.bodewellOrderListItems));
        } 
       else{
        this.rid=this.rid+' ';
        console.log('error in summary Items==>'+JSON.stringify(err))

       } 
    //    if (err) {
    //        console.log('error in summary Items==>'+JSON.stringify(err))
    //      }
   }
  
   installationChangeCapture()
   {
    

         console.log(`call installation`);
         let message = { message: 'Install' };
         publish(this.messageContext, memberChannel, message);
 
   }
   _installationServices;
   installationFlag=false;
   memberinstallationflag=false;
   free;
   @wire(getAllRelatedCartItem, { cartId: '$cartId'})
   cartItems({ data, err }) {
     console.log('cartItemId===' + this.cartId);
     if (data) {
       console.log('data' + JSON.stringify(data))
       this._installationServices = data.relatedItemAll;
       //  this._cartItems=data.relatedItemAllProduct;
       if (this._installationServices.length > 0) {
         this.installationFlag = true;
      
         if (this.isMember === true) {
           this.memberinstallationflag = true;
           if (this.memberInstallation === 0) {
               this.free = 'FREE';
           }
           else
               this.free = '';
     
       } else
           this.memberinstallationflag = false;
      
     
       }
       else {
         this.installationFlag = false;
       }
 
 
       console.log('this._installationServices==' + JSON.stringify(this._installationServices));
     }
     if (err) {
       console.log('error===' + JSON.stringify(err))
     }
   }


   }