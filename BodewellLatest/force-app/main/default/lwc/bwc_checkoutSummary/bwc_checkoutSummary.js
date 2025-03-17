import { LightningElement, track, wire } from 'lwc';
import getAllRelatedCartItem from '@salesforce/apex/BWC_ProductViewServicesController.bwc_getAllRelatedCartItem';
import addPartsShippingAsLineItem from '@salesforce/apex/BWC_ProtectionPlanController.addPartsShippingAsLineItem';
import { NavigationMixin } from 'lightning/navigation';
import { CartSummaryAdapter } from 'commerce/cartApi'
import zipCodeChannel from '@salesforce/messageChannel/zipCodeChange__c';
//import addRelatedToCart from '@salesforce/apex/BWC_ProductViewServicesController.bwc_CreateCartItems';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import getTaxAmount from '@salesforce/apex/BWC_CartController.getTaxAmount';
import bwc_getRelatedCartItemAll from '@salesforce/apex/BWC_ProductViewServicesController.bwc_getRelatedCartItemAll';
import CHECKOUT_CHANNEL from '@salesforce/messageChannel/BWC_Checkout__c';

export default class Bwc_checkoutSummary extends NavigationMixin(LightningElement) {

  @track localStorageProducts = {};
  @track _checkoutItems = [];
  @track cartId;
  @track _cartItems = [];
  @track _cartTotal = 0.0;
  @track subTotal = 0.0;
  @track _fixedTotal = 0.0;
  @track _fixedcartTotal = 0.0;
  @track promotions = 0.0;
  @track showPromotion = false;
  @track _fixedPromo = 0.0;
  @track total = 0.0;
  @track deliveryfee = 0.0;
  @track smallPackageFee;
  @track installationfee = 0.0;
  @track _installationFee = 0.0;
  @track memberInstallation = 0.0;
  @track selectedPartsShip;
  @track partsShipFee = 0.0;
  @track partsShipOptions;
  @track _installationServices;
  cartPageUrl = '/cart';
  @track installationFlag = false;
  @track memberinstallationflag = false;
  @track promotionflag = false;
  @track deliveryflag = false;
  @track isUserMember = false;
  @track free = '';
  @track isFree = false;
  @track localStorageZipCode;
  @track taxAmt;
  @track taxFlag = false;
  showSpinner = false;
  subscription;
  // @track taxInfo;
  subscription = null;
  protectionPlanFee=0.0;
  memberProtectionPlanFee=0.0;
  protectionPlanFeeflag=false;
  protectionFee=0.0;

  @wire(MessageContext)
  messageContext;
  @track partShipppingFlag = '';
  currencyCode='USD';

