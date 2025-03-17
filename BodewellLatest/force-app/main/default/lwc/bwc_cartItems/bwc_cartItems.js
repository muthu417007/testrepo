/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, api, track, wire } from "lwc";
import { navigate, NavigationContext } from "lightning/navigation";
import basePath from '@salesforce/community/basePath';
import BuyerGroup from '@salesforce/label/c.BWC_BuyerGroup';
import MEMBER_SKU from '@salesforce/label/c.BWC_BodewellMemberSKU';
import ProtectionPlanDiscount from '@salesforce/label/c.BWC_ProtectionPlanDiscount';
import BWC_UI from '@salesforce/resourceUrl/BodewellTheme';
import revertMembership from '@salesforce/apex/BWC_PAController.revertMembership';
import PRODUCTIDMEMBER from "@salesforce/label/c.BWC_Product_Id_For_Member";
import { publish, subscribe, MessageContext, createMessageContext } from "lightning/messageService";
import bwcCartPage from "@salesforce/messageChannel/bwcCartPage__c";
import bwc_cartZipCode from '@salesforce/messageChannel/bwc_cartZipCode__c';
import bwc_membershipSavings from '@salesforce/messageChannel/bwc_membershipSavings__c';
import { updateItemInCart, applyCouponToCart, deleteCouponFromCart, deleteItemFromCart } from 'commerce/cartApi';
import zipCodeChannel from '@salesforce/messageChannel/zipCodeChange__c';
import getShipTypeFee from '@salesforce/apex/BWC_CartController.getShipTypeFees';
import getBuyerGroup from '@salesforce/apex/BWC_CartController.getBuyerGroup';
import fetchPrices from '@salesforce/apex/BWC_CartController.fetchPrices';
import bwc_getRelatedCartItemAll from '@salesforce/apex/BWC_ProductViewServicesController.bwc_getRelatedCartItemAll';
import getSkew from '@salesforce/apex/BWC_ADC.getADC_Details'

import bwc_CouponApplied from '@salesforce/messageChannel/bwc_CouponApplied__c';
import bwc_CouponError from '@salesforce/messageChannel/bwc_CouponError__c';

export default class Bwc_cartItemsAdvanced extends LightningElement {

    couponCode;
    successMessage;
    errorMessage; 
    couponId;
    openFlag = false;
    showItems = false; 
    memberCartItemId;   
    _cartId;
    _quantity;
    _navigationContext;
    _webStoreId;
    _accountId;
    _cartStatus;
    @track skuArr = [];
    @track _cartItems = [];
    @track _partsList = [];
    @track _hdList = [];
    @track _prodShippingList = [];
    @track _pickupList = [];
    @track _sdsList = [];
    @track _memberList = [];
    @track productIds2 = [];
    @track quantities = [];  
    @track _totalQuantity = 0;
    @track _cartTotal = 0.0;
    @track _fixedTotal = 0.0;
    @track _cartTotalWithDiscount = 0.0;
    @track _cartTotalWithoutDiscount = 0.0;
    @track addPromotions = false;
    @track _deliveryFee = 0.0;
    @track _installationFee = 0.0;
    @track memberInstallationFee = 0.0;
    @track _savedAmt = 0.0;
    @track _memberSKU = false;
    @track _memberSavings = 0.0;
    @track fixedMemberSavings = 0.0
    @track protectionPlanFee = 0.0;
    @track memberProtectionPlanFee= 0.0;
    loading = true;
    subscription3;
    hdListflag = false;
    partsListflag = false;
    prodShippingListflag = false;
    @track cartflag = false;
    @track pickupListflag = false;
    sdsListFlag = false;
    @track cartItemsFlag;
    @track showAsPrice = false;
    isMember = false;
    labelMSRP;
    labelDiscount;
    labelPrice;
    @track zipCode;
    @track localStorageZipCode;
    context = createMessageContext();
    subscription2; 
    @track partsShipOptions;
    smallPackageFee;     
    @track skewData;
    @api skewError;   
    @track availableQuantity;
    @track productIds;  
    @track memberProdSavings = 0.0;

