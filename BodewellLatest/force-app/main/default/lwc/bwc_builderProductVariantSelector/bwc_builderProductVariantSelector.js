import { api, LightningElement, wire } from 'lwc';
import { navigate, NavigationContext } from 'lightning/navigation';
import { createProductVariantUpdateAction, dispatchAction } from 'commerce/actionApi';
import { SessionContextAdapter } from 'commerce/contextApi';
import { isVariantSupportedProductClass } from 'c/bwc_productVariantSelector';
import { variationInfo } from './designTimeData'; // <-- design-time only

/**
 * @typedef {{[key: string]: *}} JsonData
 */

/**
 * @description The BuilderProductVariantSelector class provides a component for
 * selecting product variants for a specific product.
 *
 * **Important Note:**
 *
 * This example uses a technique that can have a minimal negative impact on the runtime behavior of the component.
 * Namely, this example loads component-specific mock data at design-time (when in the Experience Builder) so that
 * a user is not left without any visualization of the component during the declarative administration of a page.
 *
 * If you prefer to change this behavior, simply remove the places marked with "design-time only".
 * @slot heading
 */
export default class bwc_BuilderProductVariantSelector extends LightningElement {
    /*
     * @description Specifies the rendering mode for the component.
     */
    static renderMode = 'light';

    /**
     * @type {?JsonData}
     * @private
     */
    _sessionContext; // <-- design-time only

    /**
     * @type {?JsonData}
     * @private
     */
    _product;

    /**
     * @type {?JsonData}
     * @private
     */
    _designTimeData; // <-- design-time only

    @wire(NavigationContext)
    navContext;

    /**
     * @description We need to show the pricing tiers during design-time / preview mode. So we're using
     * the session context to retrieve that information.
     * @param {object} response Wire adapter response
     * @param {JsonData} [response.data] The wired session context data
     * @private
     */
    @wire(SessionContextAdapter) // <-- design-time only
    wireSessionContext({ data }) {
        this._sessionContext = data;
        if (this._sessionContext?.isPreview && !this._designTimeData) {
            this._designTimeData = variationInfo();
        }
    }

    /**
     * @description The product to select variants for.
     * @type {?JsonData}
     */
    @api
    set product(value) {
        this._product = value;
    }

    get product() {
        if (
            this.isPreviewMode &&
            this._product &&
            !this._product?.variationInfo?.variationAttributeInfo &&
            this._designTimeData
        ) {
            // This whole condition is for the design-time only
            return { ...this._product, variationInfo: { ...this._designTimeData } };
        }
        return this._product;
    }

    /**
     * @description list of buyer group names, returned from the User data binding expression
     * @type {?list}
     */
    _buyerGroupNames;

    @api
    get buyerGroupNames() {
        return this._buyerGroupNames;
    }
    set buyerGroupNames(value) {
        if (value) {
            this._buyerGroupNames = value;
        }
    }

    /**
     * @description design-time only
     * @private
     * @returns {boolean} Whether we operate in the design-time / preview mode
     */
    get isPreviewMode() {
        return !!this._sessionContext?.isPreview;
    }

    /**
     * @description Determines whether variant can be displayed based on productClass being of
     * a supported type.
     * @type {boolean}
     * @private
     */
    get isDisplayable() {
        // The `isPreviewMode` condition portion is for the design-time only
        return this.isPreviewMode || isVariantSupportedProductClass(this.product?.productClass);
    }

    /**
     * H@description andles when the variation of the product changes.
     * @private
     * @param {CustomEvent} event - contains info about product that variant change relates to.
     */
    handleVariantOptionChanged(event) {
        event.stopPropagation();
        const { productId, options, isValid } = event.detail;
        dispatchAction(this, createProductVariantUpdateAction(options, isValid));

        if (isValid && productId && this.navContext) {
            navigate(this.navContext, {
                type: 'standard__recordPage',
                attributes: {
                    objectApiName: 'Product2',
                    recordId: productId,
                    actionName: 'view',
                },
                state: {
                    recordName: 'Product2',
                },
            });
        }
    }
}