  // @wire(MessageContext)
  // messageContext;
  @track zipCode;
  connectedCallback() {
    this.handleSubscribe();
 
    if (localStorage.getItem('zipcode')) {
      //An Id key is in the local Storage
      this.localStorageZipCode = JSON.parse(localStorage.getItem('zipcode'));
      this.zipCode = this.localStorageZipCode.Zipcode;
      //console.log('localStorageZipCode zipcode='+this.zipCode);

    }


    if (localStorage.getItem('checkoutProducts')) {
      this.localStorageProducts = JSON.parse(localStorage.getItem('checkoutProducts'));
      // console.log('Checkout Data is ' + JSON.stringify(this.localStorageProducts));
      this.cartId = this.localStorageProducts.cartId;
      this._accountId = this.localStorageProducts.accountId;
      this._cartItems = this.localStorageProducts.allItems;
      this._cartTotal = this.localStorageProducts.cartTotal;
      this.deliveryfee = this.localStorageProducts.deliveryfee;
      this.installationfee = this.localStorageProducts.installationfee;
      this.memberInstallation = this.localStorageProducts.memberinstallationfee;
      // this.partsShipFee = this.localStorageProducts.partsShipFee;
      this.protectionPlanFee=this.localStorageProducts.protectionPlanFee;
      this.memberProtectionPlanFee=this.localStorageProducts.memberProtectionPlanFee;
      this.selectedPartsShip = this.localStorageProducts.partsShipSelected;
      this.partsShipOptions = this.localStorageProducts.partsShipOptions;
      this.showPromotion = this.localStorageProducts.showPromotion;
      this._partsList = this.localStorageProducts.partsList;
      this.partsIds = this.localStorageProducts.partsList.map(part => part.id);
      this.promotions = this.localStorageProducts.promotions;
      this.isUserMember = this.localStorageProducts.isUserMember;

      if (this.partsIds.length !== 0) {
        this.addPartsShippingAsLineItem();
      }

    }

    //decimal value of promotions
    if (this.promotions != null) {
      this.promotionflag = true;
      this._fixedPromo = this.promotions.toFixed(2);
    }

    //member value for delivery
    if (this.deliveryfee > 0) {
      this.deliveryflag = true;
      if (this.isUserMember === true) {
        this.free = 'FREE';
        // console.log("this.isUserMember from checkout Summary", this.isUserMember);
        // console.log("this.free from checkout Summary", this.free);
      }
      else {
        this.free = '';
      }

    } else
      this.deliveryflag = false;

    //installation 
    /*
    if (this.installationfee > 0) {
      this.installationflag = true;
      if (this.isUserMember === true) {
        this.memberinstallationflag = true;
        if (this.memberInstallation === 0) {
            this.free = 'FREE';
        }
        else
            this.free = '';
  
    } else
        this.memberinstallationflag = false;
  
  } else
      this.installationflag = false; */



    //member value for partsShipFee
    if(this.partsShipOptions){
    if (this.partsShipOptions.length !== 0 && this.partsShipFee) {
      if (this.partsShipFee === this.partsShipOptions.find(record => record.value === 'Standard_Shipping').additionalParam && this.isUserMember === true) {
        this.partShipppingFlag = 'FREE';
      }
      else {
        this.partShipppingFlag = '';
      }
    }
  }

    if (this.free === 'FREE' && this.isFree === false) {
      this.delivery = 0; this._installationfee = this.memberInstallation; 
      this.protectionFee = this.isUserMember === true ? this.memberProtectionPlanFee : this.protectionPlanFee;

      if (this.showPromotion === true) {
        this.subTotal = this._cartTotal + parseFloat(this._installationFee);
        this.total = (this._cartTotal + parseFloat(this._installationFee) + parseFloat(this.protectionFee)) - this.promotions;
        //  console.log("FREE CheckoutTotal With Promotions: " + this.total);
      } else {
        this.subTotal = this._cartTotal + parseFloat(this._installationFee) + parseFloat(this.protectionFee);
        this.total = this._cartTotal + parseFloat(this._installationFee);
        // console.log("FREE CheckoutTotal Without Promotions: " + this.total);
        // console.log("_installationFee,installationfee,memberInstallation 1",this.installationfee,this._installationFee,this.memberInstallation,this.memberinstallationflag);

      }
    } else if (this.free === 'FREE' && this.isFree === true) {
      this.delivery = 0;
      // this._installationFee = this.memberinstallationflag === true ? this.memberInstallation : this.installationfee;

      if ((this.showPromotion === true)) {
        this.subTotal = this._cartTotal;
        this.total =  this._cartTotal - this.promotions;
        // console.log("CartTotal With Promotions without partshipfee: " + this.total);
      } else {
        this.subTotal = this._cartTotal;
        this.total = this._cartTotal;
        //   console.log("_installationFee,installationfee,memberInstallation 2",this.installationfee,this._installationFee,this.memberInstallation,this.memberinstallationflag);
        //   console.log("CartTotal Without Promotions without partshipfee: " + this.total);
      }
    }
    else {
      this._installationFee = this.memberinstallationflag === true ? this.memberInstallation : this.installationfee;
      this.protectionFee = this.isUserMember === true ? this.memberProtectionPlanFee : this.protectionPlanFee;
      console.log("Protetcion Plan fee in checkout", this.protectionFee, this.isUserMember, this.memberProtectionPlanFee, this.protectionPlanFee);

      //console.log(" this.memberinstallationflag from checkout summary",  this.memberinstallationflag);
      //console.log(" this.memberInstallation from checkout summary",  this.memberInstallation);
      //console.log(" this._installationFee from checkout summary",  this._installationFee);

      if ((this.showPromotion === true)) {
         this.total = (this._cartTotal + parseFloat(this.deliveryfee) + parseFloat(this._installationFee) + parseFloat(this.protectionFee)) - this.promotions;
        console.log("CartTotal With Promotions without partshipfee: " + this.total);
      } else {
        this.subTotal = this._cartTotal + parseFloat(this._installationFee) + parseFloat(this.protectionFee);
        this.total = this._cartTotal + parseFloat(this.deliveryfee) + parseFloat(this._installationFee) + parseFloat(this.protectionFee);
        // console.log("CartTotal Without Promotions without partshipfee: " + this.total);
      }

    }

    if (this.partShipppingFlag === '') {
      this.total += this.partsShipFee;
      // console.log("CartTotal With PartShipFee: " + this.total);

    }

    if (this.total != null) {
      this._fixedTotal = this.total.toFixed(2);
    }

    //decimal for checkout total
    if (this.subTotal != null) {
      this._fixedcartTotal = this.subTotal.toFixed(2);
    }

    /*

    console.log("total from checkout summary" + this.total);
    console.log("isUserMember from checkout summary" + this.isUserMember);
    console.log("Fixed total from checkout summary" + this._fixedTotal);
    console.log("_fixedcartTotal from checkout summary" + this._fixedcartTotal);
    console.log("deliveryfee from checkout summary" + this.deliveryfee);
    console.log("partsShipFee from checkout summary" + this.partsShipFee);
    console.log("Promotion Flag" + this.promotionflag);
    console.log("promotions from checkout summary" + this.promotions);
    console.log("installationfee from checkout summary" + this.installationfee); */
    //}





  }

