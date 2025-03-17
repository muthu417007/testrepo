import { LightningElement ,track,api,wire} from 'lwc';
    import { CartSummaryAdapter } from 'commerce/cartApi';
    import { SessionContextAdapter } from 'commerce/contextApi';
    import calculateTotalAmount from '@salesforce/apex/BWC_CalculateEntirePrice.calculateTotalAmount';
    import BWC_UI from '@salesforce/resourceUrl/BodewellTheme';
    import CHECKOUT_CHANNEL from '@salesforce/messageChannel/BWC_Checkout__c';
    import getCustomerDetails from '@salesforce/apex/BWCStripeController.createStripeCustomer';
    import { subscribe, unsubscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
    import USER_ID from '@salesforce/user/Id';
    import { CurrentPageReference } from 'lightning/navigation';
    
    export default class Bwc_paymentLinkStripe extends LightningElement {
      Step_4 = BWC_UI + '/icons/checkout-icons/step-4.svg';
        @track  amountArray=[];
        amount;
        orderNumber;
        isPayment=false;
        isPaymentIntent=false;
        @wire(MessageContext)
        messageContext;
        linkFlag=false;
        checkoutFlag=false;
        subscription;
        orderNumber;
        accountId;
        cartId;
        @wire(CurrentPageReference)
        getPageReferenceParameters(currentPageReference) {
            if (currentPageReference) {
                console.log("currentPageReference payment link-->", JSON.stringify(currentPageReference));
             if(currentPageReference.attributes.name=='payment_link__c')
             {
              this.amount=parseFloat(currentPageReference.state.amount);
              this.cartId=currentPageReference.state.orderNumber;
              this.accountId=currentPageReference.state.useId;

              this.linkFlag=true;
              this.amountArray= [{id:'payment-element-0',amount:this.amount,index:0,affirmId:'affirm-message-0'}];
              this.isPayment=true;
              this.isPaymentIntent=true;
              this.getStripeCustomerDetailsPaymentLink();
             }
             if(currentPageReference.attributes.name=='Current_Checkout')
             {
              this.checkoutFlag=true;
             }
            }
        }
        /**
         * @description This method is used to initialize the payment
         * @return {void}
         */
        connectedCallback() {
          
            this.subscription =
            subscribe(
                this.messageContext,
                CHECKOUT_CHANNEL,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }  
    paymentElementArray=[];
    TotalAmount=1000;
     /**
         * @description get the session context so we can check if we are "in preview" mode or not
         * @example
         * { "effectiveAccountId": "001Hn00001uFNzR", "effectiveAccountName": "United Coffee Bean Corp", "isLoggedIn": true, "userId": "005Hn00000HODpi", "userName": "Lauren", "buyerGroups": [ { "id": "0ZIHn0000008UhgOAE", "name": "Acme Coffee Buyer Group" } ], "isPreview": false, "isAnonymousPreview": false }
         */
     _sessionContext;
     @wire(SessionContextAdapter)
     wireSessionContext({ data, error }) {
         if (data) {
             this._sessionContext = data;
             if(this.checkoutFlag==true)
             {
 this.getStripeCustomerDetails();
             }
            
         } else if (error) {
             console.log(`bwc_cybersourceHPP::wireSessionContext::error = ${JSON.stringify(error, null, 2)}`);
         }
     }
     cartId;
     grandAmountTotal;
    @wire(CartSummaryAdapter)
    wireCartSummary({ data, error }) {
        if (data) {
            console.log('cartSummaryAdapter-->',data);
            this.cartId=data.cartId;
            this.getServiceCharge(data.cartId);
            console.log('service amt in Adapter-->'+this.serviceAmount);
            if(this.serviceAmount===undefined || this.serviceAmount === null){
              this.serviceAmount = 0;     
            }
        
            const grandAmount = parseFloat(data.grandTotalAmount)+this.serviceAmount;
            this.grandAmountTotal=grandAmount;
            
            console.log('grandAmount-->'+grandAmount);
            this._cartSummary = data;
            this._cartSummaryJSON = JSON.stringify({
                "grandTotalAmount": grandAmount,
                "totalTaxAmount": data.totalTaxAmount,
                "cartId": data.cartId,
                "currencyIsoCode": data.currencyIsoCode,
                'webstoreId':data.webstoreId
            });
          
        } else if (error) {
            console.log(`bwc_cybersourceHPP::wireCartSummary::error = ${JSON.stringify(error, null, 2)}`);
        }
    }
    
     /**
        * @description get the cart summary so we can get the cart id, currency code, etc... as we need it to pass to the payment provider
        * @example
        * { "accountId": "001Hn00001uFNzRIAW", "cartId": "0a6Hn000000PKgsIAG", "currencyIsoCode": "USD", "grandTotalAmount": "874.79", "isSecondary": false, "messagesSummary": { "errorCount": 0, "hasErrors": false, "limitedMessages": [], "relatedEntityId": "0a6Hn000000PKgsIAG", "totalLineItemsWithErrors": 0 }, "name": "Cart", "orderOwnerId": null, "ownerId": "005Hn00000HODpiIAH", "purchaseOrderNumber": null, "status": "Checkout", "taxType": "Net", "totalChargeAmount": "11.99", "totalListPrice": "11.99", "totalProductAmount": "798.00", "totalProductAmountAfterAdjustments": "798.00", "totalProductCount": "2", "totalPromotionalAdjustmentAmount": "0.00", "totalTaxAmount": "64.80", "type": "Cart", "uniqueProductCount": 1, "webstoreId": "0ZEHn0000008UgiOAE" }
        */
     _cartSummary;
     _cartSummaryJSON;  // The string subset version of the cart summary is needed for the "getParameters" call
     @api serviceAmount;
    
     getServiceCharge(cartId){
         calculateTotalAmount({cartId:cartId})
         .then(result=>{
             console.log('ServiceResult-->'+result);
             this.serviceAmount = result;
         })
         .catch(error=>{
             console.log('error in CalculateEntirePrice apex class-->'+error);
         })
     }
    //@track childComponentsNew = [1:1000];
    stripeFromChild;
    getRandomInt(max) {
        return Math.floor(Math.random() * max);
      }
      amountChangeHandler(event) {
        let tempTotal;
        let remainingSum=0;
        let changedIndex = event.detail.val;
        console.log('changedIndex==' + changedIndex);
    
        let indexSelected;
        for (let i = 0; i < this.amountArray.length; i++) {
          if (this.amountArray[i].index == changedIndex) {
            indexSelected = i;
          }
    
    
        }
        for (let i = 0; i < indexSelected; i++) {
          remainingSum += this.amountArray[i].amount;
          console.log('in parent 1'+remainingSum);
    
        }
        remainingSum += parseInt(event.detail.amount);
        console.log('in parent 2'+remainingSum);
        let remainigAmount = this.TotalAmount - remainingSum;
        console.log('in parent remainigAmount'+remainigAmount);
        let indexTemp = Math.floor(Math.random() * 1000);
        let updatedChildComponents;
        if (indexSelected < ((this.amountArray.length)-1)) {
          this.amountArray.splice(indexSelected + 1, this.amountArray.length - (indexSelected + 1));
          updatedChildComponents = [...this.amountArray];
          updatedChildComponents = updatedChildComponents.map(item => {
            if (item.index == changedIndex) {
    
              tempTotal = item.amount;
              item.amount = parseInt(event.detail.amount);
              item.index = indexTemp;
              item.id = 'payment-element-' + indexTemp;
              item.affirmId='affirm-message-'+ indexTemp;
              console.log('in parent');
            }
    
            return item;
    
          });
          let indexTemp2 = Math.floor(Math.random() * 1000);
          this.amountArray = [...updatedChildComponents, { id: 'payment-element-' + indexTemp2, amount: remainigAmount, index: indexTemp2,affirmId:'affirm-message-'+ indexTemp2 }];
    console.log('this.amountArray=== if'+JSON.stringify(this.amountArray));
        }
        else {
          updatedChildComponents = [...this.amountArray];
          updatedChildComponents = updatedChildComponents.map(item => {
            if (item.index == changedIndex) {
    
              tempTotal = item.amount;
              item.amount = parseInt(event.detail.amount);
              item.index = indexTemp;
              item.id = 'payment-element-' + indexTemp;
              item.affirmId='affirm-message-'+ indexTemp;
              console.log('in parent');
            }
            else {
    
              let indexTemp1 = Math.floor(Math.random() * 1000);
              item.index = indexTemp1;
              item.id = 'payment-element-' + indexTemp1;
              item.affirmId='affirm-message-'+ indexTemp1;
    
    
    
            }
            return item;
    
          });
    
    
    
    
         
          let indexTemp2 = Math.floor(Math.random() * 1000);
          this.amountArray = [...updatedChildComponents, { id: 'payment-element-' + indexTemp2, amount: tempTotal - (event.detail.amount), index: indexTemp2 }];
          console.log('in parent===' + JSON.stringify(this.amountArray));
          console.log('this.amountArray=== else'+this.amountArray);
        }
    
    
    
      }
    
      customerId;
     getStripeCustomerDetails(){
      getCustomerDetails({accountID:USER_ID})
      .then(result=>{
          console.log('customer Id-->'+result);
          this.customerId = result;
      })
      .catch(error=>{
          console.log('error in customerId apex class-->'+JSON.stringify(error));
      })
    }
    getStripeCustomerDetailsPaymentLink(){
      console.log('userId payment link==='+this.accountId);

      getCustomerDetails({accountID:this.accountId})
      .then(result=>{
          console.log('customer Id-->'+result);
          this.customerId = result;
      })
      .catch(error=>{
          console.log('error in customerId apex class-->'+JSON.stringify(error));
      })
    }
     // disconnectedCallback(){
        //     unsubscribe(this.subscription);
        //      this.subscription = null;
        // }
    
        handleMessage(data) {
          console.log('bwc_cybersourceHPP::handleMessage::data=' + JSON.stringify(data, null, 2));
          if (data?.enablePlaceOrder) {
              
              this.isPayment=true;
          }
    
          if (data?.enablePaymentIntent) {
              
            this.isPaymentIntent=true;
            
        }
        if(this.isPaymentIntent===true && this.isPayment===true)
        {
          this.handleClick();
        }
      }
    
      handleClick()
      {
        let indexTemp2 = Math.floor(Math.random() * 1000);
        this.amountArray= [{id:'payment-element-'+indexTemp2,amount:this.grandAmountTotal,index:0,affirmId:'affirm-message-'+indexTemp2}];
      }
      disconnectedCallback() {
          unsubscribe(this.subscription);
          this.subscription = null;
      }
    }