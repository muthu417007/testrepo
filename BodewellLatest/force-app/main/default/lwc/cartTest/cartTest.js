/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, api, track, wire } from "lwc";
import { navigate, NavigationContext } from "lightning/navigation";
import deleteCartItem from "@salesforce/apex/BWC_CartController.deleteCartItem";
import updateCartItem from "@salesforce/apex/BWC_CartController.updateCartItem";
import { publish, subscribe, MessageContext, createMessageContext } from "lightning/messageService";
import bwcCartPage from "@salesforce/messageChannel/bwcCartPage__c";
//import { subscribe, MessageContext } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import bwc_CouponApplied from '@salesforce/messageChannel/bwc_CouponApplied__c';
import { updateItemInCart, applyCouponToCart } from 'commerce/cartApi';
import USER_ID from '@salesforce/user/Id';
import zipCodeChannel from '@salesforce/messageChannel/zipCodeChange__c';
import getShipTypeFee from '@salesforce/apex/BWC_CartController.getShipTypeFees';

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
    @track _deliveryFee=0.0;
    @track _installationFee = 0.0;
    @track _memberSKU = false;
    @track _memberList = [];

    _cartProductAmountWithDiscount;
    _cartPromotionAdjustmentTotal;
    _cartTotalWithPromotions;
    @track _savedAmt = 0.0;
    subscription3;
    //couponCode = '';


    // added on 9/10  -- santhosh 
    pickupListflag = false;
    sdsListFlag = false;
    @track _pickupList = [];
    @track _sdsList = [];
    
    // couponName = '';
    // couponStatus = '';
    // couponStartDateTime = '';
    // couponEndDateTime = '';
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
            console.log('bwc_cartCopy zipcode ' + this.zipCode);

        }
        console.log('bwc_cartCopy ZIPCODE IS ==> ' + this.zipCode);

        this.subscribeToCouponApplied();
        this.handleSubscribe();

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
            console.log("Message from Coupon Subscriber"+ JSON.stringify(couponCode.message));
            this.handleCouponApplied(couponCode);
            });
    }

    // handleCouponApplied(message) {
    //     this.couponCode = message.couponCode;
    //     this.couponName = message.couponName;
    //     this.couponStatus = message.couponStatus;
    //     this.couponStartDateTime = message.couponStartDateTime;
    //     this.couponEndDateTime = message.couponEndDateTime;

    // }     

    async handleCouponApplied(couponCodeReceived){
        const couponCode = couponCodeReceived.message;
        console.log("couponCode in cart"+this.couponCode);

    await applyCouponToCart(couponCode);
    
    setTimeout(() => {
        this.getPriceAndQuantity();
        this.template.querySelector('c-bwc_product-ship-type').filterCartItems(this._cartItems);
        this.publishMessage();
        }, 1000); 

    }

    get isCouponApplied() {
         return (this.couponCode !== '');
        }

    // showToast(title, message) {
    //     const toastEvent = new ShowToastEvent({
    //         title: title,
    //         message: message,
    //         variant: 'info'
    //     });
    //     this.dispatchEvent(toastEvent);
    // }

    //called inside handlermethod
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
        this._savedAmt = 0.0;
        this._memberList = [];
        //subTotal =0.0;
        if (this._cartItems) {
            for (let i = 0; i < this._cartItems.length; i++) {
                this._totalQuantity += parseInt(this._cartItems[i].quantity);
                this._cartTotal += parseFloat(this._cartItems[i].amount);
                this._savedAmt += parseFloat(this._cartItems[i].adjustmentAmount);

                if (this._cartItems[i].ProductDetails.fields.StockKeepingUnit === 'BODEWELL MEMBERSHIP') {
                    console.log("Found Membership SKU");
                    this._memberList.push(this._cartItems[i]);

                }

               // this._cartTotal = subTotal.toFixed(2);

            }
            if (this._memberList.length > 0) {
                this._memberSKU = true;
            } else this._memberSKU = false;
        }
    }


    //Categorisation of products
    filterCartItems(event) {

        this._hdList = [];
        this._prodShippingList = [];
        this._partsList = [];
        this._sdsList = [];
        this._pickupList = [];
        this._deliveryFee = 0.0;
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

        /*if (this.hdListflag || this.sdsListFlag) {
            this._deliveryFee = 99;
        }*/
        this.getPriceAndQuantity();
        this.publishMessage();

        return false;
    }
    @wire(getShipTypeFee)
    wiredRecs({ data, error }) {

        if (data) {
            let shipOptions = [];
            console.log('ship resp ' + JSON.stringify(data));
            for (let i = 0; i < data.length; i++) {
                if (data[i].DeveloperName == 'HOME_DELIVERY') {
                    this._deliveryFee = data[i].Price__c;
                } else if (data[i].DeveloperName == 'FREESTANDING_INSTALL_2STEP') {
                    this._installationFee = 0;
                    // data[i].Price__c;
                } else if (data[i].DeveloperName == 'SMALL_PACKAGE_DELIVERY') {
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
    
    
    // async handleValueChange(event) {
    //     const { value, cartItemId } = event.detail;       
    //     const shipTypeComponent = this.template.querySelector('c-bwc_product-ship-type');
        
    //     console.log("before Update");
        
    //     await this.updateItemInCart(cartItemId, value);
        
    //     console.log("After Update");
      
    //     // Call the functions after updateItemInCart() executes
    //     this.getPriceAndQuantity();
    //     shipTypeComponent.filterCartItems(this._cartItems);
    //     this.publishMessage();
    //   }
      
    //   async updateItemInCart(cartItemId, value) {
    //     // Perform the updateItemInCart logic here
    //     // This is just an example of an asynchronous operation
    //     return new Promise((resolve) => {
    //       setTimeout(() => {
    //         console.log('updateItemInCart completed');
    //         resolve();
    //       }, 1000);
    //     });
    //   }
      
      
    async handleValueChange(event) {
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
        
            // .then((response) => {
                /* console.log("Response", response);
            let updatedCartItem = JSON.parse(JSON.stringify(response));
      
            for (let i = 0; i < this._cartItems.length; i++) {
              if (cartItemId === this._cartItems[i].id) {
                let currentCartItem = JSON.parse(JSON.stringify(this._cartItems[i]));
                
               //updatedCartItem.ProductDetails.fields=updatedCartItem.productDetails.fields;
                
               // let fields={ 'fields': currentCartItem.ProductDetails.fields};
                updatedCartItem.ProductDetails={ 'fields': currentCartItem.ProductDetails.fields};

                updatedCartItem.productDetails.fields = currentCartItem.ProductDetails.fields;
                console.log("Cloned cartItem details", currentCartItem.ProductDetails.fields);
                
              
                updatedCartItem.amount= updatedCartItem.totalPrice;
                updatedCartItem.salesPrice= updatedCartItem.totalPrice;
                //updatedCartItem.quantity= updatedCartItem.quantity ;
                updatedCartItem.adjustmentAmount= updatedCartItem.totalAdjustmentAmount ;
             
               // currentCartItem.quantity= updatedCartItem.quantity ;
                //currentCartItem.adjustmentAmount= updatedCartItem.totalAdjustmentAmount ;
                //const updateCartItemLatest=[...updateCartItem];
                cartItemsList.splice(i, 1, updatedCartItem);
                console.log("replaced list"+JSON.stringify(cartItemsList));
                //break;                
              }
            }
      
            this._cartItems = Array.from(cartItemsList); 
            //this._cartItems = cartItemsList;
            console.log("Updated cartItems" +JSON.stringify(this._cartItems));
            this.getPriceAndQuantity();
            shipTypeComponent.filterCartItems(this._cartItems);
            this.publishMessage(); */
            // })
            // .catch((error) => {
            //     console.error('An error occurred:', error);
            // });
        //this.getPriceAndQuantity();
        //shipTypeComponent.filterCartItems(this._cartItems);
        // this.publishMessage();
    //} 

    // handleValueChange(event) {
    //     const value = event.detail.value;
    //     const cartItemId = event.detail.cartItemId;
    //     const shipTypeComponent = this.template.querySelector('c-bwc_product-ship-type');
    //     console.log("Typeof of updateItemto cart" + typeof updateItemInCart, updateItemInCart);

    //     Promise.resolve(updateItemInCart(cartItemId, value))
    //         .then((response) => {             

    //             // Additional logic after successful update
    //             //let updatedCartItems = JSON.parse(JSON.stringify(response));
    //           //  this.cart();
    //             console.log('Item updated in cart successfully'+ JSON.stringify(response));
    //            // this._cartItems=updatedCartItems;

    //             // this.getPriceAndQuantity();
    //             // shipTypeComponent.filterCartItems(this._cartItems);
    //             // this.publishMessage();

    //         })
    //         .catch((error) => {
    //             console.error('An error occurred:', error);
    //             // Additional error handling
    //         });
    //         console.log('Item updated in cart successfully'+ JSON.stringify(this._cartItems));

    //        // shipTypeComponent.filterCartItems(this._cartItems);

    // }
    // handleValueChange(event) {
    //     const { value, cartItemId } = event.detail;

    //     const shipTypeComponent = this.template.querySelector('c-bwc_product-ship-type');

    //     Promise.resolve()
    //       .then(() => updateItemInCart(cartItemId, value))
    //       .then((response) => {
    //         this.cart(); // Assuming this is a valid function and performs necessary operations with the updated cart data
    //       })
    //       .catch((error) => {
    //         console.error('An error occurred:', error);
    //       })
    //     //   .finally(() => {
    //     //    // this.cart();
    //     //     //shipTypeComponent.filterCartItems(this._cartItems);
    //     //     this.getPriceAndQuantity();
    //     //     this.publishMessage();
    //      // });
    //   }



    // handleValueChange(event) {
    //     const value = event.detail.value;
    //     const cartItemId = event.detail.cartItemId;
    //     const itemPrice = this._cartItems.find(
    //         (item) => item.id === cartItemId
    //     ).price;
    //     const itemSavedPrice = this._cartItems.find(
    //         (item) => item.id === cartItemId
    //     ).adjustmentAmount;

    //     updateCartItem({
    //             webstoreId: this._webStoreId,
    //             effectiveAccountId: this._accountId,
    //             activeCartOrId: this._cartStatus,
    //             cartItemId: cartItemId,
    //             newQuantity: value,
    //             cartItemPrice: itemPrice * value,
    //             cartItemSavedAmt : ((itemSavedPrice) * value)
    //         })
    //         .then(() => {
    //             console.log("reached updatecartItem in Cart Comp");
    //             this.changeCartItem(cartItemId, value, itemPrice * value, ((itemSavedPrice) * value) );

    //         })
    //         .catch((e) => {

    //             console.log("Error in changeCartItem Method===" + JSON.stringify(e));
    //         });
    // }

    // //UI changes on update - product price, exclusive savings? promotional savings?
    // changeCartItem(cartItemId, newQuantity, cartItemPrice, cartItemSavedAmt) {

    //     let updatedCartItems = JSON.parse(JSON.stringify(this._cartItems));
    //     (updatedCartItems || []).map((item) => {
    //         console.log("MAP" + item);
    //         if (item.id === cartItemId) {
    //             item.quantity = newQuantity;
    //             item.salesPrice = cartItemPrice;
    //             item.adjustmentAmount = cartItemSavedAmt;
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