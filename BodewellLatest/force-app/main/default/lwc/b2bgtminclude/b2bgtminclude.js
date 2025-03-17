import { api, LightningElement, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import Is_Guest from '@salesforce/user/isGuest';
import getProductType from '@salesforce/apex/BWC_GtmInfoHelper.getProductType';

export default class b2bgtminclude extends LightningElement {

    @api gtmCode;
    userId = USER_ID;
    isGuest = Is_Guest;
    connected = false;
    isProduct = false;
    objectApi;
    objectPageTypes = [
        { key: 'ProductCategory', type: 'Category' },
        { key: 'OrderSummary', type: 'Order Summary' },
        { key: 'Product2', type: 'Product' }
    ];
    pageType;
    productType;
    infoLoaded = false;
    productId;
    searchpage = false;

    get iframeSrc() {
        return `<iframe src="https://www.googletagmanager.com/ns.html?id=${this.gtmCode}" height="0" width="0" style="display: none; visibility: hidden"></iframe>`;
    }

    @wire(CurrentPageReference)
    getStateParameters(e) {
        this.url = window.location.href;
        if (e.attributes.name) {
            this.title = e.attributes.name;
            this.title = this.title.replaceAll('__c', '');
            this.title = this.title.replaceAll('_', ' ');
        }
        if(e.type == 'standard__search') {
            this.searchpage = true;
        }
        if (e.attributes.objectApiName) {
            this.objectApi = e.attributes.objectApiName;
        }
        if(e.attributes.recordId)
        {            
            this.productId = e.attributes.recordId;
        }    
    }

    connectedCallback() {
        this.connected = true;
        this.gtmPageView();
    }

    gtmPageView() {
        if (this.objectApi) {
            this.pageType = this.objectPageTypes.find(item => item.key == this.objectApi).type;
        } else if (this.title.toLowerCase().indexOf('mya') > -1) {
            this.pageType = 'MY Account';
        } else if (this.title.toLowerCase().indexOf('cart') > -1) {
            this.pageType = 'Cart';
        } else if (this.title.toLowerCase().indexOf('checkout') > -1) {
            this.pageType = 'Checkout';
        } else if (this.title.toLowerCase().indexOf('checkout') > -1) {
            this.pageType = 'Checkout';
        } else {
            this.pageType = this.searchpage ? 'Search' : this.title;
        }
        if (this.pageType == 'Product' && !this.infoLoaded) {
            this.getProductInfo(this.productId);
        } else {
            let gtm__pageView = new CustomEvent(
                'gtm__pageView', {
                detail: {
                    userId: this.userId,
                    loggedIn: !this.isGuest,
                    productType: this.productType,
                    pageType: this.pageType,
                    storeType: undefined,
                    storeId: undefined,
                    bcPage: undefined
                }
            });
            document.dispatchEvent(
                gtm__pageView, {
                bubbles: true,
                composed: true
            });
        }
    }

    getProductInfo(input) {
        getProductType({ productId: input })
            .then(response => {
                if (response.success) {
                    this.productType = response.data;
                }
                this.infoLoaded = true;
                this.gtmPageView();
            }).catch(error => {
                console.error('error : ', error);
            });
    }
}