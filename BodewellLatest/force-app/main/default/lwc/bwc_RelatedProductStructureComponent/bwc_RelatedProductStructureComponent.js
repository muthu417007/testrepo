import { LightningElement, api, wire ,track } from 'lwc';
import { ProductAdapter, ProductPricingAdapter } from 'commerce/productApi';
import { generateUrl, navigate, NavigationContext } from 'lightning/navigation';


export default class Bwc_RelatedProductStructureComponent extends LightningElement {
    @api productId;
    @track productImageUrl;
    @track productPrice;
    @track productDescription;
    @track productSku;
    @track productRating;

    _navigationContext;
    @track _productUrl;

    @wire(NavigationContext)
    wiredNavigationContext(context) {
        this._navigationContext = context;
        this.updateCallToActionButtonUrl();
    }

    @wire(ProductAdapter, { productId: '$productId' })
    ProductAdapterMethod({ error, data }) {
        if (data) {
            console.log('relatedProductStructureData->', data);
            this.productImageUrl = data.fields.BWC_Main_Image__c;
            this.productRating = data.fields.BWC_Rating__c;
            this.productSku = data.fields.StockKeepingUnit
            this.productDescription = data.fields.BWC_Product_Marketing_Description__c
        }
        else {
            console.log('relatedProductStructureError->', error);
        }
    }

    @wire(ProductPricingAdapter, { productId: '$productId' })
    ProductPricingAdapterMethod({ error, data }) {
        if (data) {
            console.log('ProductPricingAdapter data-->', data);
            this.productPrice = data.unitPrice;
        }
        else {
            console.log('error pricing-->', error);
        }
    }

    updateCallToActionButtonUrl() {
        if (this._navigationContext && this.productId) {
            this._productUrl = generateUrl(this._navigationContext, {
                type: 'standard__recordPage',
                attributes: {
                    objectApiName: 'Product2',
                    recordId: this.productId,
                    actionName: 'view',
                },
            });
        }
    }
}