    HOME_DELIVERY = BWC_UI + '/icons/checkout-icons/in-home-delivery.svg';
    FEDEX_SHIPPING = BWC_UI + '/icons/checkout-icons/Fedex-shipping.svg';
    FREIGHT_SHIPPED = BWC_UI + '/icons/checkout-icons/Freight-shipped.svg';
    ORDER_PICKUP = BWC_UI + '/icons/checkout-icons/Order-Pick-Up.svg';
    PRODUCT_SHIPPED = BWC_UI + '/icons/checkout-icons/Products-shipped.svg';
    PART_SHIPPED = BWC_UI + '/icons/checkout-icons/Parts-shipped.svg';

    @api
    get cart() {
        return this._cartItems;
    }
    set cart(val) {
        this._cartItems = val;
        console.log("_cartItems====" + JSON.stringify(val));
        if (this._cartItems !== undefined && this._cartItems !== null) {
            this.cartItemsFlag = true;
            this.loading = true;
            this.productIds = this._cartItems.map(cartItem => cartItem.ProductDetails.productId);
            this.productIds2 = [];
            this.quantities = [];
            this._cartItems.forEach(cartItem => {
            this.productIds2.push(cartItem.ProductDetails.productId);
            this.quantities.push(cartItem.quantity);

            //console.log("cartItemsFlag", this.cartItemsFlag);
           // console.log("Product Ids", JSON.stringify(this.productIds));        
            //console.log("Product Ids.quantities", JSON.stringify(this.productIds2), JSON.stringify(this.quantities));
            //console.log("Product Ids and Quantities");
            // for (let i = 0; i < this.productIds2.length; i++) {
            //     console.log("Product Id:", this.productIds2[i], ", Quantity:", this.quantities[i]);
            // }

            });    
        }
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

    connectedCallback() {
        console.log('CartItems connected callback');
        if (localStorage.getItem('zipcode')) {
            this.localStorageZipCode = JSON.parse(localStorage.getItem('zipcode'));
            this.zipCode = this.localStorageZipCode.Zipcode;
            // console.log('bwc_cartItems zipcode ' + this.zipCode);
            this.getSkewData();
        }
       
        this.handleSubscribe();
        this.subscribeToCouponApplied();

    }

    handleSubscribe() {
        if (this.subscription2) {
            return;
        }
        this.context = createMessageContext();

        this.subscription2 = subscribe(this.context, zipCodeChannel, (message) => {
            const fullAddress = message.message;
            this.zipCode = fullAddress.Zipcode;
            //console.log('ZIP CODE subscribe from bwc_cartCopy------ ' + this.zipCode);
        });
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
                .then(async (result) => {
                    console.log("getSkew cartItems result>>>" + JSON.stringify(result));
                    this.skewData = result;
                    let updatedCartItems = JSON.parse(JSON.stringify(this._cartItems));
                    updatedCartItems = updatedCartItems.map(item => {
                        const sku = item.ProductDetails.fields.StockKeepingUnit;
                        const availableQuantity = this.getAvailableQuantity(sku);
                        //console.log("availableQuantity" + availableQuantity);
                        item.availableQuantity = availableQuantity;
                        item.quantity = (item.quantity > item.availableQuantity) ? item.availableQuantity : item.quantity;
                        item.showAsPrice = false;
                        item.showAsLabels = false;
                        return item;
                    });

                    this._cartItems = updatedCartItems;
                    this.getPriceAndQuantity();
                    this.template.querySelector('c-bwc_product-ship-type').filterCartItems(this._cartItems);
                    await this.installationFeeServices();
                    this.publishMessage();
                    // console.log("UpdatedCartItems@@@" + JSON.stringify(this._cartItems));
                })

                .catch(error => {
                    this.skewError = error;
                    console.log('skewError', error);
                });
        }
    }

    //sends sdsflag value to zipCode component
    publishZipCode() {
        const zipCodeInfo =
        {
            zip: this.zipCode,
            productFlag: this.pickupListflag,
            hdList: this._hdList,
            pickupList: this._pickupList
        }

        publish(this.messageContext, bwc_cartZipCode, zipCodeInfo);
        //console.log("zipCodeInfo from Cart" + JSON.stringify(zipCodeInfo));

    }

    @wire(MessageContext)
    messageContext;

