/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, api, track, wire } from "lwc";
import { navigate, NavigationContext } from "lightning/navigation";
//import deleteCartItem from "@salesforce/apex/BWC_CartController.deleteCartItem";
import { refreshApex } from '@salesforce/apex'
//import updateCartItem from "@salesforce/apex/BWC_CartController.updateCartItem";
import { publish, subscribe, MessageContext, createMessageContext } from "lightning/messageService";
import bwcCartPage from "@salesforce/messageChannel/bwcCartPage__c";
import bwc_CouponApplied from '@salesforce/messageChannel/bwc_CouponApplied__c';
import bwc_CouponError from '@salesforce/messageChannel/bwc_CouponError__c';
import bwc_cartZipCode from '@salesforce/messageChannel/bwc_cartZipCode__c';
import { updateItemInCart, applyCouponToCart, deleteItemFromCart } from 'commerce/cartApi';
import USER_ID from '@salesforce/user/Id';
import zipCodeChannel from '@salesforce/messageChannel/zipCodeChange__c';
import getShipTypeFee from '@salesforce/apex/BWC_CartController.getShipTypeFees';
import bwc_getRelatedCartItemAll from '@salesforce/apex/BWC_ProductViewServicesController.bwc_getRelatedCartItemAll';
import getSkew from '@salesforce/apex/BWC_ADC.getADC_Details'


export default class Bwc_cartItemsAdvanced extends LightningElement {

    @track skewData;
    @api skewError;
    @track skuArr = [];
    @track availableQuantity;

    @track _cartItems = [];
    _cartId;
    _quantity;
    _navigationContext;
     _webStoreId;
    _accountId;
    _cartStatus;
    _cartItemCount = 0;
    @track _partsList = [];
    @track _hdList = [];
    @track _prodShippingList = [];
    @track _pickupList = [];
    @track _sdsList = [];
   
    @track _totalQuantity = 0;
    @track _cartTotal = 0.0;
    _fixedTotal = 0.0;
    @track _deliveryFee = 0.0;
    @track _installationFee = 0.0;
    @track _memberSKU = false;
    @track _memberList = [];

    _cartProductAmountWithDiscount;
    _cartPromotionAdjustmentTotal;
    _cartTotalWithPromotions;
    @track _savedAmt = 0.0;
    subscription3;
    hdListflag = false;
    partsListflag = false;
    prodShippingListflag = false;
    @track pickupListflag = false;
    sdsListFlag = false;
    

    @track zipCode;
    @track localStorageZipCode;
    context = createMessageContext();
    subscription2;

    @track partsShipOptions;
    smallPackageFee;


    connectedCallback() {
        if (localStorage.getItem('zipcode')) {
            this.localStorageZipCode = JSON.parse(localStorage.getItem('zipcode'));
            this.zipCode = this.localStorageZipCode.Zipcode;
            console.log('bwc_cartItems zipcode ' + this.zipCode);
            this.getSkewData();

        }
        console.log('bwc_cartItems ZIPCODE IS ==> ' + this.zipCode);

        this.subscribeToCouponApplied();
        this.handleSubscribe();

    }
 
    //Returns the available quantity from inventory based on SKU List and zipcode by hitting API
    getAvailableQuantity(sku) {
        if (this.skewData) {
            const foundItem = this.skewData.availabilityDetails.find(details => details.inventoryItemName === sku);
            if (foundItem) {
                return foundItem.availableQuantity || 0;
            }
        }
        return 0;  // Default value if no matching item is found
    }
    
    getSkewData() {
        if (this._cartItems) {
            this.skuArr = this._cartItems.map(item => item.ProductDetails.fields.StockKeepingUnit);
    
            getSkew({
                skuList: this.skuArr,
                postalCodeInstance: this.zipCode
            })
                .then(result => {
                    console.log("getSkew cartItems result>>>" + JSON.stringify(result));
                    this.skewData = result;
    
                    let updatedCartItems = JSON.parse(JSON.stringify(this._cartItems));
                    updatedCartItems= updatedCartItems.map(item => {
                        const sku = item.ProductDetails.fields.StockKeepingUnit;
                        const availableQuantity = this.getAvailableQuantity(sku);
                        console.log("availableQuantity"+availableQuantity);
                        item.availableQuantity=availableQuantity;
                        item.quantity=(item.quantity > item.availableQuantity) ? item.availableQuantity : item.quantity;
                                    
                        return item;
                        
                    });
    
                    this._cartItems = updatedCartItems;
                    this.getPriceAndQuantity();
                    this.template.querySelector('c-bwc_product-ship-type').filterCartItems(this._cartItems);
                    this.publishMessage();
                    console.log("UpdatedCartItems@@@"+JSON.stringify(this._cartItems));
                })
    
                .catch(error => {
                    this.skewError = error;
                    console.log('skewError', error);
                });
        }
    }

