import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import BASE_PATH from '@salesforce/community/basePath';

export default class BWC_ProdRegGuestLogin extends LightningElement {
    
    @api guestRegLink = '/mya-guest-product-registration';    
    guestRegURL;
    basePath = BASE_PATH;
    isProdReg = false;

    @wire(CurrentPageReference)
    currentPageReference;

    connectedCallback() {
        console.log('prodReg: ', this.currentPageReference);
        if(this.currentPageReference.state.startURL == this.basePath + '/mya-product-registration') {
            this.isProdReg = true;
            this.guestRegURL = this.basePath + this.guestRegLink;
        }
    }
}