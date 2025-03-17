import { LightningElement, track, api, wire } from 'lwc';
import { CartSummaryAdapter } from 'commerce/cartApi';
import PUBLISHABLE_KEY from "@salesforce/label/c.BWC_StripePublishableKey";
import redirect_URL from "@salesforce/label/c.BWC_Stripe_Return_URL";
import { placeOrder } from 'commerce/checkoutApi';
import getCheckoutStatus from "@salesforce/apex/BWC_ShippingAndBillingAddressController.getCheckoutStatus";
import bwc_getRelatedCartItemAll from '@salesforce/apex/BWC_ProductViewServicesController.bwc_getRelatedCartItemAll';
import BuyerGroup from '@salesforce/label/c.BWC_BuyerGroup';
import zipCodeChannel from '@salesforce/messageChannel/zipCodeChange__c';
import getTaxAmount from '@salesforce/apex/BWC_CartController.getTaxAmount';

//abhishek changes
import checkAndHitUpdateConsumer from "@salesforce/apex/BWC_UpdateBillingAddress.checkAndHitUpdateConsumer";
import MEMBER_SKU from '@salesforce/label/c.BWC_BodewellMemberSKU';
import { SessionContextAdapter } from 'commerce/contextApi';
import { CartItemsAdapter } from 'commerce/cartApi';
import getCustomerDetails from '@salesforce/apex/BWC_StripeSplitController.createStripeCustomer';
import searchPaymentIntent from '@salesforce/apex/BWC_StripeSplitController.searchPaymentIntent';
import getPaymentMethod from '@salesforce/apex/BWC_StripeSplitController.getPaymentMethod';
//import calculateTotalAmount from '@salesforce/apex/BWC_StripeSplitController.calculateTotalAmount';
import USER_ID from '@salesforce/user/Id';
import BWC_UI from '@salesforce/resourceUrl/BodewellTheme';
import createPaymentIntent from "@salesforce/apex/BWC_StripeSplitController.createPaymentIntent";
const stripe = window.Stripe(PUBLISHABLE_KEY);
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import authorizePayment from "@salesforce/apex/BWC_StripeSplitController.authorizePayment";
import getPaymentIntent from "@salesforce/apex/BWC_StripeSplitController.getPaymentIntent";
import updatePaymentIntent from "@salesforce/apex/BWC_StripeSplitController.updatePaymentIntent";
import updatePaymentIntentAmount from "@salesforce/apex/BWC_StripeSplitController.updatePaymentIntentAmount";