    handleSubscribe() {
        if (this.subscription2) {
            return;
        }
        this.context = createMessageContext();

        this.subscription2 = subscribe(this.context, zipCodeChannel, (message) => {
            const fullAddress = message.message;
            this.zipCode = fullAddress.Zipcode;
            console.log('ZIP CODE subscribe from bwc_cartCopy------ ' + this.zipCode);


        });
    }

    publishZipCode(){
        const zipCodeInfo =
        {
            zip:this.zipCode,
            productFlag:this.pickupListflag
        }

        publish(this.messageContext, bwc_cartZipCode, zipCodeInfo);
        console.log("zipCodeInfo from Cart" +JSON.stringify(zipCodeInfo));

    }

    @wire(MessageContext)
    messageContext;
    subscribeToCouponApplied() {
        if (this.subscription3) {
            return;
        }
        this.subscription3 = subscribe(
            this.messageContext,
            bwc_CouponApplied,
            (couponCode) => {
                console.log("Message from Coupon Subscriber" + JSON.stringify(couponCode.message));
                this.handleCouponApplied(couponCode.message);
            });
    }

    async handleCouponApplied(couponCodeReceived) {
        const couponCode = couponCodeReceived;
        console.log("couponCode in cart" + couponCode);
        await applyCouponToCart(couponCode).then(async (isValidCoupon) => {
            console.log("isValidCoupon" + JSON.stringify(isValidCoupon));
            await new Promise((resolve) => setTimeout(resolve, 2000));
            await this.getPriceAndQuantity();
            console.log("getPriceAndQuantity called");
            this.template.querySelector('c-bwc_product-ship-type').filterCartItems(this._cartItems);
            console.log("filterCartItems called");
            this.publishMessage();
            console.log("publishMessage called");
            this.publishSuccess("Coupon code has been applied");
            console.log("publishSuccess called");

        }).catch(error => {

            console.error("Error:", JSON.stringify(error));
            console.error("ErrorMessage:", JSON.stringify(error.message));
            if (error.error.code === 'ALREADY_APPLIED') {
                this.publishError("Coupon already applied");
            } else {
                this.publishError("Invalid coupon code. Please try again.");

            }
        })
    }

    publishSuccess(appliedMsg) {
        const successMsg = { smsg: appliedMsg, emsg: '' }
        publish(this.messageContext, bwc_CouponError, successMsg);
    }

    publishError(errorMessage) {
        const errMsg = { emsg: errorMessage, smsg: '' };
        publish(this.messageContext, bwc_CouponError, errMsg);
    }


    //Sent to cartSummary component
    publishMessage() {

        let messagePayload = {
            source: "LWC",
            myObjectField: {
                total: this._cartTotal,
                delivery: (this._sdsList.length > 0 || this._hdList.length > 0) ? this._deliveryFee : 0,
                installation: (this._sdsList.length > 0 || this._hdList.length > 0) ? this._installationFee : 0,
                partsShipOptions: this._partsList.length > 0 ? this.partsShipOptions : [],
                hdList: this._hdList,
                sdsList: this._sdsList,
                partsList: this._partsList,
                fedexList: this._prodShippingList,
                pickupList: this._pickupList,
                cartItems: this._cartItems,
                promotions: this._savedAmt
            }
        };

        publish(this.messageContext, bwcCartPage, messagePayload);
        console.log("myObjectField" + JSON.stringify(messagePayload.myObjectField));
    }

    @api
    get cart() {
        return this._cartItems;
    }
    set cart(val) {
        this._cartItems = val;
        console.log("_cartItems====" + JSON.stringify(val));
    }

    @api
    get cartId() {
        return this._cartId;
    }
    set cartId(val) {
        this._cartId = val;
        console.log("_cartId====" + JSON.stringify(val));
    }

    @api
    get webStoreId() {
        return this._webStoreId;
    }
    set webStoreId(val) {
        this._webStoreId = val;
        console.log("_webStoreId====" + val);
    }

    @api
    get acctId() {
        return this._accountId;
    }
    set acctId(val) {
        this._accountId = val;
        console.log(`_accountId==== ${val}`);
    }

    @api
    get cartStatus() {
        return this._cartStatus;
    }
    set cartStatus(val) {
        this._cartStatus = val;
        console.log(`_cartStatus===  ${val}`);
    }

