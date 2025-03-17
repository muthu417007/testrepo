import { LightningElement, wire, api } from 'lwc';
import { SessionContextAdapter } from 'commerce/contextApi';
import getParameters from '@salesforce/apex/BWC_CybersourcePOCController.getParameters';

export default class bwc_cybersourcePOC extends LightningElement {

    sessionContext;
    @wire(SessionContextAdapter) // <-- design-time only
    wireSessionContext({ data }) {
        this.sessionContext = data;
    }

    parametersValues;

    @wire(getParameters)
    wiredGetParameters({data, error}) {
        if (error) {
            console.log('wiredGetParameters()::error' + JSON.stringify(error, null, 2));
        } else {
            this.parametersValues = [];
            for(let key in data) {
                this.parametersValues.push({
                    key: key,
                    value: data[key]
                });
            }
        }
    }

    _checkoutDetails;
    @api
    get checkoutDetails() {
        if (this.sessionContext?.isPreview) {
            return 'Checkout details should appear here';
        } else {
            return this._checkoutDetails;
        }
    };
    set checkoutDetails(value) {
        console.log(`checkoutDetails: ${value}`);
        this._checkoutDetails = value;
    }

    _paymentInfo;
    get paymentInfo() {
        if (this.sessionContext?.isPreview) {
            return 'Payment details should appear here';
        } else {
            return this._paymentInfo;
        }
    }
    set paymentInfo(value) {
        this._paymentInfo = value;
    }

    listenerAdded;
    connectedCallback() {
        if (!this.listenerAdded) {
            if (window.addEventListener) {
                console.log('bwc_CybersourcePayment::window.addEventListener');
                window.addEventListener('message', this.handleMessage.bind(this));
            }
        }
    }

    disconnectedCallback() {
        if (this.listenerAdded) {
            console.log('bwc_CybersourcePayment::window.removeEventListener');
            window.removeEventListener('message', this.handleMessage.bind(this));
        }
    }

    handleMessage(message) {
        if (!this.sessionContext?.isPreview) {
            this.paymentInfo = JSON.stringify(message.data, null, 2);
            console.log(`bwc_CybersourcePayment::message.data = ${this.paymentInfo}`);
        }
    }

    submitForm() {
      let win = window.open('', '_cybersourcePayment');
      this.template.querySelector('form').submit();
    }
}