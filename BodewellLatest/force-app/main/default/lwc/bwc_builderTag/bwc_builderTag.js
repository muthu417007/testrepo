import { LightningElement, api, wire } from 'lwc';
import getProductInformation from '@salesforce/apex/BWC_TagController.getProductInformation';

export default class bwc_builderTag extends LightningElement {
    /**
     * @description The product object cont aining details about the product.
     * @type {?object}
     */
    _product;
    _productIds;

    @api
    get product() {
        return this._product;
    };
    set product(value) {
        if (value) {
            this._product = value;
            this._productIds = [value.id];
        }
    }

    /**
     * @description returned from the User expression
     * @type {?list}
     */
    @api
    buyerGroupNames;

    /**
     * @description The color code for the sale banner.
     * @type {?string}
     */
    @api
    saleBannerColor;

    /**
     * @description The color code for the clearance banner.
     * @type {?string}
     */
    @api
    clearanceBannerColor

    /**
     * @description Indicates if the component is on the PDP or not - it is set to true since this component is
     * currently designed to work only on the PDP.
     * @type {boolean}
     */
    get isOnPDP() {
        return true;
    }

    /**
     * @description Indicates if the product is on sale or not.
     * @type {boolean}
     * @private
     */
    _isOnSale = false;

    /**
     * @description Indicates if the product is on clearance or not.
     * @type {boolean}
     * @private
     */
    _isOnClearance = false;

    /**
     * @description Gets the value indicating if the product is on sale.
     * @return {boolean}
     * @readonly
     */
    get isOnSale() {
        return this._isOnSale;
    }

    /**
     * @description Gets the value indicating if the product is on clearance.
     * @return {boolean}
     * @readonly
     */
    get isOnClearance() {
        return this._isOnClearance;
    }

    /**
     * @description Retrieves the products on sale or clearance by calling the Apex method, taking into consideration
     * the buyer group names, and sets the isOnClearance and isOnSale property.
     * If there's an error in fetching the data, it logs the error message.
     *
     * @param {object} result The result object containing data and error information.
     * @private
     */
    @wire(getProductInformation, { buyerGroupNames: '$buyerGroupNames', productIds: '$_productIds' })
    wiredGetProductInfo({ error, data }) {
        if (data) {
            this._isOnClearance = data.clearance.includes(this.product.id);
            this._isOnSale = data.sale.includes(this.product.id);
        } else if (error) {
            console.error(`bwc_builderTag::wiredGetProductInfo::Error fetching product information::error = ${error}`);
        }
    }
}