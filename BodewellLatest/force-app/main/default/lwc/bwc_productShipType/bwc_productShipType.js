import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import getZipcodeServiceInfo from '@salesforce/apex/BWC_CartController.getZipcodeServiceInfo';
import getZipcodeServiceInfo2 from '@salesforce/apex/BWC_CartController.getZipcodeServiceInfo2';
//import getMemberDiscounts from '@salesforce/apex/BWC_CartController.getMemberDiscounts';
import fetchPrices from '@salesforce/apex/BWC_CartController.fetchPrices';
import getAvailableDeliveryDates from '@salesforce/apex/BWC_CartController.getDeliveryDates';
import LeadSource from '@salesforce/schema/Contact.LeadSource';
import { refreshApex } from '@salesforce/apex';
import LightningAlert from "lightning/alert";
import MEMBER_SKU from '@salesforce/label/c.BWC_BodewellMemberSKU';
import MEMBER_DISCOUNT from '@salesforce/label/c.BWC_MemberDiscount';
import zipCodeChannel from '@salesforce/messageChannel/zipCodeChange__c';
import { subscribe, MessageContext } from 'lightning/messageService';
//import { publish, subscribe, MessageContext, createMessageContext } from "lightning/messageService";
export default class Bwc_productShipType extends LightningElement {

    subscription = null;

    @wire(MessageContext)
    messageContext;

    @api accountId;
    @api cartItems;
    @api zipCode;
    @track _zipCodeServiceResp;
    hdList = [];
    prodShippingList = [];
    partsList = [];
    sdsList = [];
    pickupList = [];
    pickupLocation = {};
    _cartDeliveryTypes = {};
    _deliveryTypeData = {};
    _productRecords = {};
    hdListflag = false;
    partsListflag = false;
    prodShippingListflag = false;
    pickupListflag = false;
    sdsListFlag = false;

    connectedCallback() {
        this.handleSubscribe();
    }