  calculateTotal() {

    this.addPartsShippingAsLineItem();
  
    this.total = 0.0;
    //decimal value of promotions
    if (this.promotions != null) {
      this.promotionflag = true;
      this._fixedPromo = this.promotions.toFixed(2);
    }

    //member value for delivery
    if (this.deliveryfee > 0) {
      this.deliveryflag = true;
      if (this.isUserMember === true) {
        this.free = 'FREE';
        // console.log("this.isUserMember from checkout Summary", this.isUserMember);
        // console.log("this.free from checkout Summary", this.free);
      }
      else {
        this.free = '';
      }

    } else
      this.deliveryflag = false;



    //member value for partsShipFee
    if(this.partsShipOptions){
    if (this.partsShipOptions.length !== 0 && this.partsShipFee) {
      if (this.partsShipFee === this.partsShipOptions.find(record => record.value === 'Standard_Shipping').additionalParam && this.isUserMember === true) {
        this.partShipppingFlag = 'FREE';
      }
      else {
        this.partShipppingFlag = '';
      }
    }
  }

    if (this.free === 'FREE' && this.isFree === false) {
      this.delivery = 0; this._installationfee = this.memberInstallation; 
      this.protectionFee = this.isUserMember === true ? this.memberProtectionPlanFee : this.protectionPlanFee;
     

      if (this.showPromotion === true) {
        this.subTotal = this._cartTotal + parseFloat(this._installationFee) + parseFloat(this.protectionFee);
        this.total = (this._cartTotal  + parseFloat(this._installationFee) + + parseFloat(this.protectionFee)) - this.promotions;
        //console.log("FREE CheckoutTotal With Promotions: " + this.total);
      } else {
        this.total = this._cartTotal + parseFloat(this._installationFee) + parseFloat(this.protectionFee);
        //console.log("FREE CheckoutTotal Without Promotions: " + this.total);
        //console.log("_installationFee,installationfee,memberInstallation 1 later",this.installationfee,this._installationFee,this.memberInstallation,this.memberinstallationflag);

      }
    }
    else if (this.free === 'FREE' && this.isFree === true) {
      this.delivery = 0;
      // this._installationFee = this.memberinstallationflag === true ? this.memberInstallation : this.installationfee;

      if ((this.showPromotion === true)) {
        this.subTotal = this._cartTotal;
        this.total = this._cartTotal - this.promotions ;
        // console.log("CartTotal With Promotions without partshipfee: " + this.total);
      } else {
        this.subTotal = this._cartTotal;
        this.total = this._cartTotal;
        // console.log("_installationFee,installationfee,memberInstallation 2",this.installationfee,this._installationFee,this.memberInstallation,this.memberinstallationflag);
        // console.log("CartTotal Without Promotions without partshipfee: " + this.total);
      }
    }
    else {
      this._installationFee = this.memberinstallationflag === true ? this.memberInstallation : this.installationfee;
      this.protectionFee = this.isUserMember === true ? this.memberProtectionPlanFee : this.protectionPlanFee;
      console.log("Protetcion Plan fee in checkout", this.protectionFee, this.isUserMember, this.memberProtectionPlanFee, this.protectionPlanFee);

      if ((this.showPromotion === true)) {
        this.subTotal = this._cartTotal + parseFloat(this._installationFee) + parseFloat(this.protectionFee);
        this.total = (this._cartTotal + parseFloat(this.deliveryfee) + parseFloat(this._installationFee) + parseFloat(this.protectionFee)) - this.promotions;
        //console.log("CartTotal With Promotions without partshipfee: " + this.total);
      } else {
        this.subTotal = this._cartTotal + parseFloat(this._installationFee) + parseFloat(this.protectionFee);
        this.total = this._cartTotal + parseFloat(this.deliveryfee) + parseFloat(this._installationFee) + parseFloat(this.protectionFee);
        //console.log("_installationFee,installationfee,memberInstallation 3",this.installationfee,this._installationFee,this.memberInstallation,this.memberinstallationflag);

        //  console.log("CartTotal Without Promotions without partshipfee 2: " + this.total);
      }

    }

    if (this.partShipppingFlag === '') {
      this.total += this.partsShipFee;
      //console.log("CartTotal With PartShipFee: " + this.total);

    }

    if (this.taxFlag === true) {
      this.total += parseFloat(this.taxAmount);
      //console.log('this.taxAmt', this.taxFlag, this.total);

    }
    //decimal for checkout total
    if (this.total !== null) {
      this._fixedTotal = this.total.toFixed(2);
    }

    //decimal for checkout subtotal
    if (this.subTotal !== null) {
      this._fixedcartTotal = this.subTotal.toFixed(2);
    }

    /*console.log("total from checkout summary" + this.total);
    console.log("isUserMember from checkout summary" + this.isUserMember);
    console.log("Fixed total from checkout summary" + this._fixedTotal);
    console.log("_fixedcartTotal from checkout summary" + this._fixedcartTotal);
    console.log("deliveryfee from checkout summary" + this.deliveryfee);
    console.log("partsShipFee from checkout summary" + this.partsShipFee);
    console.log("Promotion Flag" + this.promotionflag);
    console.log("promotions from checkout summary" + this.promotions);
    console.log("installationfee from checkout summary" + this.installationfee);
    console.log("taxAmt from checkout summary" + this.taxAmt);*/

  }

  
  @wire(CartSummaryAdapter)
  async handleTax({ error, data }) {
   if (data) {
      console.log('CartSummaryAdapter data-->', data);
      this.showSpinner = true; 
      await new Promise((resolve) => setTimeout(resolve, 5000));
      this.getTaxAmount();
      console.log("getTaxAmount called");
    }
    if (error) {
      console.log('error===' + error);
    }
  }