    //Sent to cartSummary component
    publishMessage() {
        let messagePayload = {
            source: "LWC",
            myObjectField: {
                total: this._cartTotal,
                cartQuantity:this._totalQuantity,
                cartFlag:this.cartflag,
                addPromotions: this.addPromotions,
                isUserMember: this.isMember,
                delivery: (this._sdsList.length > 0 || this._hdList.length > 0) ? (this._deliveryFee).toFixed(2) : 0,
                installation: (this._installationFee).toFixed(2),
                memberInstallation: (this.memberInstallationFee).toFixed(2),
                protectionPlanFee: (this.protectionPlanFee).toFixed(2),
                memberProtectionPlanFee: (this.memberProtectionPlanFee).toFixed(2),
                //memberProtectionPlanFee:(this.protectionPlanFee- (ProtectionPlanDiscount * this.protectionPlanFee)).toFixed(2),
                partsShipOptions: this._partsList.length > 0 ? this.partsShipOptions : [],
                hdList: this._hdList,
                sdsList: this._sdsList,
                partsList: this._partsList,
                fedexList: this._prodShippingList,
                pickupList: this._pickupList,
                membership: this._memberList,
                cartItems: this._cartItems,
                promotions: this._savedAmt
            }
        };

        this.context = createMessageContext();
        publish(this.context, bwcCartPage, messagePayload);
        console.log("myObjectField" + JSON.stringify(messagePayload.myObjectField));
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

    //this Navigation goes back to Home Page from Cart    
    get homeUrl() {
        return basePath;
    }

    async handleMemProductSavings() {
        if (this.productIds2.length === 0 || this.quantities.length === 0) {
            //console.log('productIds or quantities is empty.');
            this.memberProdSavings = 0;
            return;
        }
        await fetchPrices({ productIds: this.productIds2, quantities: this.quantities })
            .then(result => {
                if(result.totalDifference!=undefined && result.totalDifference > 0)
                {
                this.memberProdSavings = result.totalDifference;
                }
                else{
                    this.memberProdSavings = 0;
                }
                console.log('##Product Savings from apex' + JSON.stringify(result));
            })
            .catch(error => {
                console.log('## Erro Product Savings from apex' + JSON.stringify(error));
            })
    }

    async installationFeeServices() {
        try {
            const result = await bwc_getRelatedCartItemAll({ itemId: this._cartId, isMember: this.isMember, zipCode: this.zipCode });
            console.log('data Total Install====', JSON.stringify(result));
            this._installationFee = result.totalFee;
            this.memberInstallationFee=result.installationFeeForMember;
            this.protectionPlanFee = result.protectionPlanTotal;
            this.memberProtectionPlanFee =result.protectionPlanForMember;
            // console.log("@@@_installationFee", this._installationFee);
            // console.log("@@@memberInstallationFee", this.memberInstallationFee);
            // console.log("@@@protectionPlanFee", this.protectionPlanFee);
            await this.handleMemberSavings2();
            this.publishMessage();
        } catch (error) {
            console.log('error===', JSON.stringify(error));
            throw error;
        }
    }

    handleMemberSavings2() {
        if (this._totalQuantity > 0) {
            if (this._sdsList.length === 0 && this._hdList.length === 0) {
                this._memberSavings = 0;
                this._memberSavings = this.memberProdSavings + (ProtectionPlanDiscount * this.protectionPlanFee) + (this._installationFee - this.memberInstallationFee);
            } else if (this._sdsList.length > 0 || this._hdList.length > 0) {
                this._memberSavings = 0;
                this._memberSavings = this.memberProdSavings + (ProtectionPlanDiscount * this.protectionPlanFee) + (this._installationFee - this.memberInstallationFee) + parseFloat(this._deliveryFee);
                console.log("handleMemberSavings2 with delivery", this._memberSavings);
            }
        } else {
            this._memberSavings = 0;
        }

        console.log("handleMemberSavings2 individual", this._installationFee, this.memberInstallationFee, this.protectionPlanFee, this.memberProdSavings, this._deliveryFee);
        this.fixedMemberSavings = this._memberSavings.toFixed(2);
        console.log("@@@fixedMemberSavings", this.fixedMemberSavings);
        this.publishMemberSavings(this.fixedMemberSavings);
    }
  
    publishMemberSavings(value) {
        const savings = { savings: value }
        publish(this.messageContext, bwc_membershipSavings, savings);
        console.log("@@@fixedMemberSavings Publish", JSON.stringify(savings));
    } 

    @wire(getBuyerGroup, { acctId: '$_accountId' })
    buyerGroups({ data, error }) {

        if (data) {
            //console.log("buyerGroups data" + JSON.stringify(data));
            //console.log("buyerGroups acctId" + this._accountId);
            console.log("BuyerGroup from customlabel" + BuyerGroup);
            //considering user belongs to only one buyer group at a time
            if (data[0].BuyerGroup != undefined && data[0].BuyerGroup.Name != undefined && BuyerGroup != undefined) {
                if (data[0].BuyerGroup.Name === BuyerGroup) {
                    this.isMember = true;
                    this.labelMSRP = 'MSRP'
                    this.labelDiscount = 'Member Discount';
                    this.labelPrice = 'Member Price';
                }
                else {
                    this.isMember = false;
                    this.labelMSRP = 'MSRP'
                    this.labelPrice = 'Promotional Price';
                }
            }
        }
        else if (error) {
            console.log('buyerGroups error ' + JSON.stringify(error));
        }
    }

    getPriceAndQuantity() {
        this._totalQuantity = 0;
        this._cartTotal = 0.0;
        this._cartTotalWithoutDiscount = 0.0;
        this._cartTotalWithDiscount = 0.0;
        this._savedAmt = 0.0;
        this._memberList = [];
       
        if (this._cartItems) {
            for (let i = 0; i < this._cartItems.length; i++) {
                if (this._cartItems[i].ProductDetails.fields.StockKeepingUnit == MEMBER_SKU) {
                    console.log("Found Membership SKU");                     
                    this._memberList.push(this._cartItems[i]);
                }

                if (this._sdsList.length > 0 || this._hdList.length > 0 || this._partsList.length > 0 || this._memberList.length > 0 || this._prodShippingList.length > 0 || this._pickupList.length > 0) {
                    this.cartflag = true;
                    const combinedLists = [
                        this._sdsList,
                        this._hdList,
                        this._partsList,
                        this._memberList,
                        this._prodShippingList,
                        this._pickupList,
                    ];
                    // console.log("@@this._hdList", JSON.stringify(this._hdList));
                    //  console.log("@@combinedLists", JSON.stringify(combinedLists));

                    this._totalQuantity = combinedLists.flat().reduce(
                        (totalQuantity, item) => totalQuantity + parseInt(item.quantity),
                        0
                    );
                    console.log("@@ this._totalQuantity", this._totalQuantity);

                    this._savedAmt = combinedLists
                        .flat()
                        .reduce((savedAmt, item) => savedAmt + parseFloat(item.adjustmentAmount), 0);

                    this._cartTotal = combinedLists
                        .flat()
                        .reduce((cartTotal, item) => {
                            /*if (item.MSRP === item.price) {
                                cartTotal += parseFloat(item.MSRP);
                                console.log("CT1", cartTotal);
                            } else if (this.isMember === true) {
                                if (item.memberPrice === 0) {
                                    cartTotal += parseFloat(item.MSRP);
                                    console.log("CT2 MP 0", cartTotal);
                                } else {
                                    cartTotal += parseFloat(item.memberPrice);
                                    console.log("CT2", cartTotal);
                                }
                            } else {
                                if (item.promotionalSavings === 0) {
                                    cartTotal += parseFloat(item.MSRP);
                                    console.log("CT3 PS 0", cartTotal);
                                } else {
                                    cartTotal += parseFloat(item.decimalPrice);
                                    console.log("CT3", cartTotal);
                                }
                            }*/
                            if (item.decimalPrice === 0 && this.isMember === false) {
                                cartTotal += parseFloat(item.MSRP);
                                console.log("CT when DP=0", cartTotal);
                            } else if (this.isMember === true) {
                                cartTotal += parseFloat(item.memberPrice);
                                console.log("CT when member", cartTotal);
                            } else {
                                cartTotal += parseFloat(item.decimalPrice);
                                console.log("CT for non member/guest", cartTotal);
                            }

                            return cartTotal;
                        }, 0);

                    console.log("Final CT", this._cartTotal);

                }
                else
                    this.cartflag = false;
            }
           // console.log("@@cartflag", this.cartflag);
            if (this._savedAmt !== 0 && this._savedAmt !== null) {
                this.addPromotions = true;
            }
            else {
                this.addPromotions = false;
            }

            this._fixedTotal = this._cartTotal.toFixed(2);
            // console.log("fixedTotalinCart" + this._fixedTotal);

            if (this._memberList) {
                if (this._memberList.length > 0) {
                    this._memberSKU = true;
                } else this._memberSKU = false;
            }
        }

    }


    //Categorisation of products from child bwc_productShipType
    async filterCartItems(event) {
        // console.log(' shubh vent.detail.cartItems;======' + event.detail.cartItems);
        this._cartItems = event.detail.cartItems;

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
        await this.handleMemProductSavings();
        await this.installationFeeServices();
        this.publishMessage();
        this.publishZipCode();
        this.loading = false;

        return false;
    }

//Used to fetch Delivery & Shipping Options are taken from metadata
    @wire(getShipTypeFee)
    wiredRecs({ data, error }) {

        if (data) {
            let shipOptions = [];
            console.log('ship resp ' + JSON.stringify(data));
            for (let i = 0; i < data.length; i++) {
                if (data[i].DeveloperName == 'HOME_DELIVERY') {
                    this._deliveryFee = parseFloat(data[i].Price__c);
                    //console.log("this._deliveryFee cart", this._deliveryFee);
                }

                else if (data[i].DeveloperName == 'SMALL_PACKAGE_DELIVERY') {
                    this.smallPackageFee = data[i].Price__c;
                } else if (data[i].Type__c == 'PARTS SHIPPING') {
                    let labelval = data[i].MasterLabel + '$' + data[i].Price__c;
                    let shipRecord = { label: labelval, value: data[i].Product_SKU__c, additionalParam: data[i].Price__c };
                    shipOptions.push(shipRecord);
                }

            }
            this.partsShipOptions = shipOptions;
            console.log('##SHIPPING OPTIONS ' + JSON.stringify(this.partsShipOptions));

        } else if (error) {
            console.log('error ' + error);
        }
    }

    //Handler to update UI when quantity of a products changes
    async handleValueChange(event) {
        const { value, cartItemId } = event.detail;
        await updateItemInCart(cartItemId, value);
        await new Promise((resolve) => setTimeout(resolve, 2000));
        this.getPriceAndQuantity();
        await this.handleMemProductSavings();     
        this.template.querySelector('c-bwc_product-ship-type').filterCartItems(this._cartItems);
        this.publishMessage();

    }

    async installationChangeCapture() {
        await this.installationFeeServices();
    }
  
    toggleItems() {
        this.openFlag = !this.openFlag;
        this.showItems = !this.showItems;
        if (this.openFlag) {
            this.handleOpen();
        }
    }

    handleCouponCodeChange(event) {
        this.couponCode = event.target.value;
        console.log("##couponCode handleCouponChange", this.couponCode);
    }

    async handleCouponApplied1() {
        //console.log("couponCode in cart" + this.couponCode);
        await applyCouponToCart(this.couponCode).then(async (isValidCoupon) => {
            //console.log("isValidCoupon" + JSON.stringify(isValidCoupon));
            this.couponId = isValidCoupon.cartCoupons.coupons[0].cartCouponId;
            //console.log(' this.couponId', this.couponId);
            await new Promise((resolve) => setTimeout(resolve, 2000));
            await this.getPriceAndQuantity();
            this.template.querySelector('c-bwc_product-ship-type').filterCartItems(this._cartItems);
            this.publishMessage();
            this.successMessage=`${this.couponCode}` + " Applied!";

        }).catch(error => {

            console.error("Error:", JSON.stringify(error));
            console.error("ErrorMessage:", JSON.stringify(error.message));
            if (error.error.code === 'ALREADY_APPLIED') {
                this.errorMessage="Coupon already applied";
            } else {
                this.errorMessage="We're sorry, that coupon is invalid.";              
            }
            this.loading=false;
        })
    }

    async deleteCoupon(){      
        this.successMessage=false;
        this.couponCode='';
        console.log("click on delete cartItems", this.successMessage, this.couponCode);
        await deleteCouponFromCart(this.couponId);        
        await new Promise((resolve) => setTimeout(resolve, 2000));
        await this.getPriceAndQuantity();
        this.template.querySelector('c-bwc_product-ship-type').filterCartItems(this._cartItems);
        this.publishMessage();

    }

    async clearCartItem(evt) {
        let cartItemId = evt.target.dataset.id;
        let cartItemClone = this._cartItems
        await deleteItemFromCart(cartItemId);

        console.log('PRODUCTIDMEMBER===', PRODUCTIDMEMBER);
        console.log('cartItemClone===', JSON.stringify(cartItemClone));
        var memberCartItemId;
        if (cartItemClone) {
            for (let i = 0; i < cartItemClone.length; i++) {
                if (cartItemClone[i].ProductDetails.productId == PRODUCTIDMEMBER) {
                    console.log("Found Membership SKU");
                    memberCartItemId = cartItemClone[i].id;
                }
            }
        }
        console.log("memberCartItemId called==" + memberCartItemId);

        if (cartItemId === memberCartItemId) {
            console.log("revertUserMembership called");
            this.revertUserMembership();

        }
        else {
            await new Promise((resolve) => setTimeout(resolve, 2000));
            // console.log("Call other methods on delete to update UI");
            this.getPriceAndQuantity();
            await this.handleMemProductSavings();
            await this.installationFeeServices();
            this.template.querySelector('c-bwc_product-ship-type').filterCartItems(this._cartItems);    
            this.publishMessage();      
        }

        if (this._totalQuantity == 0) {
            this.cartflag = false;
        }

    }


    revertUserMembership() {
        console.log('revert membership===' + this._accountId);
        revertMembership({ accId: this._accountId })
            .then(result => {
                console.log("revert membership===" + JSON.stringify(result));
                location.reload();
            })
            .catch(error => {
                console.log("revert membership===error==" + JSON.stringify(error));
            })
    }


//3/3/24
    //subscribes Promotion component on click of apply
    subscribeToCouponApplied() {
        if (this.subscription3) {
            return;
        }
        this.subscription3 = subscribe(
            this.messageContext,
            bwc_CouponApplied,
            (couponCode) => {
                //  console.log("Message from Coupon Subscriber" + JSON.stringify(couponCode.message));
                this.handleCouponApplied(couponCode.message);
            });
    }

    async handleCouponApplied(couponCodeReceived) {
        const couponCode = couponCodeReceived;
        console.log("couponCode in cart" + couponCode);
        await applyCouponToCart(couponCode).then(async (isValidCoupon) => {
            console.log("isValidCoupon" + JSON.stringify(isValidCoupon));
            this.couponId = isValidCoupon.cartCoupons.coupons[0].cartCouponId;
            console.log(' this.couponId', this.couponId);
            await new Promise((resolve) => setTimeout(resolve, 2000));
            await this.getPriceAndQuantity();
            // console.log("getPriceAndQuantity called");
            this.template.querySelector('c-bwc_product-ship-type').filterCartItems(this._cartItems);
            // console.log("filterCartItems called");
            //this.installationFeeServices();
            this.publishMessage();
            // console.log("publishMessage called");
            this.publishSuccess("Coupon code has been applied");
            // console.log("publishSuccess called");

        }).catch(error => {

            console.error("Error:", JSON.stringify(error));
            console.error("ErrorMessage:", JSON.stringify(error.message));
            if (error.error.code === 'ALREADY_APPLIED') {
                this.publishError("Coupon already applied");
            } else {
                this.publishError("Invalid coupon code. Please try again.");

            }
            this.loading=false;
        })
    }

    publishSuccess(appliedMsg) {
        const successMsg = { smsg: appliedMsg, emsg: '', cartCouponId: this.couponId }
        publish(this.messageContext, bwc_CouponError, successMsg);
    }

    publishError(errorMessage) {
        const errMsg = { emsg: errorMessage, smsg: '', cartCouponId: this.couponId };
        publish(this.messageContext, bwc_CouponError, errMsg);
    } 

















        /* 1/23
        bwc_getRelatedCartItemAll({ itemId: this._cartId, isMember: this.isMember, zipCode: this.zipCode })
         .then(result => {

             console.log('data Total Install====' + JSON.stringify(result));
             this._installationFee = result.totalFee;
             this.memberInstallationFee = result.memberTotalFee;
             this.protectionPlanFee = result.protectionPlanTotal;
             console.log("@@@_installationFee", this._installationFee);
             console.log("@@@memberInstallationFee", this.memberInstallationFee);
             console.log("@@@protectionPlanFee", this.protectionPlanFee);
           //  this.handleMemberSavings();
             this.publishMessage();
         })
         .catch(error => {
             console.log('error===' + JSON.stringify(error))
         })


 } */
/*
    async handleProtectionPlanUpdate(event, quantityChanged = false) {
        const openModal = event ? event.openModal : false;
        console.log("Event Handled", JSON.stringify(event), quantityChanged);
        console.log("@@@memberSavings in handleProtectionPlanUpdate", this.memberProdSavings, ProtectionPlanDiscount, this.protectionPlanFee);
        if (quantityChanged || openModal) {
            this.memberProdSavings -= (ProtectionPlanDiscount * this.protectionPlanFee);
            console.log("@@@memberSavings in handleProtectionPlanUpdate after sub", this.memberProdSavings);
        }
        await this.installationFeeServices();
        console.log("@@@memberSavings in handleProtectionPlanUpdate after call", this.memberProdSavings, ProtectionPlanDiscount, this.protectionPlanFee);

        if (this.protectionPlanFee > 0) {
            this.memberProdSavings += (ProtectionPlanDiscount * this.protectionPlanFee);
            console.log("@@@memberSavings in handleProtectionPlanUpdate after call in handleProtectionPlanUpdate", this.memberProdSavings, ProtectionPlanDiscount, this.protectionPlanFee);

        }

        this.fixedMemberSavings = this.memberProdSavings.toFixed(2);
        console.log("@@@fixedMemberSavings after PP updated", this.fixedMemberSavings);
        this.publishMemberSavings(this.fixedMemberSavings);

        // await this.handleMemberSavings();
    }



    async handleMemberSavings() {
        console.log("this._memberSavings bef install", this.memberProdSavings);

        if (this._installationFee > 0) {
            if (this._installationFee > this.memberInstallationFee)
                this.memberProdSavings += (this._installationFee - this.memberInstallationFee);
            console.log("this._installationFee,this.memberInstallationFee,this.memberProdSavings", this._installationFee, this.memberInstallationFee, this.memberProdSavings);
        }
        if (this._sdsList.length > 0 || this._hdList.length > 0)
            this.memberProdSavings += (this._deliveryFee);

        if (this.protectionPlanFee > 0) {
            // console.log("@@@protectionPlanFee & savings handleMemSavings", this.protectionPlanFee, this._memberSavings);
            this.memberProdSavings += (ProtectionPlanDiscount * this.protectionPlanFee);

            //console.log("@@@_memberSavings else", this._memberSavings);
        }
        this.fixedMemberSavings = this.memberProdSavings.toFixed(2);
        console.log("@@@fixedMemberSavings", this.fixedMemberSavings);
        await this.publishMemberSavings(this.fixedMemberSavings);
    }

    publishMemberSavings(value) {
        const savings = { savings: value }
        publish(this.messageContext, bwc_membershipSavings, savings);
        // console.log("@@@fixedMemberSavings Publish", JSON.stringify(savings));

    }  */

    /*async clearCartItem(evt) {
        let cartItemId = evt.target.dataset.id;
        await deleteItemFromCart(cartItemId);
        await new Promise((resolve) => setTimeout(resolve, 2000));
        this.getPriceAndQuantity();
        console.log("getPriceAndQuantity called from delete");
 
        this.template.querySelector('c-bwc_product-ship-type').filterCartItems(this._cartItems);
        console.log("filterCartItems called from delete");
        refreshApex(this.cartItemsAllResult);
        location.reload();
        this.publishMessage();
        console.log("publishMessage called from delete");
 
        // console.log("cartItemId"+cartItemId);
        // if(cartItemId!==undefined){
          
        //     console.log('refreshApex called');
        // }
        // else
        // {
        //     this._installationFee=0;
        // }
        // console.log("this._installationFee"+this._installationFee);
        // setTimeout(() => {
        
        
        // },2000);
 
    } */

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