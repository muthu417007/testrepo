import { LightningElement,api } from 'lwc';

export default class Bwc_bazaarvoicePDPRatingSummary extends LightningElement {    INSERT_PRODUCT_ID;
    _productDetails;
  @api
  get product() {
    return this._productDetails;
  }
  set product(val) {
    this._productDetails = val;
 
    if(val)
    {
      this.INSERT_PRODUCT_ID=val?.fields?.StockKeepingUnit;
    }
}


}