    handleSubscribe() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(this.messageContext, zipCodeChannel, (message) => {
            console.log('date------' + message.message);

            const fullAddress = message.message;
            this.zipCode = fullAddress.Zipcode;


        });
    }

    //context = createMessageContext();

    /*@wire(getZipcodeServiceInfo, { accountId: '$accountId' })
    wiredZipResponse({ error, data }) {
        if (data) {
            console.log('<--zicpdoe API Response is -->  ' + data);
            console.log('-- Zipcode is --' + this.zipCode);
            this._zipCodeServiceResp = JSON.parse(data);
            this.filterCartItems();
        }

    }*/

    //item quantity updates,
    /* getAgentResponse(cartItems) {
        getZipcodeServiceInfo2({ zipCode: this.zipCode })
            .then(data => {
                if (data) {

                    if ((JSON.parse(data)).agents !== undefined && (JSON.parse(data)).agents !== null) {
                        console.log('1 zicpdoe API Response is -->  ' + data);
                        console.log('2 Zipcode from actual component is --' + this.zipCode);
                        this._zipCodeServiceResp = JSON.parse(data);
                        this.getFilterItems(cartItems)
                    }
                
                    else {
                        if ((JSON.parse(data)).agents === undefined || (JSON.parse(data)).agents === null) {

                            console.log("AGENT API response is null/product fields have been modified");
                            const toastEvent = new ShowToastEvent({
                                title: 'Error',
                                message: 'An error occurred. Please try again.',
                                variant: 'error'
                            });
                            this.dispatchEvent(toastEvent);
                        }
                    }
                }   
            })
            .catch(error => {
                console.log('error ' + error);

            })
    } */

    /*
    partsDis=0.0;
    fgDis=0.0;
    accessoryDis=0.0;

    @wire(getMemberDiscounts)
    memDiscounts({ data, error }) {
        if (data) {
           console.log('memDiscounts ' + JSON.stringify(data));
            for (let i = 0; i < data.length; i++) {
                if (data[i].DeveloperName == 'Parts_Discount') {
                    this.partsDis = parseFloat(data[i].Discount_Percentage__c);
                } else if(data[i].DeveloperName == 'FG_Discount') {
                    this.fgDis = parseFloat(data[i].Discount_Percentage__c);
                } else if(data[i].DeveloperName == 'Accessory_Discount') {
                    this.accessoryDis = parseFloat(data[i].Discount_Percentage__c);
                }
            }
        }
     else if (error) {
        console.log('error memDiscounts ' + error);
    }

    } */
    //works when cart page is loaded, home,plp,checkout when child component is loaded for the first time from html/ zip code changed
    @track agentResult;
    @wire(getZipcodeServiceInfo2, { zipCode: '$zipCode' })
    wiredZipResponse(result) {
        if (result) {
            console.log("Result", result);
            this.agentResult = result;
            if (result.data) {

                if ((JSON.parse(result.data)).agents !== undefined && (JSON.parse(result.data)).agents !== null) {
                    console.log(' API Response from ProdShipType -->  ' + result.data);
                    console.log(' Zipcode from actual component/from ProdShipType --' + this.zipCode);
                    this._zipCodeServiceResp = JSON.parse(result.data);
                    if (this.cartItems != null && this.cartItems != undefined) {
                        //console.log(' Shubh 1 Ifff');
                        //this.getFilterItems(this.cartItems);
                        this.filterCartItems(this.cartItems);
                    }
                }

                else {

                    if ((JSON.parse(result.data)).agents === undefined || (JSON.parse(result.data)).agents === null || (JSON.parse(result.data)).agents.length === 0) {

                        // console.log("AGENT API response is null/product fields have been modified");
                        LightningAlert.open({
                            message: "Server Down. Please try again after some time.",
                            theme: "error",
                            label: ""
                        });
                    }
                }
            }
        }
        if (result.error) {
            LightningAlert.open({
                message: "An error occurred. Please try again after some time.",
                theme: "error",
                label: ""
            });
        }






    }
    @track memberValues;
    @track productIds;
    @track productIds2 = [];
    @track quantities = [];
    async handleMemProductSavings() {
        this.productIds = this.cartItems.map(cartItem => cartItem.ProductDetails.productId);
        console.log("Product Ids productShipType", JSON.stringify(this.productIds));
        this.productIds2 = [];
        this.quantities = [];

        this.cartItems.forEach(cartItem => {
            this.productIds2.push(cartItem.ProductDetails.productId);
            this.quantities.push(cartItem.quantity);
            console.log("Product Ids.quantities productShipType", JSON.stringify(this.productIds2), JSON.stringify(this.quantities));

            console.log("Product Ids and Quantities productShipType");
            for (let i = 0; i < this.productIds2.length; i++) {
                console.log("productShipType Product Id:", this.productIds2[i], ", Quantity:", this.quantities[i]);
            }
        });

        if (this.productIds2.length === 0 || this.quantities.length === 0) {
            console.log('productIds or quantities is empty productShipType.');
            return;
        }
        await fetchPrices({ productIds: this.productIds2, quantities: this.quantities })
            .then(result => {
                this.memberValues = result;
                console.log("memberValues", JSON.stringify(this.memberValues));
                this._memberSavings = result.totalDifference;
                console.log('##Product Savings from apex productShipType' + JSON.stringify(result));
            })
            .catch(error => {
                console.log('## Erro Product Savings from apex productShipType' + JSON.stringify(error));
            })
    }

    @api
    async filterCartItems(cartItems) {
        //     this.getAgentResponse(cartItems);
        // }

        // getFilterItems(cartItems) {
        await this.handleMemProductSavings();
        let updatedCartPromoItems = JSON.parse(JSON.stringify(cartItems));
        /*updatedCartPromoItems = updatedCartPromoItems.map((item) => {
            console.log("Item##" + JSON.stringify(item));
            let productId = item.ProductDetails.productId;
            console.log("productId",productId);

            if (item.quantity > item.availableQuantity) {
                item.quantity = item.availableQuantity;
            }
            item.price = item.salesPrice * item.quantity;

            console.log(" item.quantity", item.quantity, item.price);
            if (item.ProductDetails.fields.MSRP__c !== undefined && item.quantity !== undefined && item.price !== undefined) {
                let MSRP = item.ProductDetails.fields.MSRP__c * item.quantity;
                // item.MSRP=MSRP;
                item.MSRP = !MSRP ? MSRP : MSRP.toFixed(2);
                console.log("MSRP@@", item.MSRP);
                if (item !== undefined && item.MSRP > 0 && item.MSRP > (item.price).toFixed(2) && item.MSRP !== (item.price).toFixed(2)) {
                    console.log("MSRP > 0 @@" + item.MSRP, item.price);
                    item.promotionalSavings = (item.MSRP - item.price).toFixed(2);
                    item.decimalPrice = (item.price).toFixed(2); //actual price of product from pricebook, not used for member
                    console.log("promotionalSavings@@" + item.promotionalSavings, item.MSRP, item.price);
                    console.log("MEMBER_DISCOUNT",MEMBER_DISCOUNT);
                   // item.memberDiscount = (MEMBER_DISCOUNT * item.MSRP).toFixed(2);
                    // item.memberDiscount = (MEMBER_DISCOUNT * item.price).toFixed(2);
                    // item.memberPrice = (item.MSRP - item.promotionalSavings - item.memberDiscount).toFixed(2);

                     //X=0.10X + 500; X(1-0.10)=500; X=500/(1-0.10)
                     item.actualPrice=(item.price/(1-MEMBER_DISCOUNT)).toFixed(2);//Price prior to discount applied on member Price book
                    // item.memberPromotionalSavings = (item.MSRP - item.actualPrice).toFixed(2);
                     //need to update customlabel as per product type
                    // item.memberDiscount =(MEMBER_DISCOUNT * item.actualPrice).toFixed(2);
                     //item.memberPrice = (item.MSRP - item.memberDiscount).toFixed(2);
                     item.memberPrice= (item.price).toFixed(2); // listPrice from Member Price Book
                     console.log("@@item.actualPrice, item.memberPromotionalSavings",item.actualPrice, item.memberPromotionalSavings);
                     if(this.memberValues){
                        if (this.memberValues.memberDiscount[productId]) {
                            item.memberDiscount = (this.memberValues.memberDiscount[productId]).toFixed(2);
                            console.log("item.memberDiscount", item.memberDiscount);
                        }
                        if (this.memberValues.promotionalSavings[productId]) {
                            item.memberPromotionalSavings = (this.memberValues.promotionalSavings[productId]).toFixed(2);
                            console.log("item.memberPromotionalSavings", item.memberPromotionalSavings);
                        }
                    }

                    item.showAsPrice = false;
                    item.showAsLabels = true;
                    //console.log("showAsPrice" + item.showAsPrice);
                    console.log("showAsPrice" + item.showAsLabels);                    
                    item.memberSavings= (item.MSRP - item.memberPrice);
                    console.log("@@@ memberSavings" , item.memberSavings, item.ProductDetails.fields.StockKeepingUnit);
                } 
                
                else {
                    if (item !== undefined && (item.MSRP === null || item.MSRP === 0 || item.MSRP === (item.price).toFixed(2) || item.MSRP < (item.price).toFixed(2))) {
                        console.log("MSRP = 0/null/price @@" + item.MSRP, item.price);
                        //item.MSRP=item.price;
                        item.MSRP = (item.price).toFixed(2);
                        item.promotionalSavings = 0;
                        // item.memberPrice = 0;
                        //fetch correct % from metadata
                       // item.memberDiscount = (MEMBER_DISCOUNT * item.MSRP).toFixed(2);
                       //X=0.10X + 500; X(1-0.10)=500; X=500/(1-0.10)
                        item.actualPrice=(item.price/(1-MEMBER_DISCOUNT)).toFixed(2);
                       // item.memberDiscount =(MEMBER_DISCOUNT * item.actualPrice).toFixed(2);
                       if(this.memberValues){
                        if (this.memberValues.memberDiscount[productId]) {
                            item.memberDiscount = this.memberValues.memberDiscount[productId];
                            console.log("item.memberDiscount", item.memberDiscount);
                        }
                        // if (this.memberValues.promotionalSavings[productId]) {
                        //     item.promotionalSavings = this.memberValues.promotionalSavings[productId];
                        //     console.log("item.promotionalSavings", item.promotionalSavings);
                        // }
                    }
                        //item.memberPrice = (item.MSRP - item.memberDiscount).toFixed(2);
                        item.memberPrice= item.MSRP; // listPrice from Member Price Book
                        console.log("@@item.actualPrice, item.memberPrice,",item.actualPrice, item.memberPrice);
                        item.showAsPrice = true;
                        item.showAsLabels = false;
                        console.log("showAsPrice" + item.showAsPrice);
                        item.memberSavings= (item.actualPrice - item.memberPrice);
                        console.log("@@@ memberSavings without PMAP" , item.memberSavings, item.ProductDetails.fields.StockKeepingUnit);
                       

                    }
                }

                // this.memberSavings+= (item.MSRP - item.memberPrice);
                // console.log("@@@ memberSavings" , this.memberSavings, item.ProductDetails.fields.StockKeepingUnit);

                return item;
            }

        }); */

        updatedCartPromoItems = updatedCartPromoItems.map((item) => {
            // console.log("Item##" + JSON.stringify(item));
            let productId = item.ProductDetails.productId;
            console.log("productId", productId);

            if (item.quantity > item.availableQuantity) {
                item.quantity = item.availableQuantity;
            }
            item.price = item.salesPrice * item.quantity;
            console.log(" item.quantity,item.price", item.quantity, item.price);

            if (item.ProductDetails.fields.MSRP__c !== undefined && item.quantity !== undefined && item.price !== undefined) {
                let MSRP = item.ProductDetails.fields.MSRP__c * item.quantity;
                console.log("item.price", item.price);
                if (item.ProductDetails.fields.MSRP__c == 0 || item.ProductDetails.fields.MSRP__c == null || item.ProductDetails.fields.MSRP__c < 0) {
                    // item.MSRP=(item.price).toFixed(2); 
                    // console.log("MSRP when Product MSRP is null", item.MSRP);                    
                    if (this.memberValues !== undefined && item !== undefined && productId != undefined) {
                        if (this.memberValues.basePriceBookListPrice[productId]) {
                            if (item.ProductDetails.fields.MSRP__c < this.memberValues.basePriceBookListPrice[productId]) {
                                item.MSRP = this.memberValues.basePriceBookListPrice[productId].toFixed(2);
                                console.log("MSRP when Product MSRP < base", this.memberValues.basePriceBookListPrice[productId].toFixed(2));

                                //item.memberPrice= this.memberValues.memberPriceBookListPrice[productId].toFixed(2);
                            } else {
                                item.MSRP = this.memberValues.basePriceBookListPrice[productId].toFixed(2);
                                console.log("MSRP when Product MSRP is null bpb", this.memberValues.basePriceBookListPrice[productId].toFixed(2));
                            }
                        }
                    }
                }
                else {
                    item.MSRP = !MSRP ? MSRP : MSRP.toFixed(2);
                }
                console.log("MSRP@@", item.MSRP);

                //item.memberPrice= (item.price).toFixed(2);    
                
                if (this.memberValues !== undefined && item !== undefined && productId != undefined) {
                    if (this.memberValues.promotionalSavings[productId] != 0 && this.memberValues.promotionalSavings[productId] > 0) {
                        if (this.memberValues.memberDiscount[productId]!=undefined) {
                            item.memberDiscount = (this.memberValues.memberDiscount[productId]).toFixed(2);
                            if (item.memberDiscount > 0) {
                                item.noMemDiscFlag = false;
                            }
                            else
                                item.noMemDiscFlag = true;                           
                            console.log("item.memberDiscount", item.memberDiscount, item.noMemDiscFlag);
                        }
                        if (this.memberValues.promotionalSavings[productId]) {
                            item.promotionalSavings = (this.memberValues.promotionalSavings[productId]).toFixed(2);
                            console.log("item.memberPromotionalSavings", item.promotionalSavings);
                        }

                        item.decimalPrice = (item.price).toFixed(2);
                        item.showAsPrice = false;
                        item.showAsLabels = true;
                        console.log("item.decimalPrice", item.decimalPrice, item.showAsLabels, item.showAsPrice,item.noMemDiscFlag);

                    } else
                        if (this.memberValues.promotionalSavings[productId] == 0 || this.memberValues.promotionalSavings[productId] < 0) {
                            console.log("PromotionalSavings 0");
                            //Price label will be shown as item.MSRP
                           item.decimalPrice = 0;
                            item.showAsPrice = true;
                            item.showAsLabels = false;
                            if (this.memberValues.memberDiscount[productId] != undefined && this.memberValues.memberDiscount[productId] > 0) {
                                if (this.memberValues.memberDiscount[productId]) {
                                    item.memberDiscount = (this.memberValues.memberDiscount[productId]).toFixed(2);
                                    if (item.memberDiscount > 0) {                                        
                                        item.noMemDiscFlag = false;
                                    }
                                    else {
                                        item.noMemDiscFlag = true;                                        
                                    }
                                    console.log("item.memberDiscount inside", item.memberDiscount, item.showAsPrice, item.showAsLabels, item.noMemDiscFlag);
                                }
                            }
                            else {
                                item.memberDiscount = 0.00;
                                item.noMemDiscFlag = true;                               

                            }
                            console.log("item.memberDiscount outside", item.memberDiscount, item.showAsPrice, item.showAsLabels, item.noMemDiscFlag);

                        }

                        else {
                            item.MSRP = !MSRP ? MSRP : MSRP.toFixed(2);
                            item.decimalPrice = (item.price).toFixed(2);
                            item.promotionalSavings = 0.00;
                            item.memberDiscount = 0.00;
                            item.memberPrice = 0.00;
                            if (item.MSRP == item.decimalPrice) {
                                console.log("Promo Savings inside if");
                                item.showAsPrice = true;
                                item.showAsLabels = false;
                            }
                            else if (item.MSRP > item.decimalPrice) {
                                console.log("Promo Savings inside if else");
                                item.promotionalSavings = (item.MSRP - item.decimalPrice).toFixed(2);                             
                                item.showAsLabels = true;
                                item.showAsPrice = false;
                                console.log("Promo Savings inside if else DP", item.promotionalSavings, item.decimalPrice);
                            }
                            else {
                                console.log("Promo Savings inside else, MSRP undefine/-ve");
                                item.MSRP = item.decimalPrice;
                                item.showAsPrice = true;
                                item.showAsLabels = false;
                            }
                            console.log("Promo Savings & Member Discount is empty", item.decimalPrice, item.promotionalSavings, item.memberDiscount, item.memberPrice, item.MSRP, item.showAsLabels, item.showAsPrice);
                        }

                }

                if (this.memberValues !== undefined && item !== undefined && productId != undefined) {
                    //
                    if (this.memberValues.memberPriceBookListPriceMap !== undefined && this.memberValues.memberPriceBookListPriceMap[productId] !== undefined) {
                        item.memberPrice = this.memberValues.memberPriceBookListPriceMap[productId].toFixed(2);
                        if(item.isUserMember== true){
                        if (item.memberPrice > item.MSRP) {                            
                            item.MSRP = item.memberPrice;
                            item.showAsPrice = true;
                            item.showAsLabels = false;

                            if (item.memberDiscount > 0) {
                                item.noMemDiscFlag = false;                                
                            }
                            else {
                                   item.noMemDiscFlag = true;
                            }
                        }
                            console.log("item.memberPrice", item.memberPrice, item.memberDiscount, item.showAsPrice, item.showAsLabels, item.MSRP, item.noMemDiscFlag);
                        }
                        else{
                            item.MSRP = !MSRP ? MSRP : MSRP.toFixed(2);
                            item.showAsPrice = true;
                            item.showAsLabels = false;
                        }
                    } 
                //}
                else {
                        item.memberPrice = 0.00;
                        // if(Object.keys(this.memberValues.basePriceBookListPrice).length == 0){
                        // item.decimalPrice = 0.00;
                        // }
                        // else
                        item.decimalPrice=(item.price).toFixed(2);
                        console.log("Invalid memberId or productId for memberPriceBookListPriceMap", item.memberPrice, item.decimalPrice, item.MSRP);
                    }
                }
               

                return item;
            }


        });



        this.cartItems = updatedCartPromoItems;
        console.log("updatedCartPromoItems" + JSON.stringify(this.cartItems));



        if (cartItems)
            //  this.cartItems = cartItems;
            this.hdList = [];
        this.prodShippingList = [];
        this.partsList = [];
        this.sdsList = [];
        this.pickupList = [];
        this._cartDeliveryTypes = {};
        this._deliveryTypeData = {};
        this._productRecords = {};
        this.hdListflag = false;
        this.partsListflag = false;
        this.prodShippingListflag = false;
        this.pickupListflag = false;
        this.sdsListFlag = false;

        if (this.cartItems) {

            console.log('Number of Products ' + this.cartItems.length, JSON.stringify(this.cartItems));
            if ((this.cartItems).length == 1) {
                //if (this.cartItems[0].ProductDetails.fields.BWC_Delivery_Type__c != null && this.cartItems[0].ProductDetails.fields.BWC_Delivery_Type__c != '') {
                let productDeliveryType = this.cartItems[0].ProductDetails.fields.BWC_Delivery_Type__c; //).toLowerCase();
                if (productDeliveryType == 'sds' && this._zipCodeServiceResp.has_sds_delivery == true) {
                    this.sdsList.push(this.cartItems[0]);
                } else if (productDeliveryType == 'hd' && this._zipCodeServiceResp.has_home_delivery == true) {
                    this.hdList.push(this.cartItems[0]);
                } else if (productDeliveryType == 'sps' && this._zipCodeServiceResp.has_small_package == true) {
                    this.prodShippingList.push(this.cartItems[0]);
                } else if (productDeliveryType == 'sps fee' && this._zipCodeServiceResp.has_small_package == true) {
                    this.partsList.push(this.cartItems[0]);
                    //} else if (this._zipCodeServiceResp.has_will_call) {
                } else if (this._zipCodeServiceResp.has_will_call && (this.cartItems[0].ProductDetails.fields.StockKeepingUnit !== MEMBER_SKU)) {
                    this.pickupList.push(this.cartItems[0]);
                    for (let key in this._zipCodeServiceResp.agents) {
                        console.log('this._zipCodeServiceResp.agents==' + JSON.stringify(this._zipCodeServiceResp.agents[key]));

                        if (this._zipCodeServiceResp.agents[key].display_name == 'Will Call') {
                            console.log('this._zipCodeServiceResp.agents==' + JSON.stringify(this._zipCodeServiceResp.agents[key]));
                            this.pickupLocation = this._zipCodeServiceResp.agents[key];
                            console.log('this.pickupLocation.==' + JSON.stringify(this.pickupLocation));

                        }

                    }

                }
                //}

            } else if ((this.cartItems).length > 1) {
                console.log('CART with Multiple Items');
                let hdFirstItem = true;
                for (let i = 0; i < (this.cartItems).length; i++) {
                    console.log("this.cartItems[i]",this.cartItems[i]);
                    // if (this.cartItems[i].ProductDetails.fields.BWC_Delivery_Type__c != null && this.cartItems[i].ProductDetails.fields.BWC_Delivery_Type__c != '') {
                    this._cartDeliveryTypes[this.cartItems[i].id] = this.cartItems[i].ProductDetails.fields.BWC_Delivery_Type__c;
                    this._productRecords[this.cartItems[i].id] = this.cartItems[i].ProductDetails.fields;
                    let productDeliveryType = this.cartItems[i].ProductDetails.fields.BWC_Delivery_Type__c; //).toLowerCase();

                    if (productDeliveryType == 'sds') {
                        if ('sds' in this._deliveryTypeData) {
                            let sdsData = this._deliveryTypeData['sds'];
                            sdsData.push(this.cartItems[i].id);
                            this._deliveryTypeData['sds'] = sdsData;
                        } else {
                            this._deliveryTypeData['sds'] = [this.cartItems[i].id];
                        }

                    }
                    if (productDeliveryType == 'hd') {
                        if ('hd' in this._deliveryTypeData) {
                            let hdData = this._deliveryTypeData['hd'];
                            hdData.push(this.cartItems[i].id);
                            this._deliveryTypeData['hd'] = hdData;
                        } else {
                            this._deliveryTypeData['hd'] = [this.cartItems[i].id];
                        }
                    }
                    if (productDeliveryType == 'sps') {
                        if ('sps' in this._deliveryTypeData) {
                            let spsData = this._deliveryTypeData['sps'];
                            spsData.push(this.cartItems[i].id);
                            this._deliveryTypeData['sps'] = spsData;
                        } else {
                            this._deliveryTypeData['sps'] = [this.cartItems[i].id];
                        }
                    }
                    if (productDeliveryType == 'sps fee') {
                        if ('sps_fee' in this._deliveryTypeData) {
                            let spsFeeData = this._deliveryTypeData['sps_fee'];
                            spsFeeData.push(this.cartItems[i].id);
                            this._deliveryTypeData['sps_fee'] = spsFeeData;
                        } else {
                            this._deliveryTypeData['sps_fee'] = [this.cartItems[i].id];
                        }
                    }
                    //}
                }

                for (let i = 0; i < (this.cartItems).length; i++) {

                    let productDeliveryType = this.cartItems[i].ProductDetails.fields.BWC_Delivery_Type__c; //).toLowerCase();

                    console.log('Product Delivery Type is ' + productDeliveryType);
                    if (productDeliveryType == 'sds' && (this._deliveryTypeData['sds']).length >= 1) {
                        if (this._zipCodeServiceResp.has_sds_delivery)
                            this.sdsList.push(this.cartItems[i]);
                        else if (this._zipCodeServiceResp.has_will_call) {
                            this.pickupList.push(this.cartItems[i]);
                            for (let key in this._zipCodeServiceResp.agents) {
                                console.log('this._zipCodeServiceResp.agents==' + JSON.stringify(this._zipCodeServiceResp.agents[key]));

                                if (this._zipCodeServiceResp.agents[key].display_name == 'Will Call') {
                                    console.log('this._zipCodeServiceResp.agents==' + JSON.stringify(this._zipCodeServiceResp.agents[key]));
                                    this.pickupLocation = this._zipCodeServiceResp.agents[key];
                                    console.log('this.pickupLocation.==' + JSON.stringify(this.pickupLocation));

                                }

                            }
                        }
                    }
                    //commented below on 11/24
                    /*else if (productDeliveryType == 'hd' && ('sds' in this._deliveryTypeData) && (this._deliveryTypeData['sds']).length >= 1 && (this.cartItems[i].ProductDetails.fields.Is_Finished_Good__c == 'Yes' || this.cartItems[i].ProductDetails.fields.Is_Accessory__c == 'Yes')) {
                        if (this._zipCodeServiceResp.has_sds_delivery) {
                            this.sdsList.push(this.cartItems[i]);
                              //below 2 lines previously commented
                            //let hdTempRecords = this._deliveryTypeData['hd'];
                            //this._deliveryTypeData['hd'] = hdTempRecords.filter(item => item != this.cartItems[i].id);
                        }
                         else if (this._zipCodeServiceResp.has_will_call) {
                            this.pickupList.push(this.cartItems[i]);
                            for (let key in this._zipCodeServiceResp.agents) {
                                console.log('this._zipCodeServiceResp.agents==' + JSON.stringify(this._zipCodeServiceResp.agents[key]));

                                if (this._zipCodeServiceResp.agents[key].display_name == 'Will Call') {
                                    console.log('this._zipCodeServiceResp.agents==' + JSON.stringify(this._zipCodeServiceResp.agents[key]));
                                    this.pickupLocation = this._zipCodeServiceResp.agents[key];
                                    console.log('this.pickupLocation.==' + JSON.stringify(this.pickupLocation));

                                }

                            }
                        }
                    } */
                    else if (productDeliveryType == 'hd' && (this._deliveryTypeData['hd']).length >= 1) {
                        if (this._zipCodeServiceResp.has_home_delivery) {
                            this.hdList.push(this.cartItems[i]);
                            hdFirstItem = false;
                        } else if (this._zipCodeServiceResp.has_will_call) {
                            this.pickupList.push(this.cartItems[i]);

                            for (let key in this._zipCodeServiceResp.agents) {
                                console.log('this._zipCodeServiceResp.agents==' + JSON.stringify(this._zipCodeServiceResp.agents[key]));

                                if (this._zipCodeServiceResp.agents[key].display_name == 'Will Call') {
                                    console.log('this._zipCodeServiceResp.agents==' + JSON.stringify(this._zipCodeServiceResp.agents[key]));
                                    this.pickupLocation = this._zipCodeServiceResp.agents[key];
                                    console.log('this.pickupLocation.==' + JSON.stringify(this.pickupLocation));

                                }

                            }
                        }

                    } else if ('hd' in this._deliveryTypeData && (this._deliveryTypeData['hd']).length >= 1 && this.cartItems[i].ProductDetails.fields.Is_Accessory__c == 'Yes'  && (!this.cartItems[i].ProductDetails.fields.BWC_Is_Part__c || this.cartItems[i].ProductDetails.fields.BWC_Is_Part__c == 'false')) {
                        if (this._zipCodeServiceResp.has_home_delivery)

                            this.hdList.push(this.cartItems[i]);
                        else if (this._zipCodeServiceResp.has_will_call) {
                            this.pickupList.push(this.cartItems[i]);
                            for (let key in this._zipCodeServiceResp.agents) {
                                console.log('this._zipCodeServiceResp.agents==' + JSON.stringify(this._zipCodeServiceResp.agents[key]));

                                if (this._zipCodeServiceResp.agents[key].display_name == 'Will Call') {
                                    console.log('this._zipCodeServiceResp.agents==' + JSON.stringify(this._zipCodeServiceResp.agents[key]));
                                    this.pickupLocation = this._zipCodeServiceResp.agents[key];
                                    console.log('this.pickupLocation.==' + JSON.stringify(this.pickupLocation));

                                }

                            }
                        }

                    } else if (productDeliveryType == 'sps' && (this.cartItems[i].ProductDetails.fields.BWC_Is_Part__c == 'false' || this.cartItems[i].ProductDetails.fields.BWC_Is_Part__c == false)) {
                        if (this._zipCodeServiceResp.has_small_package)
                            this.prodShippingList.push(this.cartItems[i]);

                        else if (this._zipCodeServiceResp.has_will_call) {
                            this.pickupList.push(this.cartItems[i]);
                            for (let key in this._zipCodeServiceResp.agents) {
                                console.log('this._zipCodeServiceResp.agents==' + JSON.stringify(this._zipCodeServiceResp.agents[key]));

                                if (this._zipCodeServiceResp.agents[key].display_name == 'Will Call') {
                                    console.log('this._zipCodeServiceResp.agents==' + JSON.stringify(this._zipCodeServiceResp.agents[key]));
                                    this.pickupLocation = this._zipCodeServiceResp.agents[key];
                                    console.log('this.pickupLocation.==' + JSON.stringify(this.pickupLocation));

                                }

                            }
                        }
                    } else if ((this.cartItems[i].ProductDetails.fields.BWC_Is_Part__c || this.cartItems[i].ProductDetails.fields.BWC_Is_Part__c == 'true') && productDeliveryType == 'sps fee') {
                        if (this._zipCodeServiceResp.has_small_package)
                            this.partsList.push(this.cartItems[i]);
                        else if (this._zipCodeServiceResp.has_will_call) {
                            this.pickupList.push(this.cartItems[i]);
                            for (let key in this._zipCodeServiceResp.agents) {
                                console.log('this._zipCodeServiceResp.agents==' + JSON.stringify(this._zipCodeServiceResp.agents[key]));

                                if (this._zipCodeServiceResp.agents[key].display_name == 'Will Call') {
                                    console.log('this._zipCodeServiceResp.agents==' + JSON.stringify(this._zipCodeServiceResp.agents[key]));
                                    this.pickupLocation = this._zipCodeServiceResp.agents[key];
                                    console.log('this.pickupLocation.==' + JSON.stringify(this.pickupLocation));

                                }

                            }
                        }
                    }
                    //}
                }

            }

            console.log(' SDS LIST PRODUCTS -> ' + this.sdsList.length);
            console.log(' HD LIST PRODUCTS -> ' + this.hdList.length);
            console.log(' SPS LIST PRODUCTS -> ' + this.prodShippingList.length);
            console.log(' PARTS LIST PRODUCTS -> ' + this.partsList.length);
            console.log(' PICKUP LIST PRODUCTS -> ' + this.pickupList.length);

            let productsData = {
                'sdsList': this.sdsList,
                'hdList': this.hdList,
                'prodShippingList': this.prodShippingList,
                'partsList': this.partsList,
                'pickupList': this.pickupList,
                'pickupFlag': this.pickupList.length > 0 ? true : false,
                'partsFlag': this.partsList.length > 0 ? true : false,
                //'hdFlag': (this.hdList.length > 0 || this.sdsList.length > 0) ? true : false,
                'hdFlag': this.hdList.length > 0 ? true : false,
                'sdsFlag': this.sdsList.length > 0 ? true : false,
                'prodFlag': this.prodShippingList.length > 0 ? true : false,
                'pickupLocation': this.pickupLocation,
                'memberSavings': this.memberSavings
            }
            //console.log('products data --> ' + JSON.stringify(productsData));
            this.dispatchEvent(
                new CustomEvent("segregateproducts", {
                    bubbles: true,
                    composed: true,
                    detail: { shipTypeProducts: productsData, cartItems: this.cartItems }
                })
            );
        }
    }
}