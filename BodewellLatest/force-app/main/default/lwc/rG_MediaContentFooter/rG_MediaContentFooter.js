import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubsub';

export default class RG_MediaContentFooter extends LightningElement {
    @api hideContent = false;
    connected = false;
    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        registerListener('mediaContentEnabled', this.handleEvent, this);
        if (!this.connected) {
            fireEvent(this.pageRef, 'mediaContentEnabledCallBack', true);
        }
        this.connected = true;
    }

    handleEvent(inpVal) {
        this.hideContent = inpVal;
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }
}