/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, api, track, wire } from "lwc";
import { navigate, NavigationContext } from "lightning/navigation";
//import deleteCartItem from "@salesforce/apex/BWC_CartController.deleteCartItem";
//import updateCartItem from "@salesforce/apex/BWC_CartController.updateCartItem";
import { publish, subscribe, MessageContext, createMessageContext } from "lightning/messageService";
import bwcCartPage from "@salesforce/messageChannel/bwcCartPage__c";
//import USER_ID from '@salesforce/user/Id';
import zipCodeChannel from '@salesforce/messageChannel/zipCodeChange__c';

export default class Bwc_cartPage extends LightningElement {

    @track _cartItems = [];
    _cartId;
    _quantity;
    _navigationContext;
    _prodQuantity = false;
    _webStoreId;
    _accountId;
    _cartStatus;
    _cartItemCount = 0;
    @track _partsList = [];
    @track _hdList = [];
    @track _prodShippingList = [];
    hdListflag = false;
    partsListflag = false;
    prodShippingListflag = false;
    @track _totalQuantity = 0;
    @track _cartTotal = 0.0;
    // added on 9/5 for temporary
    availableQuantityDummy = 100;
    _deliveryFee;
    _installationFee = 0.0;
    @track _memberSKU = false;
    @track _memberList = [];

    _cartProductAmountWithDiscount;
    _cartPromotionAdjustmentTotal;
    _cartTotalWithPromotions;
    @track zipCode;
    @track _savedAmt = 0;
    // added on 9/10  -- santhosh 
    pickupListflag = false;
    sdsListFlag = false;
    @track _pickupList = [];
    @track _sdsList = [];
    @track localStorageZipCode;
    context = createMessageContext();
    subscription;
    connectedCallback() {
        //this.filterCartItems();
        // this.getPriceAndQuantity();
        if (localStorage.getItem('zipcode')) {
            this.localStorageZipCode = JSON.parse(localStorage.getItem('zipcode'));
            this.zipCode = this.localStorageZipCode.Zipcode;
            console.log('IF ZIPCODE IS ==> ' + this.zipCode);

        }
        console.log('ZIPCODE IS ==> ' + this.zipCode);
        this.handleSubscribe();


    }

    isRendered;
    renderedCallback() {

        // if (!this.isRendered) {
        //     //this.filterCartItems();
        //     this.getPriceAndQuantity();
        //     //this.template.querySelector('c-bwc_product-ship-type').filterCartItems(this._cartItems);
        //     this.publishMessage();
        //     this.isRendered = true;
        // }

    }

    handleSubscribe() {
        if (this.subscription) {
            return;
        }
        this.context = createMessageContext();

        this.subscription = subscribe(this.context, zipCodeChannel, (message) => {
            const fullAddress = message.message;
            this.zipCode = fullAddress.Zipcode;
            console.log('ZIP CODE subscribe------ ' + this.zipCode);


        });
    }


    @wire(MessageContext)
    messageContext;

    //called inside handlermethod
    publishMessage() {
        let messagePayload = {
            source: "LWC",
            myObjectField: {
                total: this._cartTotal,
                delivery: this._deliveryFee,
                installation: this._installationFee
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

    @api
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
    }

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

    getPriceAndQuantity() {
            console.log("Inside getPrice and Quantity");
            this._totalQuantity = 0;
            this._cartTotal = 0.0;
            this._memberList = [];
            if (this._cartItems) {
                for (let i = 0; i < this._cartItems.length; i++) {
                    this._totalQuantity += this._cartItems[i].quantity;
                    this._cartTotal += this._cartItems[i].salesPrice;
                    this._savedAmt = this._cartItems[i].TotalAdjustmentAmount;


                    //     if(this._cartItems[i].stockKeepingUnit==='BODEWELL MEMBERSHIP')
                    //     {

                    //         this._memberList.push(this._cartItems[i]);

                    //     }

                    // }
                    // if (this._memberList.length == 1) {
                    //     this._memberSKU = true;
                    //   } else this._memberSKU = false;
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
        //this._totalQuantity = 0;
        //this._cartTotal = 0.0;
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
            //for (let i = 0; i < this._cartItems.length; i++) {
            //  this._totalQuantity += this._cartItems[i].quantity;
            //this._cartTotal += this._cartItems[i].salesPrice;
            /*if (
          this._cartItems[i].ProductDetails.fields.BWC_Is_Part__c === "true" &&
          this._cartItems[i].ProductDetails.fields.BWC_Delivery_Type__c ===
            "sps fee"
        ) {
          this._partsList.push(this._cartItems[i]);
      
        }

        if (
          this._cartItems[i].ProductDetails.fields.BWC_Delivery_Type__c === "hd"
        ) {
          this._hdList.push(this._cartItems[i]);
        }
        if (
          this._cartItems[i].ProductDetails.fields.BWC_Delivery_Type__c ===
            "sds" &&
          this._cartItems[i].ProductDetails.fields.Product_Line__c ===
            "Small Appliances"
        ) {
          this._prodShippingList.push(this._cartItems[i]);
        }*/
            //}

            /*if (this._hdList.length > 0) {
              this.hdListflag = true;
            } else this.hdListflag = false;

            if (this._partsList.length > 0) {
              this.partsListflag = true;
            } else this.partsListflag = false;

            if (this._prodShippingList.length > 0) {
              this.prodShippingListflag = true;
            } else this.prodShippingListflag = false;*/
        }

        if (this.hdListflag || this.sdsListFlag) {
            this._deliveryFee = 99;
        }
        this.getPriceAndQuantity();
        this.publishMessage();

        return false;
    }
    handleValueChange(event){
        const value = event.detail.value;
       const cartItemId = event.detail.cartItemId;
    }

    // handleValueChange(event) {
    //     const value = event.detail.value;
    //     const cartItemId = event.detail.cartItemId;
    //     const itemPrice = this._cartItems.find(
    //         (item) => item.id === cartItemId
    //     ).price;

    //     updateCartItem({
    //             webstoreId: this._webStoreId,
    //             effectiveAccountId: this._accountId,
    //             activeCartOrId: this._cartStatus,
    //             cartItemId: cartItemId,
    //             newQuantity: value,
    //             cartItemPrice: itemPrice * value
    //         })
    //         .then(() => {
    //             console.log("reached updatecartItem in Cart Comp");
    //             this.changeCartItem(cartItemId, value, itemPrice * value);

    //         })
    //         .catch((e) => {

    //             console.log("Error in changeCartItem Method===" + JSON.stringify(e));
    //         });
    // }

    //UI changes on update - product price, exclusive savings? promotional savings?
    // changeCartItem(cartItemId, newQuantity, cartItemPrice) {

    //     let updatedCartItems = JSON.parse(JSON.stringify(this._cartItems));
    //     (updatedCartItems || []).map((item) => {
    //         console.log("MAP" + item);
    //         if (item.id === cartItemId) {
    //             item.quantity = newQuantity;
    //             item.salesPrice = cartItemPrice;
    //         }
    //         return false;
    //     });
    //     this._cartItems = updatedCartItems;
    //     //this.filterCartItems();
    //     this.getPriceAndQuantity();
    //     this.template.querySelector('c-bwc_product-ship-type').filterCartItems(this._cartItems);

    //     this.publishMessage();
    // }

    clearCartItem(evt) {
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
        //this.filterCartItems();
        this.getPriceAndQuantity();
        this.template.querySelector('c-bwc_product-ship-type').filterCartItems(this._cartItems);

        console.log(
            "UpdatedCartItems:after RemovedItem===" + JSON.stringify(this._cartItems)
        );
    }
}