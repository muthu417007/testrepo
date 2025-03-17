import { api, LightningElement } from 'lwc';

export default class Cx_matchCaseContactItem extends LightningElement {
    @api contact;
    @api disableLink = false;

    handleContactClick() {
        this.dispatchEvent(new CustomEvent('contactclick', { detail: this.contact.Id }))
    }

    handleMatchClick() {
        this.dispatchEvent(new CustomEvent('matchclick', { detail: this.contact.index }))
    }

    get isExternalContact() {
        return !this.contact.Id;
    }

    get disableLinkClick() {
        return this.isExternalContact || this.disableLink;
    }
}