import getPaymentsOnOrderPaymentSummary from "@salesforce/apex/BWC_StripeSplitController.getPaymentsOnOrderPaymentSummary";
import CHECKOUT_CHANNEL from '@salesforce/messageChannel/BWC_Checkout__c';
import { subscribe, publish, unsubscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import getOrderDeliveryPaymentSummary from '@salesforce/apex/BWC_StripeSplitController.getOrderDeliveryPaymentSummary';
import { NavigationMixin } from 'lightning/navigation';

export default class Bwc_stripePaymentComponent extends NavigationMixin(LightningElement) {
    currencyCode="USD";
    isNo=false;
    isLoading = false;
    publisherMessage = '';
    subscription = null;
    zipCode;
    @wire(MessageContext)
    messageContext;
    amountPaid = 0.0;
    remainingAmount = 0.0;
    orderInProgress = false;

    isPaymentIntent = false;
    deliveryfee;
    installationfee;
    memberInstallation;
    _cartTotal = 0.0;
    connectedCallback() {


        if (localStorage.getItem("checkoutProducts")) {
            let localStorageProducts = JSON.parse(
                localStorage.getItem("checkoutProducts")
            );
            this.cartId = localStorageProducts.cartId;
            this._cartTotal = parseFloat(localStorageProducts.cartTotal).toFixed(2);
            // this.deliveryfee = this.localStorageProducts.deliveryfee;
            // this.installationfee = this.localStorageProducts.installationfee;
            // this.memberInstallation = this.localStorageProducts.memberinstallationfee;
            console.log(" checkout shipping this.cartId===" + this.cartId);
            this.getstatusOfsteps();
        }


        if (localStorage.getItem('zipcode')) {
            //An Id key is in the local Storage
            this.localStorageZipCode = JSON.parse(localStorage.getItem('zipcode'));
            this.zipCode = this.localStorageZipCode.Zipcode;
            //Clear local storage after getting the values

        }

        this.handleSubscribe();
        this.updateBillingAddressEBS();

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
    getstatusOfsteps() {
        getCheckoutStatus({ cartId: this.cartId })
            .then(result => {

                this.status = result;

                if (this.status === "Payment") {
                    this.searchPaymentIntentForCart(this.cartId);
                    this.isPaymentIntent = true;

                }
                console.log("Bwc_stripePaymentComponent::this.status===2" + this.status);
            })
            .catch(error => {
                console.log(" this.result.error===" + JSON.stringify(error));
            })
    }

    intentId;
    Step_4 = BWC_UI + '/icons/checkout-icons/step-4.svg';
    isDisabled = true;
    @track options = [
        { value: 'yes', label: 'Yes',check:true },
        { value: 'no', label: 'No, charge this amount' }
    ];
    inputHandler(event) {
        this.isDisabled = true;
    }
    selectedOption;
    _amount = 0.0;
    async handleChange(event) {
        console.log('event.target.value' + event.target.value);
        this.selectedOption = event.target.label;
        if (event.target.checked == true && event.target.value == 'yes') {
            this.isNo=false;
            //  this.orderInProgress=true;
            this._amount = this.remainingAmount;
            //String intentId,Long amount
            this.isDisabled = true;
           
            // radioList[i].checked=true;
            let result = await updatePaymentIntentAmount({ intentId: this.intentId, amount: this._amount })

            if (result.error) {
                console.log('error in updatePaymentIntentAmount apex class-->' + error);
                //  this.orderInProgress=false;
                this.isDisabled = false;
            } else {
                console.log('updatePaymentIntentAmount-->' + result);
                //  this.orderInProgress=false;
                this.isDisabled = false;
            }


        }

        else if(event.target.checked == true && event.target.value == 'no') {
            this.isNo=true;
        }



        // Handle the selected option value here
    }
    showAmountError;
    async handleAmountChange(event) {
        this._amount = parseFloat(event.target.value);
        let val = parseFloat(event.target.dataset.id);

        console.log('val===' + typeof (val));
        console.log('val===' + typeof (this._amount));
        console.log('val===' + val);
        console.log('event.target.value===' + this._amount);
        let remain = parseFloat(val - this._amount);
        if (remain >= 0.50) {
            if (this._amount > val || this._amount == 0.0 || this._amount < 0.50) {
                event.target.classList.add("red-border");
                this.showAmountError = 'Entered amount should be less than' + val + ' or should be greater than/equal to $0.50 ';

            } else {
                if (this._amount > 0) {
                    this.showAmountError = '';
                    event.target.classList.remove("red-border");
                    let radioList = this.template.querySelectorAll(`[data-name="split"]`);
                    //   const changedIndex = event.target.dataset.index;
                    //  console.log('==changedIndexchangedIndex' + changedIndex);
                    for (let i = 0; i < radioList.length; i++) {
                        console.log('radioList[i].value' + radioList[i].value);
                        if (radioList[i].checked == true && radioList[i].value == 'no') {
                            //  this.orderInProgress=true;
                            this._amount = parseFloat(event.target.value);
                            //String intentId,Long amount
                            this.isDisabled = true;
                            radioList[i].checked = true;
                            let result = await updatePaymentIntentAmount({ intentId: this.intentId, amount: this._amount })

                            if (result.error) {
                                console.log('error in updatePaymentIntentAmount apex class-->' + error);
                                //  this.orderInProgress=false;
                                this.isDisabled = false;
                            } else {
                                console.log('updatePaymentIntentAmount-->' + result);
                                //  this.orderInProgress=false;
                                this.isDisabled = false;
                            }
                        }

                    }
                }
                else {
                    event.target.classList.add("red-border");
                    this.showAmountError = 'Entered amount should be greater than 0';
                    this.isDisabled = true;
                }

            }
        }
        else {
            event.target.classList.add("red-border");
            this.showAmountError = 'Remaining amount must be at least $0.50 ';

        }



    }
    cartId;
    grandAmountTotal = 0.0;
    _cartSummaryJSON;
    _cartSummary;
    _webstoreId;
    rid;
    serviceAmount = 0.0;
    isMember = false;
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
            if (data.buyerGroups[0].name === BuyerGroup) {
                this.isMember = true;
            }
            else {
                this.isMember = false;
            }
            this.getStripeCustomerDetails();
        } else if (error) {
            console.log(`bwc_cybersourceHPP::wireSessionContext::error = ${JSON.stringify(error, null, 2)}`);
        }
    }
    cartItemList;
    memberPresent = false;
    @wire(CartItemsAdapter)
    wireCartitemContext({ data, error }) {
        if (data) {
            this.cartItemList = data;
            console.log('cartItemList===' + JSON.stringify(this.cartItemList));
            let cartitems = this.cartItemList.cartItems;
            for (let i = 0; i < (cartitems).length; i++) {
                // console.log('cartItemList==='+JSON.stringify(cartitems[i])); 
                console.log('cartItemList===' + cartitems[i].cartItem.productDetails.sku);
                if (cartitems[i].cartItem.productDetails.sku === MEMBER_SKU) {
                    this.memberPresent = true;
                }

            }
            //  test.cartItems[0].cartItem.productDetails.sku
        } else if (error) {
            console.log(`CartItemsAdapter::error = ${JSON.stringify(error, null, 2)}`);
        }
    }
    @api serviceAmount;
    tax = 0.0;
    @wire(CartSummaryAdapter)
    wireCartSummary({ data, error }) {
        if (data) {
            // this.grandAmountTotal = 0.0;
            console.log('cartSummaryAdapter Payment-->', data);
            this.cartId = data.cartId;
            this.tax = data.totalTaxAmount;
            //  this.getServiceCharge(data.cartId);


            //  const grandAmount = parseFloat(data.grandTotalAmount) + parseFloat(this.serviceAmount);
           // this.grandAmountTotal = parseFloat(this._cartTotal) + parseFloat(this.tax);
            this._webstoreId = data.webstoreId;
            //  console.log('grandAmount-->' + grandAmount);
            this._cartSummary = data;
            // this._cartSummaryJSON = JSON.stringify({
            //     "grandTotalAmount": grandAmount,
            //     "totalTaxAmount": data.totalTaxAmount,
            //     "cartId": data.cartId,
            //     "currencyIsoCode": data.currencyIsoCode,
            //     'webstoreId': data.webstoreId
            // });

        } else if (error) {
            console.log(`bwc_cybersourceHPP::wireCartSummary::error = ${JSON.stringify(error, null, 2)}`);
        }
    }


    getServiceCharge(cartId) {
        calculateTotalAmount({ cartId: cartId })
            .then(result => {
                console.log('ServiceResult-->' + result);
                this.serviceAmount = result;
            })
            .catch(error => {
                console.log('error in CalculateEntirePrice apex class-->' + error);
            })
    }
    orderPaymentDetails;
    @wire(getOrderDeliveryPaymentSummary, { orderSummaryId: '$rid' })
    bodewellPaymentSummary({ data, err }) {
        console.log(' PaymentSummary Orders', data);
        if (data) {
            if (data.paymentSummaryId) {
                this.orderPaymentDetails = data;
                this.createPayments(this.rid);
            }
            else {
                console.log(err)
                this.rid = this.rid + ' ';
            }

        }

        else if (err) {
            console.log(`::getOrderDeliveryPaymentSummary::error: ${JSON.stringify(err)}`);
        }

    }
    customerId;
    paymentIntents;
    getStripeCustomerDetails() {
        getCustomerDetails({ accountID: USER_ID })
            .then(result => {
                console.log('customer Id-->' + result);
                this.customerId = result;
            })
            .catch(error => {
                console.log('error in customerId apex class-->' + JSON.stringify(error));
            })
    }
    finalAmount = 0.0;
    taxAmt=0.0;
    taxAmount=0.0;
    async searchPaymentIntentForCart(cartId) {

        this.isLoading = true;
        this.amountPaid = 0.0;
        this.remainingAmount = 0.0;
        this.paymentIntentArray = [];

        this.installationFeeServices(cartId);
        console.log('searchPaymentIntent cartId-->' + cartId)

       
        console.log('service amt in Adapter-->' + this.serviceAmount);


        console.log('grandAmountTotal 2-->' + this.grandAmountTotal);

     
    
        let result1 = await getTaxAmount({ cartId:cartId});

        if (result1.error) {
            this.isLoading = false;
            console.log(' ## stripe taxAmt checkoutSummary error==' + JSON.stringify(error));  
        } else {
            console.log('## stripeTax in checkoutSummary===' + JSON.stringify(result1));
            
            this.taxAmt =  result1?.reduce((acc, item) => acc + item.Amount, null);
           
                this.taxAmount= (this.taxAmt)?.toFixed(2);     

           
            console.log("## stripe taxAmt checkoutSummary", this.taxAmount);
        }
        console.log("## stripe _cartTotal this.taxAmount", this._cartTotal,this.taxAmount);
        
        if(!this.taxAmount)
        {
            this.grandAmountTotal = parseFloat(this._cartTotal) 
 
        }
        else{
            this.grandAmountTotal = parseFloat(this._cartTotal) + parseFloat(this.taxAmount);

        }
        console.log("## stripe grandAmountTotal", this.grandAmountTotal);

        await new Promise((resolve) => setTimeout(resolve, 8000));
        let result = await searchPaymentIntent({ cartId: cartId });
        if (result.error) {
            this.isLoading = false;
            console.log('error searchPaymentIntent-->' + JSON.stringify(error));
        } else {
            console.log('searchPaymentIntent-->' + result);
            // console.log('searchPaymentIntent-->' + result.data);
            if (JSON.parse(result).data) {
                this.paymentIntents = JSON.parse(result).data;
                for (let i = 0; i < (this.paymentIntents).length; i++) {
                    if (this.paymentIntents[i].status === 'requires_capture') {
                        console.log('searchPaymentIntent data-->' + JSON.stringify(this.paymentIntents[i]));
                        this.amountPaid = parseFloat(this.amountPaid + ((this.paymentIntents[i].amount) / 100));
                        this.paymentIntentArray = [...this.paymentIntentArray, JSON.stringify(this.paymentIntents[i])];
                    }


                }
                let resultMap = await this.getPaymentMethodMap();

                console.log('searchPaymentIntent amount paid-->' + this.amountPaid);
                console.log('grandAmountTotal amount paid-->' + this.grandAmountTotal);
                // this.grandAmountTotal = this.grandAmountTotal+ parseFloat(this.serviceAmount);
                console.log("@@@totalServiceAmount searchPaymentIntent", this.totalServiceAmount);
                this.finalAmount = parseFloat(this.grandAmountTotal) + parseFloat(this.totalServiceAmount);
                this.remainingAmount = (((this.finalAmount)) - (parseFloat(this.amountPaid))).toFixed(2);
                console.log('searchPaymentIntent remainingAmount-->' + this.remainingAmount);
                console.log('searchPaymentIntent remainingAmount-->' + this.remainingAmount);

                if (this.remainingAmount > 0.0) {
                    console.log('in if >0');

                    this._amount = 0.0
                    this.handleInitialize(this.remainingAmount);
                    this.orderInProgress = false;
                }
                else if (this.remainingAmount == 0.00) {
                    console.log('in else if ==0');
                    console.log('searchPaymentIntent remainingAmount-->' + this.remainingAmount);
                    console.log('orderInProgress remainingAmount-->' + this.orderInProgress);
                    console.log('(this.paymentIntentArray).length -->' + (this.paymentIntentArray).length);
                    if (this.orderInProgress == false) {
                        console.log('in if');

                        console.log('(this.paymentIntentArray).length -->' + (this.paymentIntentArray).length);

                        if ((this.paymentIntentArray).length > 0) {
                            console.log('in if length');

                            this.authorizePaymentStripe();
                            this.orderInProgress = true;
                        }
                    }


                }

            }
        }




    }


    paymentElement;
    elements;
    elementsInstance;
    async handleInitialize(amount) {
        console.log('this.cartId[i].amount==' + amount);

        console.log('this.cartId[i].amount==' + this.cartId);
        console.log('this.customerId=' + this.customerId);
        console.log('this._webstoreId=' + this._webstoreId);
        if (amount && this.cartId && this.customerId && this._webstoreId) {

            console.log('this amount' + amount);

            try {
                const result = await createPaymentIntent({ amount: amount, customerId: this.customerId, cartId: this.cartId, webstoreId: this._webstoreId });



                if (result.error) {
                    console.log(JSON.stringify('Stripe:::::error' + result.error));
                    this.isLoading = false;
                    this.showToast("Error", result.error.message, "error");
                } else {

                    console.log(JSON.stringify('Stripe:::::result intent' + result));
                    console.log('Stripe:::::response=====' + result);
                    this.intentId = (JSON.parse(result)).id;
                    const clientSecret = (JSON.parse(result)).client_secret;
                    console.log('Stripe:::::clientSecret=====' + clientSecret);
                    // this.clientSecretArray = [...this.clientSecretArray, clientSecret];
                    // this.clientSecretNew = clientSecret;

                    const appearance = {
                        theme: 'stripe',
                    };
                    const elements = stripe.elements({ appearance, clientSecret });
                    this.elements = elements;
                    // this.elementsArray = [...this.elementsArray, elements]
                    // this.elementsInstance = elements;




                    const paymentElementOptions = {
                        layout: {
                            type: 'accordion',
                            defaultCollapsed: false,
                            radios: true,
                            spacedAccordionItems: false
                        }
                        ,
                        terms: {

                            card: 'always'
                        }
                    };

                    this.paymentElement = elements.create("payment", paymentElementOptions
                    );
                    // const options = {
                    //   amount: amounttemp,
                    //   currency: 'USD',
                    //   logoColor: 'primary',
                    //   fontSize: '16px',
                    //   textAlign: 'left',
                    // };
                    // let affirmid = this.amountArray[i].affirmId;
                    // const affirmMessageElement = elements.create('affirmMessage', options);
                    // affirmMessageElement.mount(this.template.querySelector("[data-id='" + affirmid + "']"));
                    // paymentElement.mount(this.template.querySelector("#payment-element"));
                    let id = 'paymentElement-0';
                    console.log('this id==' + id);
                    this.paymentElement.mount(this.template.querySelector("[data-id='" + id + "']"));
                    this.isLoading = false;
                    // this.paymentElementArray=[...this.paymentElementArray,this.paymentElement];

                    //this.template.querySelector('[data-id="submit"]').disabled = false;

                    this.template.querySelector('[data-id="submit"]')
                        .addEventListener("click", (event) => {
                            event.preventDefault();
                            //   this.handleSubmit(this.paymentElement, clientSecret);
                        });
                    this.paymentElement.addEventListener("change", (event) => {

                        console.log(JSON.stringify(event));
                        if (event.complete === true) {
                            console.log('event.complete==' + event.complete);
                            console.log('event.value.type==' + event.value.type);
                            //value: { type: "card" },
                            if (this.memberPresent == true) {
                                this.allowAffirm = true;
                            }
                            if (event.value.type === 'affirm') {
                                if (this.allowAffirm == true) {
                                    console.log('event.this.allowAffirm==' + this.allowAffirm);
                                    if (!this.paymentIntentArray.length > 0) {
                                        console.log('this.paymentIntentArray.length>0==' + !this.paymentIntentArray.length > 0);
                                        this.isDisabled = true;
                                        this.showToast("Error", "Affirm is not allowed as first payment as you have purchased monthly subscriptions. You must use card first.", "error");

                                    }
                                }
                                else {
                                    // this.isDisabled = false;
                                }
                            }

                            else {
                                //  this.isDisabled = false;
                            }



                        }

                    });

                }
            } catch (error) {
                console.error('error create payment intent' + JSON.stringify(error));
                this.showToast("Error", "An unexpected error occurred.", "error");
                this.isLoading = false;
            }




        }

    }

    async handleSubmit() {
        this.waitingForOrder = true;
        this.isDisabled = true;



        let elements = this.elements;

        // const { paymentIntent } = await stripe.retrievePaymentIntent(this.clientSecretArray[i]);
        // console.log('paymentIntent===='+JSON.stringify(paymentIntent));
        try {

            const result = await stripe.confirmPayment({
                elements: elements,
                confirmParams: {
                    // Make sure to change this to your payment completion page
                    return_url: redirect_URL,
                },
                redirect: 'if_required',
            });

            if (result.error) {
                console.log(JSON.stringify('Stripe:::::error' + JSON.stringify(result.error)));
                this.showToast("Error", result.error.message, "error");
                this.isDisabled = false;
            } else {
                console.log(JSON.stringify(result));
                // this.paymentIntentResultArray = [...this.paymentIntentResultArray, JSON.stringify(result.paymentIntent)];
                this.showToast("Success", "Payment succeeded!", "success");
                // this.orderInProgress=true;
                await new Promise((resolve) => setTimeout(resolve, 4000));

                this.searchPaymentIntentForCart(this.cartId);
                console.log(JSON.stringify('Stripe:::::result' + JSON.stringify(result)));
            }
        } catch (error) {
            console.error(error);
            this.waitingForOrder = false;
            this.isDisabled = false;
            this.showToast("Error", "An unexpected error occurred.", "error");
        } finally {
            this.waitingForOrder = false;
            // this.isDisabled=false;
        }


    }
    cardMethods;
    paymentIntentArray = [];
    waitingForOrder = false;
    async authorizePaymentStripe() {
        console.log('authorizePaymentStripe start==');

        console.log(' this.paymentIntentResultArray===' + this.paymentIntentArray);


        console.log(' this._cartSummary.webstoreId===' + this.cartId);
        console.log(' this._cartSummary.cartId===' + this.webstoreId);
        console.log(' this._cartSummary.USER_ID===' + USER_ID);
        if (this.cartId && this.paymentIntentArray && USER_ID && this._webstoreId) {
            try {
                const result = await authorizePayment({ cartId: this.cartId, webstoreId: this._webstoreId, userId: USER_ID, paymentIntentResult: this.paymentIntentArray })

                if (result.error) {
                    console.log('stripe::handlePayment::authorizePayment()::error =' + JSON.stringify(error));
                    this.showToast("Error", error.message, "error");
                    this.waitingForOrder = false;
                } else {
                    console.log('Place order===' + JSON.stringify(result));
                    this.cardMethods = result;
                    let resultOrder = await placeOrder();
                    if (resultOrder.error) {
                        console.log('stripe::handlePayment::authorizePayment()::error =' + JSON.stringify(resultOrder));
                        this.showToast("Error", resultOrder.error.message, "error");
                        this.waitingForOrder = false;
                    }
                    else {
                        console.log('result confirmpayment' + JSON.stringify(resultOrder));
                        this.rid = resultOrder.orderReferenceNumber;
                    }

                }


            }
            catch (error) {
                // this._shouldDisablePlaceOrder = false;
                console.log('stripe::handlePayment::authorizePayment()::error =' + JSON.stringify(error));
                this.showToast("Error", error.message, "error");
                this.waitingForOrder = false;
            }
        }


    }


    showToast(title, message, variant) {
        console.log('Stripe:::::event toast');


        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant

            })
        );

    }


    async createPayments(rid) {
        this.waitingForOrder = true;
        this.rid = rid;
        console.log('rid===' + rid);
        console.log('cardMethods===' + this.cardMethods);
        console.log('orderPaymentDetails===' + this.orderPaymentDetails);
        try {
            let result = await getPaymentsOnOrderPaymentSummary({ ordRefNumber: (this.orderPaymentDetails).paymentSummaryId, methods: this.cardMethods })

            if (result.error) {
                console.log('stripe::handlePayment::getPaymentsOnOrderPaymentSummary()::error =' + JSON.stringify(result.error));

                console.log('stripe::handlePayment::authorizePayment()::error =' + JSON.stringify(result.error));
                //  this.showToast("Error", (result.error).message, "error");
                this.waitingForOrder = false;

            } else {
                console.log('result getPaymentsOnOrderPaymentSummary' + JSON.stringify(result));
                this.waitingForOrder = false;
                this.updateIntentWithOrderNumber();
                this.navigateToOrderConfirmation(this.rid);

            }


        }
        catch (error) {
            // this._shouldDisablePlaceOrder = false;
            console.log('stripe::handlePayment::getPaymentsOnOrderPaymentSummary()::error =' + JSON.stringify(error));
            // this.showToast("Error", error.message, "error");
            this.waitingForOrder = false;
        }


    }


    updateIntentWithOrderNumber() {
        updatePaymentIntent({ intentArray: this.paymentIntentArray, orderNumber: this.rid })
            .then(result => {
                console.log('result updateIntentWithOrderNumber' + JSON.stringify(result));

            })
            .catch(error => {
                console.log('stripe::::updateIntentWithOrderNumber()::error =' + JSON.stringify(error));
                // this.showToast("Error", result.message, "error");
            })
    }
    /**
      * @description navigate to the order confirmation page
      * @param {String} orderNumber
      */
    navigateToOrderConfirmation(orderNumber) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Order',
            },
            state: {
                orderNumber: orderNumber,
            }
        });
    }
    @track paymentIntentMethodMap = [];


    getPaymentMethodMap() {
        this.paymentIntentMethodMap = [];
        for (let i = 0; i < this.paymentIntentArray.length; i++) {
            let idMethod = JSON.parse(this.paymentIntentArray[i]).payment_method;
            getPaymentMethod({ paymentMethodId: idMethod })
                .then(result => {
                    console.log('result getPaymentMethodMap' + JSON.stringify(result));
                    console.log('result getPaymentMethodMap' + (JSON.parse(result)).type);
                    // console.log('result getPaymentMethodMap' + (JSON.parse(result)).card.last4);
                    console.log('result getPaymentMethodMap' + JSON.parse(this.paymentIntentArray[i]).amount);
                    if ((JSON.parse(result)).type === 'affirm') {
                        this.paymentIntentMethodMap.push({ type: (JSON.parse(result)).type, amount: (JSON.parse(this.paymentIntentArray[i]).amount) / 100, affirm: true });
                    }
                    else {
                        this.paymentIntentMethodMap.push({ type: (JSON.parse(result)).type, last: (JSON.parse(result)).card.last4, amount: (JSON.parse(this.paymentIntentArray[i]).amount) / 100, affirm: false });
                    }
                    console.log('paymentIntentMethodMap==' + JSON.stringify(this.paymentIntentMethodMap));

                })
                .catch(error => {
                    console.log('stripe::::getPaymentMethodMap()::error =' + JSON.stringify(error));
                    // this.showToast("Error", result.message, "error");
                })
        }
        console.log('paymentIntentMethodMap==' + this.paymentIntentMethodMap);
        console.log('paymentIntentMethodMap==' + JSON.stringify(this.paymentIntentMethodMap));

        return this.paymentIntentMethodMap;

    }
    allowAffirm = false;
    _installationFee = 0.0;
    memberInstallationFee = 0.0;
    protectionPlanFee = 0.0;
    totalServiceAmount = 0.0;
    deliveryfee = 0.0;
    partsShipFee = 0.0;
    partsShipFeeMember = 0.0;
    partsShipOptions;
    protectionPlanFeemember = 0.0;
    async installationFeeServices(cartId) {
        try {
            this.totalServiceAmount = 0.0;
            const result = await bwc_getRelatedCartItemAll({ itemId: cartId, isMember: this.isMember, zipCode: this.zipCode });
            console.log('data Total Install====', JSON.stringify(result));
            this._installationFee = result.totalFee;
            //this.memberInstallationFee = result.memberTotalFee;
            this.memberInstallationFee = result.installationFeeForMember;
            this.protectionPlanFee = result.protectionPlanTotal;
            this.protectionPlanFeemember = result.protectionPlanForMember;
            //  this.partsShipFee=result.partsShipFeeTotal;
            //this.partsShipFeeMember=result.partsShipFeeMemberTotal
            console.log("@@@_installationFee", this._installationFee);
            console.log("@@@memberInstallationFee", this.memberInstallationFee);
            console.log("@@@protectionPlanFeemember", this.protectionPlanFeemember);

            console.log("@@@protectionPlanFee", this.protectionPlanFee);
            console.log("@@@partsShipFee", this.partsShipFee);
            console.log("@@@partsShipFeeMember", this.partsShipFeeMember);

            if (localStorage.getItem('checkoutProducts')) {
                this.localStorageProducts = JSON.parse(localStorage.getItem('checkoutProducts'));
                this.partsShipOptions = this.localStorageProducts.partsShipOptions;
                this.deliveryfee = this.localStorageProducts.deliveryfee;
                console.log('this.deliveryfee ==' + this.deliveryfee);
            }
            if (localStorage.getItem('partsFee')) {
                if (this.partsShipOptions.length !== 0) {
                    this.partsShipFee = parseFloat(localStorage.getItem('partsFee'));

                }



                console.log('this.partsShipFee ==' + this.partsShipFee);
            }

            if (this.partsShipOptions.length !== 0 && this.partsShipFee) {

                if (this.partsShipFee === this.partsShipOptions.find(record => record.value === 'Standard_Shipping').additionalParam && this.isMember === true) {
                    this.partsShipFeeMember = 0.0;
                }
                else {
                    this.partsShipFeeMember = this.partsShipFee;
                }

            }

            console.log('this.isMember ==' + this.isMember);
            if (this.isMember) {
                this.totalServiceAmount = parseFloat(this.memberInstallationFee) + parseFloat(this.protectionPlanFeemember) + parseFloat(this.partsShipFeeMember);

            }
            else {
                //  this.totalServiceAmount = this.totalServiceAmount + parseFloat(this.deliveryfee);
                this.totalServiceAmount = parseFloat(this.protectionPlanFee) + parseFloat(this._installationFee) + parseFloat(this.deliveryfee) + parseFloat(this.partsShipFee);

            }

            console.log("@@@subTotal", this.subTotal);
            console.log("@@@totalServiceAmount", this.totalServiceAmount);



            if (this.isMember) {
                if (this.protectionPlanFee > 0) {
                    this.allowAffirm = true
                }
            }
            else {

                if (this.protectionPlanFee > 0) {
                    this.allowAffirm = true
                }

            }
            console.log('allowAffim===' + this.allowAffirm);
            // await this.handleMemberSavings2();
            // this.publishMessage();
        } catch (error) {
            console.log('error===', JSON.stringify(error));
            throw error;
        }
    }
    //abhishek
    updateBillingAddressEBS() {
        checkAndHitUpdateConsumer()
            .then(result => {
                console.log("Billing address--> " + result);
            })
            .catch(error => {
                console.log(" this.result.error===", error);
            })
    }

}