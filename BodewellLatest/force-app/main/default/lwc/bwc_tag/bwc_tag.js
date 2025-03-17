import { LightningElement, api } from 'lwc';
import { Labels } from './labels';

export default class bwc_tag extends LightningElement {
    /**
     * @description Indicates if the component is used on PDP.
     * @type {boolean}
     * @default false
     */
    @api
    isOnProductDetailPage;

    /**
     * @description Indicates whether the product is on sale.
     * @type {?boolean}
     */
    @api
    isOnSale;

    /**
     * @description Indicates whether the product is on clearance.
     * @type {?boolean}
     */
    @api
    isOnClearance;

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
    clearanceBannerColor;

    get saleLabel() {
        if (this.isOnProductDetailPage) {
            return Labels.saleTag;
        }
        return Labels.onSaleTag;
    }

    get clearanceLabel() {
        return Labels.clearanceTag;
    }

    /**
     * @description Computes the CSS style for the sale banner based on the saleBannerColor property.
     * Falls back to 'defaultColor' if saleBannerColor is not provided.
     * @type {string}
     * @readonly
     * @private
     */
    get saleBannerStyle() {
        return `background-color: ${this.saleBannerColor || 'defaultColor'};`;
    }

    /**
     * @description Computes the CSS style for the clearance banner based on the clearanceBannerColor property.
     * Falls back to 'defaultColor' if clearanceBannerColor is not provided.
     * @type {string}
     * @readonly
     * @private
     */
    get clearanceBannerStyle() {
        return `background-color: ${this.clearanceBannerColor || 'defaultColor'};`;
    }
}