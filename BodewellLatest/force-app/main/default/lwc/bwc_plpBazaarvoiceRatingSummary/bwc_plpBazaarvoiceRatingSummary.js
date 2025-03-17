import { LightningElement, api ,wire} from 'lwc';

import { generateUrl, navigate, NavigationContext } from 'lightning/navigation';
export default class Bwc_plpBazaarvoiceRatingSummary extends LightningElement {
    recordPageUrl;
     _navigationContext;
    @wire(NavigationContext)
    wiredNavigationContext(context) {
        this._navigationContext = context;
    
    }
 
    _productId;
    @api
    get productId() {
        return this._productId;
    }
    set productId(val) {
        if (val) {
            this._productId = val;
          //  this.generateProductUrl();

            console.log(' bazaarvoice product SKU' + val);
        }

    }
      _productIdReal;
    @api
    get productIdid() {
        return this._productIdReal;
    }
    set productIdid(val) {
        if (val) {
            this._productIdReal = val;
            this.generateProductUrl();

            console.log(' bazaarvoice product SKU' + val);
        }

    }
       _productUrl;
    @api
    get productUrl() {
        return this._productUrl;
    }
    set productUrl(val) {
        if (val) {
            this._productUrl = val;
            //this.generateProductUrl();
this.recordPageUrl=this._productUrl;
            console.log(' bazaarvoice product SKU URL' + val);
        }

    }


    generateProductUrl() {
        if (this._navigationContext && this?._productIdReal) {
            this.recordPageUrl = generateUrl(this._navigationContext, {
                type: 'standard__recordPage',
                attributes: {
                    objectApiName: 'Product2',
                    recordId: this._productIdReal,
                    actionName: 'view',
                },
            });
            console.log('recordPageUrl : ',this.recordPageUrl);
        }
    }

}