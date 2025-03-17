import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { SessionContextAdapter } from 'commerce/contextApi';
import { CartSummaryAdapter } from 'commerce/cartApi';
import { placeOrder } from 'commerce/checkoutApi';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import ToastContainer from 'lightning/toastContainer';
import cyberSourceModal from 'c/bwc_cybersourceHPPModal';
import getParameters from '@salesforce/apex/BWC_CybersourceController.getParameters';
import authorizePayment from '@salesforce/apex/BWC_CybersourceController.authorizePayment';

import calculateTotalAmount from '@salesforce/apex/BWC_CalculateEntirePrice.calculateTotalAmount';

import logError from '@salesforce/apex/BWC_CybersourceController.logError';
import { Labels } from './labels';
import { subscribe, unsubscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import CHECKOUT_CHANNEL from '@salesforce/messageChannel/BWC_Checkout__c';


/**
 * @description The main LWC component for payment processing with Cybersource HPP
 * This component is meant to be used on the checkout page of an LWR site and displays
 * a modal window (separate lwc component) that hosts a Visual Force page that in turn hosts the Cybersource
 * hosted payment page within an IFRAME.
 *
 * INTERACTION:
 *   LWC --> LWC MODAL --> IFRAME --> Visual Force --> Cybersource HPP
 *
 *   This component expects a result from the modal that indicates the Cybersource payment response information
 *   or if the yser cancelled the payment.
 *
 * "checkoutDetails" Property:
 *   This component exposes a public property named "checkoutDetails" to the builder in order to use data binding.
 *   The checkout page will pass data to this component through this property multiple times as part of the checkout flow.
 */
export default class bwc_cybersourceHPP extends NavigationMixin(LightningElement) {

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
        } else if (error) {
            console.log(`bwc_cybersourceHPP::wireSessionContext::error = ${JSON.stringify(error, null, 2)}`);
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

    // getServiceCharge(cartId){
    //     calculateTotalAmount({cartId:cartId})
    //     .then(result=>{
    //         console.log('ServiceResult-->'+result);
    //         this.serviceAmount = result;
    //     })
    //     .catch(error=>{
    //         console.log('error in CalculateEntirePrice apex class-->'+error);
    //     })
    // }

    @wire(CartSummaryAdapter)
    wireCartSummary({ data, error }) {
        if (data) {
            console.log('cartSummaryAdapter-->',data);
           // this.getServiceCharge(data.cartId);
            //console.log('service amt in Adapter-->'+this.serviceAmount);
           // if(this.serviceAmount===undefined || this.serviceAmount === null){
            //  this.serviceAmount = 0;     
           // }
            // const grandAmount = parseFloat(data.grandTotalAmount)+this.serviceAmount;
            // console.log('grandAmount-->'+grandAmount);
            this._cartSummary = data;
            this._cartSummaryJSON = JSON.stringify({
                "grandTotalAmount": data.grandTotalAmount,
                "totalTaxAmount": data.totalTaxAmount,
                "cartId": data.cartId,
                "currencyIsoCode": data.currencyIsoCode,
            });
        } else if (error) {
            console.log(`bwc_cybersourceHPP::wireCartSummary::error = ${JSON.stringify(error, null, 2)}`);
        }
    }

    /**
    * @description By providing this checkoutDetails property we are participating in the checkout flow and will be notified of checkout events.
    * @example
    * { "checkoutStatus": 200, "checkoutId": "2z98B000000ChG7QAK", "deliveryGroups": { "items": [ { "id": "0a78B00000009N6QAI", "deliveryAddress": { "city": "Louisville", "companyName": "", "country": "US", "firstName": "NEW", "lastName": "ADDRESS_CHECK", "name": "NEW  ADDRESS_CHECK", "postalCode": "40222", "region": "KY", "street": "120N, new address" }, "availableDeliveryMethods": [ { "carrier": "Test Carrier 1", "classOfService": "SNC9600", "currencyIsoCode": "USD", "id": "2Dm8B000000Gq3SSAS", "name": "Delivery Method 1", "shippingFee": "11.99" }, { "carrier": "Test Carrier 2", "classOfService": "SNC9600", "currencyIsoCode": "USD", "id": "2Dm8B000000Gq3TSAS", "name": "Delivery Method 2", "shippingFee": "15.99" } ], "selectedDeliveryMethod": { "carrier": "Test Carrier 1", "classOfService": "SNC9600", "currencyIsoCode": "USD", "id": "2Dm8B000000Gq3SSAS", "name": "Delivery Method 1", "shippingFee": "11.99" } } ] }, "errors": [], "notifications": [], "formStatus": { "clean": true, "dirty": false, "incongruent": false, "useShippingAddressForBilling": true }, "display": { "hidePlaceOrderButton": false }, "contactInfo": { "email": "madhavi.dharanikota@geappliances.com", "phoneNumber": "" }, "billingInfo": { "address": { "city": "Louisville", "companyName": "", "country": "US", "firstName": "NEW", "lastName": "ADDRESS_CHECK", "name": "NEW  ADDRESS_CHECK", "postalCode": "40222", "region": "KY", "street": "120N, new address" }, "email": "madhavi.dharanikota@geappliances.com" } }
    */
    _checkoutDetails;
    _shouldDisablePlaceOrder = true;  // Controls if the "Place Order" button is disabled or not

    @api
    get checkoutDetails() {
        return this._checkoutDetails;
    }
    set checkoutDetails(value) {
        if (value) {
            console.log('bwc_cybersourceHPP::getShouldDisablePlaceOrder::set checkoutDetails: ' + JSON.stringify(value, null, 2));
            this._checkoutDetails = value;
        }
    }

    @wire(MessageContext)
    messageContext;

    subscription;

    /**
     * @description This method is used to initialize the toastContainer
     * @return {void}
     */
    connectedCallback() {
        const toastContainer = ToastContainer.instance();
        toastContainer.toastPosition = 'top-center';
        this.subscription =
        subscribe(
            this.messageContext,
            CHECKOUT_CHANNEL,
            (message) => this.handleMessage(message),
            { scope: APPLICATION_SCOPE }
        );
    }

    // disconnectedCallback(){
    //     unsubscribe(this.subscription);
    //      this.subscription = null;
    // }

    handleMessage(data) {
        console.log('bwc_cybersourceHPP::handleMessage::data=' + JSON.stringify(data, null, 2));
        if (data?.enablePlaceOrder) {
            this._shouldDisablePlaceOrder = false;
        }
    }

    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    _parameters; // Holds the set of parameters to be passed to the Cybersource Hosted Payment Page

    /**
     * @description Display a modal window with a form to enter the payment information into Cybersource
     * @returns {void}
     */
    handlePlaceOrderClick() {
        if (localStorage.getItem('serviceAmount')) {
            this.serviceAmount = localStorage.getItem('serviceAmount');
            console.log('this.serviceLOcalAmount===' + this.serviceAmount);
        }
        if(this.serviceAmount == undefined || this.serviceAmount == null){
            this.serviceAmount = 0;
        }
        let cartSummaryObject = JSON.parse(this._cartSummaryJSON);
        console.log('cartSummaryobject-->',cartSummaryObject);
        cartSummaryObject.grandTotalAmount = JSON.stringify(parseFloat(cartSummaryObject.grandTotalAmount) + parseFloat(this.serviceAmount));
        console.log('cartSummaryobjectAfterUpdate-->',cartSummaryObject);
        this._cartSummaryJSON = JSON.stringify(cartSummaryObject);
        console.log('cartSummaryJson-->',this._cartSummaryJSON);

        getParameters({
            accountId: this._sessionContext.effectiveAccountId,
            cartSummary: this._cartSummaryJSON
        })
        .then(data => {
            console.log('bwc_cybersourceHPP::getParameters()::data = ' + JSON.stringify(data, null, 2));
            this._parameters = {...data};
            delete this._parameters.iframe_url;
            return data.iframe_url;
        })
        .then((iframe_url) => {
            cyberSourceModal.open({
                size: 'small',
                iframe_url,
                params: this._parameters
            }).then(paymentInfo => {
                // The paymentInfo variable will be undefined if the user clicks the "x" button to close the form
                // otherwise a payment response from Cybersource was returned
                if (paymentInfo) {
                    this.handlePayment(paymentInfo);
                }
            });
        })
        .catch(error => {
            console.log('bwc_cybersourceHPP::getParameters()::error = ' + JSON.stringify(error, null, 2));
        })
    }

    /**
     * @description contains the payment information returned by Cybersource
     * @example
     * { "utf8": "✓", "transaction_id": "6969762034446801004005", "signed_field_names": "transaction_id,decision,req_access_key,req_profile_id,req_transaction_uuid,req_transaction_type,req_reference_number,req_amount,req_tax_amount,req_currency,req_locale,req_payment_method,req_override_custom_receipt_page,req_override_custom_cancel_page,req_bill_to_forename,req_bill_to_surname,req_bill_to_email,req_bill_to_address_line1,req_bill_to_address_city,req_bill_to_address_state,req_bill_to_address_country,req_bill_to_address_postal_code,req_card_number,req_card_type,req_card_type_selection_indicator,req_card_expiry_date,card_type_name,req_merchant_defined_data1,req_merchant_defined_data4,message,reason_code,auth_avs_code,auth_avs_code_raw,auth_response,auth_amount,auth_code,auth_trans_ref_no,auth_time,request_token,payment_token,signed_field_names,signed_date_time", "signed_date_time": "2023-10-10T22:16:43Z", "signature": "5Ck0YYvmRkQu8cAf9Pf/PBW2+yxXqmSiub8L+ivOW5Q=", "request_token": "Axj/7wSTedTg6vKNc2XlABsZPaOLTKdJoz6camnvuvY8A4EnvuvY8A+kDvhszThk0kyxdfA9zCBSTedTg6vKNc2XlAAAlx39", "req_transaction_uuid": "3f635809-aadc-add5-0463-afa130df2cb5", "req_transaction_type": "authorization,create_payment_token", "req_tax_amount": "0.00", "req_reference_number": "0a68B0000000B79QAE-1381", "req_profile_id": "FC11F2FC-5A46-4CED-90BF-5C5946498F4B", "req_payment_method": "card", "req_override_custom_receipt_page": "https://geapp--bwcommoob.sandbox.my.salesforce-sites.com/bcybersourceresponse", "req_override_custom_cancel_page": "https://geapp--bwcommoob.sandbox.my.salesforce-sites.com/bcybersourceresponse", "req_merchant_defined_data4": "Domain URL", "req_merchant_defined_data1": "BodeWell Store", "req_locale": "en", "req_currency": "USD", "req_card_type_selection_indicator": "1", "req_card_type": "002", "req_card_number": "xxxxxxxxxxxx1113", "req_card_expiry_date": "09-2027", "req_bill_to_surname": "User 1", "req_bill_to_forename": "Member", "req_bill_to_email": "shubhadaprakash.kurumkar@geappliances.com", "req_bill_to_address_state": "WI", "req_bill_to_address_postal_code": "41114", "req_bill_to_address_line1": "781 Orphan Road", "req_bill_to_address_country": "US", "req_bill_to_address_city": "Green Bay", "req_amount": "158.99", "req_access_key": "e90c2411c92a3a958c02ce260f1664d5", "reason_code": "100", "payment_token": "9909000392307008", "message": "Request was processed successfully.", "decision": "ACCEPT", "card_type_name": "Mastercard", "auth_trans_ref_no": "O48Z2NIQOSFS", "auth_time": "2023-10-10T221643Z", "auth_response": "00", "auth_code": "831000", "auth_avs_code_raw": "Y", "auth_avs_code": "Y", "auth_amount": "158.99" }
     */
    _paymentInfo;

    /**
     * @description This method is called when the payment information is returned from Cybersource.
     * This method contains the logic to determine if the order can be created, or if there was an error creating the payment
     * @param {Object} paymentInfo - The payment information returned by the Cybersource modal form
     * @returns {void}
     */
    async handlePayment(paymentInfo) {
        this._paymentInfo = paymentInfo;

        if (this._paymentInfo.reason_code === '100') {
            this._shouldDisablePlaceOrder = true;
            this.showNotification(Labels.paymentNotificationTitle, Labels.paymentNotificationMessage, 'info');
            authorizePayment({ strPaymentRecord: this.buildPaymentRecord() })
            .then(() => {
                return placeOrder();
            })
            .then(result => {
                // result should look like this: { "errors": [], "orderReferenceNumber": "2ADMS-IXH45-FULN6-BYD5W" }
                this.navigateToOrderConfirmation(result.orderReferenceNumber);
            })
            .catch(error => {
                this._shouldDisablePlaceOrder = false;
                console.log(`bwc_cybersourceHPP::handlePayment::authorizePayment()::error = ${JSON.stringify(error, null, 2)}`);
            });
        } else {
            // Display error message in modal window
            console.log(`bwc_cybersourceHPP::handlePayment::this._paymentInfo = ${JSON.stringify(this._paymentInfo)}`);
            this.showNotification(Labels.paymentNotificationTitle, this.getConsumerFriendlyMessage(this._paymentInfo.reason_code), 'error', 'sticky');
            await logError({
                message: `Cybersource returned error code: ${this._paymentInfo.reason_code}`,
                payLoad: JSON.stringify(this._paymentInfo)
            });
        }
    }

    /**
     * @description Build the payment info object that is passed to the placeOrder() method
     * @returns {String} JSON string of the payment information to be passed to the authorizePayment() method
     */
    buildPaymentRecord() {
        return JSON.stringify({
            cartId: this._cartSummary.cartId,
            webstoreId: this._cartSummary.webstoreId,
            accountId: this._sessionContext.effectiveAccountId,
            currencyIsoCode: this._paymentInfo.req_currency,
            signed_date_time: this._paymentInfo.signed_date_time,
            request_token: this._paymentInfo.request_token,
            transaction_id: this._paymentInfo.transaction_id,
            auth_code: this._paymentInfo.auth_code,
            auth_time: this._paymentInfo.auth_time,
            payment_token: this._paymentInfo.payment_token,
            req_card_expiry_date: this._paymentInfo.req_card_expiry_date,
            req_bill_to_forename: this._paymentInfo.req_bill_to_forename,
            req_bill_to_surname: this._paymentInfo.req_bill_to_surname,
            req_bill_to_street: this._paymentInfo.req_bill_to_address_line1,
            req_bill_to_city: this._paymentInfo.req_bill_to_address_city,
            req_bill_to_state: this._paymentInfo.req_bill_to_address_state,
            req_bill_to_postal_code: this._paymentInfo.req_bill_to_address_postal_code,
            req_bill_to_country: this._paymentInfo.req_bill_to_address_country,
            req_card_type: this._paymentInfo.req_card_type,
            req_card_number: this._paymentInfo.req_card_number,
            auth_amount: this._paymentInfo.auth_amount,
            cardNumber: this._paymentInfo.req_card_number,
            card_type_name: this._paymentInfo.card_type_name,
            expiryYear: this._paymentInfo.req_card_expiry_date.split('-')[1],
            expiryMonth: this._paymentInfo.req_card_expiry_date.split('-')[0]
        });
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

    /**
     * @description Shows a toast notificaiton
     * @param {String} title - The title of the toast
     * @param {String} message - The message of the toast
     * @param {String} variant - The variant of the toast, values can be "info", "warning", "error", "success"
     * @param {String} mode - The mode of the toast, values can be "dismissible" (default) or "sticky"
     */
    showNotification(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant,
            mode
        });
        this.dispatchEvent(evt);
    }

    /**
     * @description Return a consumer friendly message
     * @param {String} reasonCode - The reason code from the payment response from the payment processor
     * @returns {String}
     * @example
     * The consumer friendly messages will be stored in a custom label as JSON.
     * The JSON structure is:
     * {
     *    "default": "Default message",
     *    "100": "Successful transaction",
     *    "101": "Invalid request"
     * }
     * If a reason code is not found in the JSON structure then the "default" is returned.
     */
    getConsumerFriendlyMessage(reasonCode) {
        const messages = JSON.parse(Labels.paymentConsumerFriendlyMessages || '{}');
        if (messages[reasonCode]) {
            return messages[reasonCode];
        } else {
            return messages['default'];
        }
    }
}