  cartRedirect() {
    this[NavigationMixin.Navigate]({
      type: 'comm__namedPage',
      attributes: {
        name: 'Current_Cart'
      }
    });

  }
  handleSubscribe() {
    if (this.subscription) {
      return;
    }
    this.subscription = subscribe(this.messageContext, zipCodeChannel, (message) => {
      console.log(message.message);

      const fullAddress = message.message;
      this.zipCode = fullAddress.Zipcode;
      console.log('subscribe zipcode===' + this.zipCode);
     
    });
  }
  @wire(getAllRelatedCartItem, { cartId: '$cartId', zipCode: '$zipCode' })
  cartItems({ data, err }) {
    console.log('cartItemId===' + this.cartId);
    if (data) {
      console.log('data' + JSON.stringify(data))
      this._installationServices = data.relatedItemAll;
      if (this._installationServices.length > 0) {
        this.installationFlag = true;

        if (this.isUserMember === true) {
          this.memberinstallationflag = true;
          if (this.memberInstallation === 0) {
            this.isFree = true;
            this.free = 'FREE';
          }
          else
            this.isFree = false;
          this.free = '';
          console.log("memberInstallation free?", this.free);

        } else
          this.memberinstallationflag = false;
      }
      else {
        this.installationFlag = false;
      }
      console.log('this._installationServices==' + JSON.stringify(this._installationServices));
    }
    if (err) {
      console.log('error==' + JSON.stringify(err))
    }
  }

