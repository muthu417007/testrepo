import { LightningElement, api } from 'lwc';
export default class Bwc_WillCallShippingModelAgree extends LightningElement {
    @api isPickupModal;
    @api isTNC = false;
    openTNC() {
        this.isTNC = true;
        this.isPickupModal = false;
    }
    openPickUpModel() {
        this.isTNC = false;
        this.isPickupModal = true;
    }
    connectedCallback() {
        console.log('inside model console connected callback');
    }
}