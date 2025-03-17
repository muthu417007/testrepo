import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import BASE_PATH from '@salesforce/community/basePath';
// Guest flag
import IS_GUEST from '@salesforce/user/isGuest'; //Srini- Added to check whther logged-in user is guest or not

export default class BWC_GuestProductRegistartion extends NavigationMixin(LightningElement) {

    @api brand = 'Bodewell';
    @api nonGuestUrl = '/mya-product-registration';
    isGuest = IS_GUEST;
    basePath = BASE_PATH;

    @wire(CurrentPageReference)
    currentPageReference;

    connectedCallback() {
        let view = this.currentPageReference.state.view;
        let isEditor = view ? view.indexOf('editor') == -1 ? false : true : false;
        console.log('isEditor: ',isEditor);
        if (!this.isGuest && !isEditor) {
            this.redirectLink = this.basePath + this.nonGuestUrl;
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: this.redirectLink
                }
            });
        }
    }
}