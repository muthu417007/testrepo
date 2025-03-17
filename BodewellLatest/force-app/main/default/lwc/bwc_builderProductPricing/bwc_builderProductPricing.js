import { api, LightningElement, wire } from 'lwc';
import { generateStyleProperties } from 'experience/styling';
import BWC_UI from '@salesforce/resourceUrl/BodewellTheme';
import { AppContextAdapter } from 'commerce/contextApi';

const textSizeToStyle = new Map([
    ['small', 'var(--dxp-s-text-heading-small-font-size)'],
    ['medium', 'var(--dxp-s-text-heading-medium-font-size)'],
    ['large', 'var(--dxp-s-text-heading-large-font-size)'],
]);

/**
 * @typedef {{[key: string]: *}} JsonData
 */

/**
 * @description Gets the associated dxp CSS font size property for the given text size.
 * @private
 * @param {('small' | 'medium' | 'large')} textSize The size of heading to be reflected by the returned CSS class.
 * @returns {string} The dxp CSS property matching the requested size, if one exists; otherwise, 'initial'.
 */
function getTextSizeStyle(textSize) {
    return textSizeToStyle.get(textSize) ?? 'initial';
}

/**
 * @description This is a builder component that exposes the properties that are needed by the bwc_productPricing 
 * component to Experience Builder.
 */
export default class BuilderProductPricing extends LightningElement {

    MEMBER_SKU = BWC_UI + '/icons/membership.svg';

    static renderMode = 'light';

    /**
     * @description Product data.
     * @type {?JsonData}
     */
    @api product;

    /**
     * @description Product pricing data for a product.
     * @type {?JsonData}
     */
    @api productPricing;

    /**
     * @description Product tax data for a product.
     * @type {?JsonData}
     */

    @api productTax;

    /**
     * @description Product variant data for the currently selected product variant, if any.
     * @type {?{isValid: boolean}}
     */
    @api productVariant;

    /**
     * @description Whether to show the negotiated price.
     * @type {?boolean}
     */
    @api showNegotiatedPrice;

    /**
     * @description The color of the negotiated price label text.
     * @type {?string}
     */
    @api negotiatedPriceTextColor;

    /**
     * @description The size of the negotiated price label text.
     * @type {('small' | 'medium' | 'large' | null)}
     */
    @api negotiatedPriceTextSize;

    /**
     * @description The negotiated price label text.
     * @type {?string}
     */
    @api negotiatedPriceLabel;

    /**
     * @description The color of the original price label text.
     * @type {?string}
     */
    @api originalPriceTextColor;

    /**
     * @description The size of the original price label text.
     * @type {?string}
     */
    @api originalPriceTextSize;

    /**
     * @description The original price label text.
     * @type {?string}
     */
    @api originalPriceLabel;

    /**
     * @description The unavailable price label text.
     * @type {?string}
     */
    @api unavailablePriceLabel;

    /**
     * @description Whether to display the Original price
     * @type {?boolean}
     */
    @api showOriginalPrice;

    /**
     * @description Whether to show the VAT Tax section.
     * @type {?boolean}
     */
    @api showTaxIndication;

    /**
     * @description The Tax Included label text.
     * @type {?string}
     */
    @api taxIncludedLabel;

    /**
     * @description The size of the tax label text.
     * @type {?string}
     */
    @api taxLabelSize;

    /**
     * @description The color of the Tax label text.
     * @type {?string}
     */
    @api taxLabelColor;

    /**
     * @description Tax locale type for the product.
     * @type {('Gross' | 'Net' | null)}
     */
    taxLocaleType;

    /**
     * @description Tax rate for the product.
     * When a given product is exempt, taxRatePercentage will be 0.
     * @type {?number}
     */
    get taxRatePercentage() {
        const taxRate = this.productTax?.taxPolicies?.[0]?.taxRatePercentage;

        return taxRate != null ? Number(taxRate) : undefined;
    }

    /**
     * @description The ISO 4217 currency code for the product detail page.
     * @type {?string}
     */
    get currencyCode() {
        return this.productPricing?.currencyIsoCode;
    }

    /**
     * @description The localized negotiated price of the item.
     * @type {?string}
     */
    get negotiatedPrice() {
        return this.productPricing?.negotiatedPrice;
    }

    /**
     * @description The localized original price of the item.
     * @type {?string}
     */
    get originalPrice() {
        return this.productPricing?.listPrice;
    }

    @wire(AppContextAdapter)
    wireAppContext(entry) {
        if (entry.data) {
            this.taxLocaleType = entry.data.taxType;
        }
    }

    /**
     * @description Custom styling for the product price.
     * @returns {string} Default styles
     */
    get priceStyles() {
        return generateStyleProperties({
            '--ref-c-product-pricing-tax-info-label-color': this.taxLabelColor || 'initial',
            '--ref-c-product-pricing-tax-info-label-size': getTextSizeStyle(this.taxLabelSize),
            '--ref-c-product-pricing-original-price-label-color': this.originalPriceTextColor || 'initial',
            '--ref-c-product-pricing-original-price-label-size': getTextSizeStyle(this.originalPriceTextSize),
            '--ref-c-product-pricing-negotiated-price-label-color': this.negotiatedPriceTextColor || 'initial',
            '--ref-c-product-pricing-negotiated-price-label-size': getTextSizeStyle(this.negotiatedPriceTextSize),
        });
    }

    /**
     * @description Should render pricing component if
     * - the variantAttribute selection is not invalid
     * - not a VariationParent product
     * - pricing data is loaded
     * - product data is loaded.
     *
     * We need to check both pricing data and product data are loaded.
     * We still want to render the pricing component if there is no data or error occurs instead of hiding the component completely,
     * because the pricing component has a price unavailable state we could leverage.
     * @returns {boolean} Whether to display the pricing
     */
    get displayPricing() {
        return (
            this.isValidProductVariant &&
            this.isValidProductClass &&
            this.isProductDataAvailable &&
            this.isProductPricingDataAvailable
        );
    }

    get isValidProductVariant() {
        return this.productVariant?.isValid !== false;
    }

    get isValidProductClass() {
        return this.product?.productClass !== 'VariationParent' && this.product?.productClass !== 'Set';
    }

    get isProductDataAvailable() {
        return this.product != null;
    }

    get isProductPricingDataAvailable() {
        return this.productPricing != null;
    }

    /**
     * @description LWC hook called after each render.
     */
    renderedCallback() {
        this.classList.toggle('slds-hide', !this.displayPricing);
    }
}