  installationChangeCapture() {
    this.installationFeeServices();
  }
  installationFeeServices() {

    bwc_getRelatedCartItemAll({ itemId: this.cartId, isMember: this.isUserMember, zipCode: this.zipCode })
      .then(result => {

        console.log('data Total Install checkout summary' + JSON.stringify(result));

        this.installationfee = result.totalFee;
        this.memberInstallation = result.memberTotalFee;
        this.calculateTotal();

      })
      .catch(error => {
        console.log('error===' + JSON.stringify(error))
      })


  }

  addPartsShippingAsLineItem() {
    addPartsShippingAsLineItem({ sku: this.selectedPartsShip, cartId: this.cartId, cartItemIdList: this.partsIds })
      .then(result => {
        this.partsShipFee = result[0].BWC_Service_Price__c;
        console.log("##partsShipFee checkoutSummary", this.partsShipFee);
        console.log('##Parts Ship Fee Result checkoutSummary===' + JSON.stringify(result));
      })
      .catch(error => {
        console.log(' ##Parts Ship Fee error checkoutSummary===' + JSON.stringify(error));


      })
  }
 

taxAmount;
getTaxAmount(){
 getTaxAmount({ cartId: this.cartId})
 .then(async (result) => {
     console.log('##Tax in checkoutSummary===' + JSON.stringify(result));
     this.taxAmt = await result.reduce((acc, item) => acc + item.Amount, null);
     this.taxAmount= (this.taxAmt).toFixed(2);     
     console.log("##taxAmt checkoutSummary", this.taxAmount);
     if (this.taxAmount !== null && this.taxAmount !== undefined){
       this.taxFlag = true;
       this.showSpinner = false;
       console.log('this.taxFlag', this.taxFlag);
       this.calculateTotal();
       if (this.taxFlag === true) {
         this.sendMessageToPayment();
       }
     }
   })
   .catch(error => {
     console.log(' ##taxAmt checkoutSummary error==' + JSON.stringify(error));  
   })    
}

  sendMessageToPayment() {
    const payLoad = { enablePaymentIntent: true };
    publish(this.messageContext, CHECKOUT_CHANNEL, payLoad);
    //console.log('sendMessageToPayment::Tax()::enabling Payments elements load = ' + JSON.stringify(payLoad));

  }
}