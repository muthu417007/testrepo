import { LightningElement, track, api, wire } from 'lwc';
import { MessageContext, publish, subscribe, unsubscribe, createMessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import bwcCartPage from '@salesforce/messageChannel/bwcCartPage__c';
import bwc_membershipPopUp from '@salesforce/messageChannel/bwc_membershipPopUp__c';
import bwc_membershipSavings from '@salesforce/messageChannel/bwc_membershipSavings__c';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import { restartCheckout } from 'commerce/checkoutApi';
import updateCheckoutStatus from "@salesforce/apex/BWC_ShippingAndBillingAddressController.updateCheckoutStatus";
import addPartsShippingAsLineItem from '@salesforce/apex/BWC_ProtectionPlanController.addPartsShippingAsLineItem';
import LightningAlert from "lightning/alert";

export default class Bwc_cartSummary extends NavigationMixin(LightningElement) {
    userId = USER_ID;
    deliveryflag = false;
    installationflag = false;
    promotionflag = false;
    partsflag = false;
    partsOptionsflag = false;
    @track memberinstallationflag = false;
    memberDeliveryflag = false;
    @track free = '';
    @track isFree = false;
    @track freeInstallation = '';
    @track isFreeInstallation = false;
    @track freeProtectionPlan = '';
    @track isFreeProtectionPlan = false;
    @track isSameInstallation = false;
    @track isSameProtectionPlan = false;
    checkoutFlag = true;
    currencyCode='USD';
    alertShown=false;
    @track _subTotal = 0.0;
    @track _fixedTotal = 0.0;
    @track _fixedPromo = 0.0;
    @track _fixedcartTot = 0.0;
    @track total = 0.0;
    @track partsShipFee = 0.0;
    @track delivery = 0.0;
    @track selectedOption;
    @track selectShippingPrice = '';
    @track showTextStandard = false;
    @track showTextSecond = false;
    @track showTextNext = false;
    @track partsShipfree = '';
    @track subscription = null;
    @track subscription1 = null;
    @track receivedObjectData;
    @track options = [];
    @track cartItemsData = {};
    @track _savedAmt;
    @track _cStatus;
    @track memberSavings = 0.0;
    @track fixedMemSavings = 0.00;
    @track partsIds;
    protectionPlanFee = 0.0;
    memberProtectionPlanFee = 0.0;
    protectionPlanFeeflag = false;
    protectionFee = 0.0;


    @track _cartProductAmountWithDiscount;
    @track _cartPromotionAdjustmentTotal;

    @track installationfee = 0.0;


    @api
    get cart() {
        return this._cartItems;
    }
    set cart(val) {
        this._cartItems = val;
        //console.log("_cartItems====" + JSON.stringify(val));
    }

    @api
    get cartId() {
        return this._cartId;
    }
    set cartId(val) {
        this._cartId = val;
        // console.log("_cartId====" + JSON.stringify(val));
    }

    @api
    get webStoreId() {
        return this._webStoreId;
    }
    set webStoreId(val) {
        this._webStoreId = val;
        // console.log("_webStoreId====" + val);
    }

    @api
    get acctId() {
        return this._accountId;
    }
    set acctId(val) {
        this._accountId = val;
        //console.log(`_accountId==== ${val}`);
    }

    @api
    get cartStatus() {
        return this._cartStatus;
    }
    set cartStatus(val) {
        this._cartStatus = val;
        //console.log(`_cartStatus===  ${val}`);
    }


    @api
    get cartProductAmountWithDiscount() {
        return this._cartProductAmountWithDiscount;
    }
    set cartProductAmountWithDiscount(val) {
        this._cartProductAmountWithDiscount = val;
        //console.log(`_cartProductAmountWithDiscount===  ${val}`);
    }

    @api
    get cartPromotionAdjustmentTotal() {
        return this._cartPromotionAdjustmentTotal;
    }
    set cartPromotionAdjustmentTotal(val) {
        this._cartPromotionAdjustmentTotal = val;
        // console.log(`_cartPromotionAdjustmentTotal===  ${val}`);
    }

    @wire(CurrentPageReference) currentPageReference;
    get isGuestUser() {
        return !this.userId;

    }

    context = createMessageContext();

    connectedCallback() {
        this.handleSubscribe();
        this.handleMemberSavings();

    }

    handleSubscribe() {
        //console.log("printFromhandleSub");
        if (this.subscription) {
            return;
        }
        this.context = createMessageContext();
        this.subscription = subscribe(this.context, bwcCartPage, (message) => {

            // Handle the received message and its object data
            // console.log("MessageFromSub" + JSON.stringify(message));

            this.receivedObjectData = message.myObjectField;
            console.log("receivedObjectData cartSumm" + JSON.stringify(this.receivedObjectData));
            this.options = this.receivedObjectData.partsShipOptions;

            //installation
            if (this.receivedObjectData.installation > 0) {
                this.installationflag = true;
                console.log("isSame 0",this.receivedObjectData.memberInstallation,this.receivedObjectData.installation,this.isSame, this.isFree,this.free);

                if (this.receivedObjectData.isUserMember === true) {
                    this.memberinstallationflag = true;
                    if (this.receivedObjectData.memberInstallation == 0.00) {
                        this.isFreeInstallation = true;
                        this.freeInstallation = 'FREE';
                        //console.log("isSame 1",this.receivedObjectData.memberInstallation,this.receivedObjectData.installation,this.isSame,this.isFree,this.free);

                    }
                    else {
                        this.isFreeInstallation = false;
                        this.freeInstallation = '';
                       // console.log("isSame 2",this.receivedObjectData.memberInstallation,this.receivedObjectData.installation,this.isSame,this.isFree,this.free);
                        if (this.receivedObjectData.memberInstallation == this.receivedObjectData.installation) {
                            this.isSameInstallation = true;
                        }

                        else {
                            this.isSameInstallation = false;
                        }
                       // console.log("isSame 3",this.receivedObjectData.memberInstallation,this.receivedObjectData.installation,this.isSame,this.isFree,this.free);

                    }
                }
                else {
                    this.memberinstallationflag = false;
                }
            } else {
                this.installationflag = false;
            }
            console.log("Installation in Summary" + this.receivedObjectData.installation, this.installationflag);
            console.log("Free Installation:this.receivedObjectData.isUserMember,this.memberinstallationflag,this.free,this.isFree,this.receivedObjectData.memberInstallation", this.receivedObjectData.isUserMember, this.memberinstallationflag, this.free, this.isFree, this.receivedObjectData.memberInstallation, this.receivedObjectData.installation);

            //ProtectionPlan Fee
            if (this.receivedObjectData.protectionPlanFee > 0) {
                this.protectionPlanFeeflag = true;

                if (this.receivedObjectData.isUserMember === true) {
                    this.memberinstallationflag = true;
                    if (this.receivedObjectData.memberProtectionPlanFee == 0.00) {
                        this.isFreeProtectionPlan = true;
                        this.freeProtectionPlan = 'FREE';
                    }
                    else {
                        this.isFreeProtectionPlan = false;
                        this.freeProtectionPlan = '';
                        if (this.receivedObjectData.memberProtectionPlanFee === this.receivedObjectData.protectionPlanFee) {
                            this.isSameProtectionPlan = true;
                        }
                        else {
                             this.isSameProtectionPlan = false;
                        }
                    }
                }
                else {
                    this.memberinstallationflag = false;
                }
            } else {
                this.protectionPlanFee = false;
            }
            console.log("protectionPlanFee in Cart Summary" + this.receivedObjectData.protectionPlanFee, this.protectionPlanFee);
            console.log("Free memberProtectionPlanFee:this.receivedObjectData.isUserMember,this.memberinstallationflag,this.free,this.isFree,this.receivedObjectData.memberProtectionPlanFee", this.receivedObjectData.isUserMember, this.memberinstallationflag, this.free, this.isFree, this.receivedObjectData.memberProtectionPlanFee, this.receivedObjectData.protectionPlanFee);



            //delivery
            if (this.receivedObjectData.delivery > 0) {
                this.deliveryflag = true;
                if (this.receivedObjectData.isUserMember === true) {
                    this.free = 'FREE';
                }
                else {
                    this.free = '';
                }

            } else
                this.deliveryflag = false;

            console.log("this.receivedObjectData.delivery Summary", this.receivedObjectData.delivery);


            //promotions  
            if (this.receivedObjectData.addPromotions === true) {
                if (this.receivedObjectData.promotions !== 0 && this.receivedObjectData.promotions !== null) {
                    this.promotionflag = true;
                }
            }
            else
                this.promotionflag = false;

            //parts Shipping Options    
            if (this.options.length > 0) {
                this.partsOptionsflag = true;
            } else{
                this.partsOptionsflag = false;
            }

            this.partsIds = this.receivedObjectData.partsList.map(part => part.id);
            /*console.log('##ship options in Summary ' + JSON.stringify(this.receivedObjectData.partsShipOptions));
            console.log('##this.receivedObjectData.partsList', JSON.stringify(this.receivedObjectData.partsList));          
            console.log("##PartsIds", JSON.stringify(this.partsIds));
            console.log("cart Total in Summary" + this.receivedObjectData.total);
            console.log("Delivery in Summary" + this.receivedObjectData.delivery);
            console.log("Installation in Summary" + this.receivedObjectData.installation);
            console.log("Promotion in Summary" + this.receivedObjectData.promotions);
            console.log('ship options in Summary ' + JSON.stringify(this.receivedObjectData.partsShipOptions)); */

            let promo = this.receivedObjectData.promotions;
            if (promo !== null) {
                this._fixedPromo = promo.toFixed(2);
                console.log("FixedPromo in Summary" + this._fixedPromo);
            }

            let cartTot = this.receivedObjectData.total;
            if (cartTot !== null) {
                this._fixedcartTot = cartTot.toFixed(2);
                console.log("Summary_fixedcartTot" + this._fixedcartTot);
            }

            //Add Promotions to Total or Not
            this.delivery=  this.memberinstallationflag === false ? this.receivedObjectData.delivery : 0;
            this.installationfee = this.memberinstallationflag === true ? this.receivedObjectData.memberInstallation : this.receivedObjectData.installation;
            this.protectionFee = this.memberinstallationflag === true ? this.receivedObjectData.memberProtectionPlanFee : this.receivedObjectData.protectionPlanFee;
              
            if (this.receivedObjectData.addPromotions === true) 
            {
                    this.total = (this.receivedObjectData.total + parseFloat(this.delivery) + parseFloat(this.installationfee) + parseFloat(this.protectionFee)) - this.receivedObjectData.promotions;
                    console.log("CartTotal With Promotions: " + this.total);
            } else 
            {
                    this.total = this.receivedObjectData.total + parseFloat(this.delivery) + parseFloat(this.installationfee) + parseFloat(this.protectionFee);
                    console.log("CartTotal Without Promotions: " + this.total, this.protectionFee);
            }
            

            if (this.partsShipfree === '') {
                this.total += this.partsShipFee;
                console.log("Cartotal with partsShipFee");
            }

            this._fixedTotal = this.total.toFixed(2);
            console.log("Summary FixedTotal" + this._fixedTotal);

            this._subTotal = this.total - this.partsShipFee;

            //console.log("this.receivedObjectData.cartItems", JSON.stringify(this.receivedObjectData.cartItems));
            console.log("this.receivedObjectData.cartItems length", this.receivedObjectData.cartItems.length);

            //     if(this.receivedObjectData.cartItems.length > 0){
            //         this.checkoutFlag=false;

            //    }

            switch (true) {
                case (
                    this.receivedObjectData.hdList.length > 0 &&
                    this.receivedObjectData.hdList.every(item => item.ProductDetails.fields.BWC_IsPurchasable__c === 'true')
                ):
                case (
                    this.receivedObjectData.sdsList.length > 0 &&
                    this.receivedObjectData.sdsList.every(item => item.ProductDetails.fields.BWC_IsPurchasable__c === 'true')
                ):
                case (
                    this.receivedObjectData.pickupList.length > 0 &&
                    this.receivedObjectData.pickupList.every(item => item.ProductDetails.fields.BWC_IsPurchasable__c === 'true')
                ):
                case (
                    this.receivedObjectData.partsList.length > 0 &&
                    this.receivedObjectData.partsList.every(item => item.ProductDetails.fields.BWC_IsPurchasable__c === 'true')
                ):
                case (
                    this.receivedObjectData.fedexList.length > 0 &&
                    this.receivedObjectData.fedexList.every(item => item.ProductDetails.fields.BWC_IsPurchasable__c === 'true')
                ):
                    console.log("Entered checkoutFlag condition");
                    this.checkoutFlag = false;
                    break;
                default:
                    this.checkoutFlag = true;
                    break;
            }
            // console.log("alertShown 1", this.alertShown, this.checkoutFlag);


            if (this.checkoutFlag) {
                const nonPurchasableItems = [];

                [
                    ...this.receivedObjectData.hdList,
                    ...this.receivedObjectData.sdsList,
                    ...this.receivedObjectData.pickupList,
                    ...this.receivedObjectData.partsList,
                    ...this.receivedObjectData.fedexList,
                ].forEach(item => {
                    if (item.ProductDetails.fields.BWC_IsPurchasable__c !== 'true') {
                        nonPurchasableItems.push(item);
                    }
                });
             // console.log("alertShown 2", nonPurchasableItems.length, this.alertShown, this.checkoutFlag);


                // Show alert with item SKUs
                if (!this.alertShown && nonPurchasableItems.length > 0) {
                    const itemSKUs = nonPurchasableItems.map(item => item.ProductDetails.fields.StockKeepingUnit);
                    LightningAlert.open({
                        message: `This product(s) ${itemSKUs.join(', ')} is(are) not purchasable. Please remove them from the cart to checkout!`,
                        theme: "error",
                        label: ""
                    });
                    this.checkoutFlag=false;
                    this.alertShown = true;
                }
                 //console.log("alertShown 3", this.alertShown, this.checkoutFlag);

            }

            //Add into in localstorage to use in checkoutSummary
            let cartRecordsData = {
                'hdList': this.receivedObjectData.hdList,
                'sdsList': this.receivedObjectData.sdsList,
                'pickupList': this.receivedObjectData.pickupList,
                'partsList': this.receivedObjectData.partsList,
                'fedexList': this.receivedObjectData.fedexList,
                'total': this.total,
                'cartTotal': this.receivedObjectData.total,
                'deliveryfee': this.receivedObjectData.delivery,
                'installationfee': this.installationfee,
                'memberinstallationfee': this.receivedObjectData.memberInstallation,
                'protectionPlanFee': this.receivedObjectData.protectionPlanFee,
                'memberProtectionPlanFee': this.receivedObjectData.memberProtectionPlanFee,
                'isUserMember': this.receivedObjectData.isUserMember,
                'promotions': this.receivedObjectData.promotions,
                'showPromotion': this.receivedObjectData.addPromotions,
                'allItems': this.receivedObjectData.cartItems,
                'partsShipOptions': this.receivedObjectData.partsShipOptions,
                'accountId': (this.userId != null) ? this._accountId : null,
                'partsShipFee': this.partsShipFee,
                'cartId': this._cartId

            }
            this.cartItemsData = cartRecordsData;
        }, { scope: APPLICATION_SCOPE });
    }

    handleMemberSavings() {
        if (this.subscription1) {
            return;
        }
        this.subscription1 = subscribe(
            this.messageContext,
            bwc_membershipSavings,
            (savings) => {
               // console.log("@@@memberSavings In cartSummary" + JSON.stringify(savings));
                this.memberSavings = parseFloat(savings.savings);

                if (!isNaN(this.memberSavings)) {
                    this.fixedMemSavings = this.memberSavings.toFixed(2);
                   // console.log("memberSaving subscribe cs", this.memberSavings, this.fixedMemSavings);
                } else {
                    console.error("Invalid number for memberSavings");
                }
            });

       // console.log("memberSaving subscribe", this.fixedMemSavings);
    }


    disconnectedCallback() {
        unsubscribe(this.subscription);
        unsubscribe(this.subscription1);
    }

    @track previousOption = '';
    handleSelectionChange(event) {
        this.selectedOption = event.detail.value;
        console.log("##Selected Option", this.selectedOption);

        this.addPartsShippingAsLineItem();

        if (this.selectedOption == 'Standard_Shipping') {
            if (this.receivedObjectData.isUserMember === true) {
                this.partsShipfree = 'FREE';
            }
            else {
                this.partsShipfree = '';
            }
            //console.log("this.free from summary", this.free);
            this.partsShipFee = this.options.find(record => record.value === 'Standard_Shipping').additionalParam;
            // console.log("##partsShipFee", this.partsShipFee);
            this.showTextStandard = true;
            this.showTextSecond = false;
            this.showTextNext = false;

        }
        if (this.selectedOption == 'Second_Day') {
            this.partsShipfree = '';
            this.partsShipFee = this.options.find(record => record.value === 'Second_Day').additionalParam;
            this.showTextSecond = true;
            this.showTextNext = false;
            this.showTextStandard = false;

        }
        if (this.selectedOption == 'Next_Day') {
            this.partsShipfree = '';
            this.partsShipFee = this.options.find(record => record.value === 'Next_Day').additionalParam;
            this.showTextNext = true;
            this.showTextSecond = false;
            this.showTextStandard = false;
        }


        this.partsflag = true;
        if (this.previousOption === 'Standard_Shipping') {
            this.memberSavings = parseFloat(this.memberSavings) - this.options.find(record => record.value === 'Standard_Shipping').additionalParam;
            this.fixedMemSavings = (this.memberSavings).toFixed(2);
        }
        if (this.selectedOption === 'Standard_Shipping') {
            this.memberSavings = parseFloat(this.memberSavings) + parseFloat(this.partsShipFee);
            this.fixedMemSavings = (this.memberSavings).toFixed(2);
        }

        this.publishMemberSavingsWithPartShipFee(this.fixedMemSavings);


        // Update the previousOption value with the newSelectedOption
        this.previousOption = this.selectedOption;
        console.log("this.previousOption", this.previousOption);
        console.log("##Final Parts Ship Fee", this.partsShipFee);

        if (this.receivedObjectData.isUserMember === true && this.partsShipFee === this.options.find(record => record.value === 'Standard_Shipping').additionalParam) {
            this.total = this._subTotal;
            this._fixedTotal = this.total.toFixed(2);
            console.log("PartsShipFee in Summary For Member" + this.partsShipFee);
        }
        else {
            this.total = this._subTotal + this.partsShipFee;
            this._fixedTotal = this.total.toFixed(2);
            console.log("PartsShipFee in Summary" + this.partsShipFee);
        }




    }

    publishMemberSavingsWithPartShipFee(value) {
        const savings = { savings: value }
        publish(this.messageContext, bwc_membershipSavings, savings);
        console.log("@@@publishMemberSavingsWithPartShipFee", JSON.stringify(savings));

    }

    @wire(MessageContext)
    messageContext;

    handleBodewellMemberClick() {
        const payload = {
            bodewellMemberClick: true
        };
        publish(this.messageContext, bwc_membershipPopUp, payload);
    }



    /**
     * @description This method is used to handle the checkout button click event.
     */
    async handleCheckout() {
        if (!this.isGuestUser) {
            await this.updateStatus('Customer');
        }

        //console.log('bwc_cartSummary::handleCheckout::checkout button clicked');
        this.cartItemsData["partsShipSelected"] = this.selectedOption;
        this.cartItemsData["partsShipFee"] = this.partsShipFee;
        // console.log('bwc_cartSummary::handleCheckout::Checkout local storage payload ' + JSON.stringify(this.cartItemsData));
        localStorage.setItem('checkoutProducts', JSON.stringify(this.cartItemsData));

        if (!this.isGuestUser) {
            await restartCheckout();
        }


        const navContextPageName = this.isGuestUser ? 'Login' : 'Current_Checkout';
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: navContextPageName,
            }

        });

        console.log("After Nav to checkout, CartStatus", this.cartStatus);
        if (navContextPageName == 'Current_Checkout' && this.cartStatus == 'Active' && this.cartStatus != 'Checkout') {
            if (this.cartStatus != 'Checkout') {
                console.log("Inside condition to update cart Status & status", this.cartStatus);
            }
            setTimeout(() => {
                window.location.reload();
            }, 1000);
            console.log("cartStatus from checkout", this._cartStatus);
        }




    }

    @api
    get cartItemId() {
        return this._cartItemId;

    }
    set cartItemId(val) {
        this._cartItemId = val;
        console.log('this._cartItemId===' + this._cartItemId);

    }



    addPartsShippingAsLineItem() {
        addPartsShippingAsLineItem({ sku: this.selectedOption, cartId: this._cartId, cartItemIdList: this.partsIds })
            .then(result => {
                this.partsShipFee = result[0].BWC_Service_Price__c;
                console.log("##partsShipFee cartSummary", this.partsShipFee);
                console.log('##Parts Ship Fee Result cartSummary===' + JSON.stringify(result));
            })
            .catch(error => {
                console.log(' ##Parts Ship Fee error cartSummary===' + JSON.stringify(error));


            })
    }

    async updateStatus(statusVal) {
        try {
            let result = await updateCheckoutStatus({ cartId: this.cartId, status: statusVal })

            console.log("shub status==result" + JSON.stringify(result));

        } catch (error) {
            console.log('error===', JSON.stringify(error));
            throw error;
        }
    }

}