import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import { Labels } from './labels';

/**
 * @description Handles the communications between the Cybersource Hosted Payment Page and the bwc_cybersourceHPP component
 * This component hosts the IFRAME and listens for messages from the Visual Force page that is in the IFRAME.
 * When a message is received, it is parsed and the appropriate action is taken.
 */
export default class bwc_cybersourceHPPModal extends LightningModal {
    // This is the URL that is hosted in the IFRAME
    @api
    iframe_url;

    // The parameters to send to the Visual Force page
    @api
    params;

    // Text displayed in modal header area: "Enter Payment Information" or "Payment Processing"
    _headerLabel = Labels.paymentHeaderText;

    // Set up a listener for messages from the VF Page in the IFRAME
    _listenerAdded;

    connectedCallback() {
        if (!this._listenerAdded) {
            window.addEventListener('message', this.handleMessage.bind(this));
            this._listenerAdded = true;
        }
    }

    disconnectedCallback() {
        if (this._listenerAdded) {
            window.removeEventListener('message', this.handleMessage.bind(this));
            this._listenerAdded = false;
        }
    }

    _showSpinner = true;

    /**
     * @description Handle the message received from the IFRAME
     * There are 2 types of messages that are expected:
     * 1. REQUEST_PAGE_LOADED
     *     This message is sent when the IFRAME is loaded.
     * 2. CYBERSOURCE_RESPONSE
     *     This message is sent when the payment is completed.
     *     The message contains the payment information.
     * @private
     * @param {Object} Message
     * @oaram {Object} Message.data
     * @param {Object} Message.source
     * @param {String} Message.origin
     * @returns {void}
     */
    handleMessage({data, source, origin}) {
        const {event, payload} = data;
        const allowedOrigin = this.getAllowedOrigin();
        if (origin !== allowedOrigin) {
            return;
        }
        if (event === 'REQUEST_PAGE_LOADED') {
            // Stop the spinner and send a message to the VF Page containing
            // the parameters needed for the Hosted Payment Page
            this._showSpinner = false;
            source.postMessage({...this.params}, '*');
        }
        if (event === 'CYBERSOURCE_RESPONSE') {
            this.close(payload);  // close the modal and return the payment information
        }
    }

    /**
     * @description Get the origin of the IFRAME
     * @private
     * @returns {String}
     */
    getAllowedOrigin() {
        let parts = this.iframe_url.split('/');
        let host = parts[2];
        return `https://${host}`;
    }
}