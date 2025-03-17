import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { SessionContextAdapter } from 'commerce/contextApi';
import getOrderInfo from '@salesforce/apex/BWC_CybersourceController.getOrderInfo';
import { Labels } from './labels';

/**
 * @description A component to display order confirmation message on order summary page
 */
export default class bwc_OrderConfirmation extends LightningElement {
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
            console.log(`bwc_OrderConfirmation::wireSessionContext::error = ${JSON.stringify(error, null, 2)}`);
        }
    }
/**
 * @description this is used to show component on builder
 */
    _waitingForOrder;
    get waitingForOrder() {
        return this._sessionContext?.isPreview ? false : this._waitingForOrder;
    }
    set waitingForOrder(value) {
        this._waitingForOrder = value;
    }

    /**
     * @description The header text e.g., "Your order #### has been placed."
     * @returns {string}
     */
    get orderMessageText() {
        return Labels.orderMessageText(this._sessionContext?.isPreview ? 'BWC-05634563' : this._orderNumber );
    };

    /**
     * @description The text for email message. e.g. "We sent an email to XXXX.com containing information about your order."
     * @type {string}
     */
    get emailMessageText() {
        return Labels.emailMessageText(this._sessionContext?.isPreview ? 'johndoe@acme.com' : this._email);
    }

    _orderReferenceNumber;
    _orderNumber = '';
    _email = '';

    /**
     * @description Get the current page reference to extract query parameter "orderNumber"
     */
    @wire(CurrentPageReference)
    getCurrentPageRef({state}) {
        if (state?.orderNumber) {
            this._orderReferenceNumber = state.orderNumber;
        }
    }

    /**
     * @description Get the order info from the server
     * @async
     * @returns {Promise<void>}
     * @param {String} orderReferenceNumber - this is the long order number that is generated from placeOrder
     */
    @wire(getOrderInfo, {orderNumber: '$_orderReferenceNumber'})
    wiredGetOrderInfo({data, error}) {
        this.waitingForOrder = true;
        if (data) {
            if (data.orderNumber && data.email) {
                this._orderNumber = data.orderNumber;
                this._email = data.email;
                this.waitingForOrder = false;
            } else {
                this._orderReferenceNumber = this._orderReferenceNumber + ' ';
            }
        } else if (error) {
            console.log(`bwc_OrderConfirmation::wiredGetOrderInfo::error: ${JSON.stringify(error)}`);
        }
    }
}