   /* @api
    get cartProductAmountWithDiscount() {
        return this._cartProductAmountWithDiscount;
    }
    set cartProductAmountWithDiscount(val) {
        this._cartProductAmountWithDiscount = val;
        console.log(`_cartProductAmountWithDiscount===  ${val}`);
    }

    @api
    get cartPromotionAdjustmentTotal() {
        return this._cartPromotionAdjustmentTotal;
    }
    set cartPromotionAdjustmentTotal(val) {
        this._cartPromotionAdjustmentTotal = val;
        console.log(`_cartPromotionAdjustmentTotal===  ${val}`);
    }

    @api
    get cartTotalWithPromotions() {
        return this._cartTotalWithPromotions;
    }
    set cartTotalWithPromotions(val) {
        this._cartTotalWithPromotions = val;
        console.log(`_cartTotalWithPromotions===  ${val}`);
    } */

    //this Navigation open the PDP page of the product onclick the product name
    @wire(NavigationContext)
    wiredNavigationContext(context) {
        this._navigationContext = context;
    }
    onclickProductName(event) {
        console.log("Product Id" + event.target.dataset.id);
        navigate(this._navigationContext, {
            type: "standard__recordPage",
            attributes: {
                objectApiName: "Product2",
                recordId: event.target.dataset.id,
                actionName: "view"
            }
        });
    }
    @wire(bwc_getRelatedCartItemAll, { itemId: '$_cartId' })
    cartItemsAll({ data, err }) {
        console.log('cartItemId===' + this._cartId);
        if (data) {
            console.log('data Total Install====' + data)
            this._installationFee = data;

        }
        if (err) {
            console.log('error===' + JSON.stringify(err))
        }
    }

    getPriceAndQuantity() {
        console.log("Inside getPrice and Quantity");
        this._totalQuantity = 0;
        this._cartTotal = 0.0;
        this._savedAmt = 0.0;
        this._memberList = [];
        if (this._cartItems) {
            for (let i = 0; i < this._cartItems.length; i++) {
                this._totalQuantity += parseInt(this._cartItems[i].quantity);
                this._cartTotal += parseFloat(this._cartItems[i].amount);
                this._savedAmt += parseFloat(this._cartItems[i].adjustmentAmount);

                if (this._cartItems[i].ProductDetails.fields.StockKeepingUnit === 'BODEWELL MEMBERSHIP') {
                    console.log("Found Membership SKU");
                    this._memberList.push(this._cartItems[i]);

                }
            }
            this._cartTotal = this._cartTotal - this._installationFee;
            this._fixedTotal = this._cartTotal.toFixed(2);
            console.log("fixedTotalinCart" + this._fixedTotal);

            if (this._memberList) {
                if (this._memberList.length > 0) {
                    this._memberSKU = true;
                } else this._memberSKU = false;
            }
        }

    }


    //Categorisation of products
    filterCartItems(event) {

        this._hdList = [];
        this._prodShippingList = [];
        this._partsList = [];
        this._sdsList = [];
        this._pickupList = [];

        if (this._cartItems) {
            const segregagatedProductList = event.detail.shipTypeProducts;
            this._hdList = segregagatedProductList.hdList;
            this._partsList = segregagatedProductList.partsList;
            this._prodShippingList = segregagatedProductList.prodShippingList;
            this._pickupList = segregagatedProductList.pickupList;
            this._sdsList = segregagatedProductList.sdsList;
            this.hdListflag = segregagatedProductList.hdFlag;
            this.sdsListFlag = segregagatedProductList.sdsFlag;
            this.partsListflag = segregagatedProductList.partsFlag;
            this.prodShippingListflag = segregagatedProductList.prodFlag;
            this.pickupListflag = segregagatedProductList.pickupFlag;

        }


        this.getPriceAndQuantity();
        this.publishMessage();
        this.publishZipCode();

        return false;
    }
    @wire(getShipTypeFee)
    wiredRecs({ data, error }) {

        if (data) {
            let shipOptions = [];
            console.log('ship resp ' + JSON.stringify(data));
            for (let i = 0; i < data.length; i++) {
                if (data[i].DeveloperName == 'HOME_DELIVERY') {
                    this._deliveryFee = parseFloat(data[i].Price__c);
                }

                else if (data[i].DeveloperName == 'SMALL_PACKAGE_DELIVERY') {
                    this.smallPackageFee = data[i].Price__c;
                } else if (data[i].Product_SKU__c == 'PARTS SHIPPING') {
                    let labelval = data[i].MasterLabel + ' $' + data[i].Price__c;
                    console.log('Label Name is ' + labelval);
                    let shipRecord = { label: labelval, value: labelval };
                    console.log('ship record is ' + JSON.stringify(shipRecord));
                    shipOptions.push(shipRecord);
                }

            }
            this.partsShipOptions = shipOptions;
            console.log('SHIPPING OPTIONS ' + JSON.stringify(this.partsShipOptions));

        } else if (error) {

            console.log('error ' + error);

        }
    }

    async handleValueChange(event) {
        const { value, cartItemId } = event.detail;
        await updateItemInCart(cartItemId, value);
        await new Promise((resolve) => setTimeout(resolve, 2000));
        this.getPriceAndQuantity();
       // console.log("getPriceAndQuantity called");
        this.template.querySelector('c-bwc_product-ship-type').filterCartItems(this._cartItems);
        //console.log("filterCartItems called");
        this.publishMessage();
        //console.log("publishMessage called");

    }

    async clearCartItem(evt){
        let cartItemId = evt.target.dataset.id;
        await deleteItemFromCart(cartItemId);        
        await new Promise((resolve) => setTimeout(resolve, 2000));
        this.getPriceAndQuantity();
               console.log("getPriceAndQuantity called from delete");

        this.template.querySelector('c-bwc_product-ship-type').filterCartItems(this._cartItems);
                console.log("filterCartItems called from delete");

        refreshApex(this._installationFee);  
        console.log('refreshApex called');      
        this.publishMessage();
                console.log("publishMessage called from delete");


    }

}
 /*   clearCartItem(evt) {
        let cartItemId = evt.target.dataset.id;
        console.log(cartItemId);
        deleteCartItem({
            webstoreId: this._webStoreId,
            effectiveAccountId: this._accountId,
            activeCartOrId: this._cartStatus,
            cartItemId: cartItemId
        })
            .then(() => {
                this.removeCartItem(cartItemId);
                refreshApex(this.cartItemsAll);
                console.log("CartItemId in clearcartItem Method===" + cartItemId);
            })
            .catch((e) => {
                console.log("Error in clearcartItem Method===" + e);
            });
    }

    removeCartItem(cartItemId) {
        const removedItem = (this._cartItems || []).filter(
            (item) => item.id === cartItemId
        )[0];
        console.log("RemovedItem===" + JSON.stringify(removedItem));
        const quantityOfRemovedItem = removedItem ? removedItem.quantity : 0;
        console.log("RemovedItemQuantity===" + quantityOfRemovedItem);
        const updatedCartItems = (this._cartItems || []).filter(
            (item) => item.id !== cartItemId
        );
        // Update the cartItems with the change
        this._cartItems = updatedCartItems;
        this.getPriceAndQuantity();
        this.template.querySelector('c-bwc_product-ship-type').filterCartItems(this._cartItems);
        this.publishMessage();
        console.log(
            "UpdatedCartItems:after RemovedItem===" + JSON.stringify(this._cartItems)
        );
    }
}

/*async handleValueChange(event) {
      const { value, cartItemId } = event.detail;
      const shipTypeComponent = this.template.querySelector('c-bwc_product-ship-type');
      //let cartItemsList = JSON.parse(JSON.stringify(this._cartItems));
      console.log("before Update");
      await updateItemInCart(cartItemId, value);
      console.log("After Update");

      setTimeout(() => {
          this.getPriceAndQuantity();
          //this.template.querySelector('c-bwc_product-ship-type').filterCartItems(this._cartItems);
          shipTypeComponent.filterCartItems(this._cartItems);
          this.publishMessage();
      }, 1000);

  }

handleValueChange(event) {
        const value = event.detail.value;
        const cartItemId = event.detail.cartItemId;
        const itemPrice = this._cartItems.find(
            (item) => item.id === cartItemId
        ).price;
        const itemSavedPrice = this._cartItems.find(
            (item) => item.id === cartItemId
        ).adjustmentAmount;

        updateCartItem({
                webstoreId: this._webStoreId,
                effectiveAccountId: this._accountId,
                activeCartOrId: this._cartStatus,
                cartItemId: cartItemId,
                newQuantity: value,
                cartItemPrice: itemPrice * value,
                cartItemSavedAmt : ((itemSavedPrice) * value)
            })
            .then(() => {
                console.log("reached updatecartItem in Cart Comp");
                this.changeCartItem(cartItemId, value, itemPrice * value, ((itemSavedPrice) * value) );

            })
            .catch((e) => {

                console.log("Error in changeCartItem Method===" + JSON.stringify(e));
            });
    }

    //UI changes on update - product price, exclusive savings? promotional savings?
    changeCartItem(cartItemId, newQuantity, cartItemPrice, cartItemSavedAmt) {

        let updatedCartItems = JSON.parse(JSON.stringify(this._cartItems));
        (updatedCartItems || []).map((item) => {
            console.log("MAP" + item);
            if (item.id === cartItemId) {
                item.quantity = newQuantity;
                item.salesPrice = cartItemPrice;
                item.adjustmentAmount = cartItemSavedAmt;
            }
            return false;
        });
        this._cartItems = updatedCartItems;
        //this.filterCartItems();
        this.getPriceAndQuantity();
        this.template.querySelector('c-bwc_product-ship-type').filterCartItems(this._cartItems);

        this.publishMessage();
    } */