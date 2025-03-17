import { api, LightningElement } from 'lwc';
import { generateStyleProperties } from 'experience/styling';
import { EVENT, KEY_CODE, PRODUCT_COMPARE_CONSTANTS, FIELD_NAMES } from './constants';
import { i18n, productCompareLabels } from './labels';
import bwc_CommonModal from 'c/bwc_commonModal';
import { NavigationMixin } from 'lightning/navigation';

/**
 * @description Generates an SLDS CSS class representing margin of a given spacing.
 * @param {string} spacing The defined spacing
 * @param {('vertical' | 'horizontal')} direction The direction to use
 * @returns {string} The margin class
 */
function generateClassForSpacing(spacing, direction) {
    return ['none', 'small', 'medium', 'large'].includes(spacing) ? `slds-m-${direction}_${spacing}` : '';
}

/**
 * @description An event fired when the add to cart button is clicked.
 * @event SearchProductGrid#addproducttocart
 * @type {CustomEvent}
 * @property {object} detail CustomEvent details
 * @property {string} detail.productId
 *   The unique identifier of the product to be added to the cart.
 * @property {number} detail.quantity
 *   The quantity of the product to be added to the cart.
 */

/**
 * @description An event fired when the user indicates a desire to view the details of a product.
 * @event SearchProductGrid#showproduct
 * @type {CustomEvent}
 * @property {object} detail CustomEvent details
 * @property {string} detail.productId
 *   The unique identifier of the product.
 * @property {string} detail.productName
 *   The name of the product.
 */

/**
 * @description The layout UI configuration.
 * @typedef {object} ProductGridConfiguration
 * @property {string} layout
 *  The layout for the card collection.
 *  Supported (case-sensitive) values are:
 *  - "grid"
 *      The products will be displayed in grid column layout.
 *      The property gridMaxColumnsDisplayed defines the max no. of columns.
 *  - "list"
 *      The products will be displayed as a list.
 * @property {number} gridMaxColumnsDisplayed
 *  The maximum columns to be displayed in the grid.
 * @property {ProductCardConfiguration} cardConfiguration
 *  The card layout configuration.
 */

/**
 * @description Representation of Builder Field Item
 * @typedef {object} BuilderFieldItem
 * @property {string} name
 *  The name of the field.
 * @property {string} fontSize
 *  The font size of the field.
 *  Accepted values are: "small", "medium", and "large"
 * @property {string} fontColor
 *  Font color for the field, as 'rgb', 'rgba' or 'hex' CSS value.
 */

/**
 * @fires SearchProductGrid#showproduct
 * @fires SearchProductGrid#addproducttocart
 */

/**
 * @description Displays products in a grid or by rows
 */
export default class bwc_searchProductGrid extends NavigationMixin(LightningElement) {
    static renderMode = 'light';

    /**
     * @description Gets or sets the product layout configuration.
     * @type {?ProductGridConfiguration}
     */
    @api
    configuration;

    /**
     * @description Gets or sets the card collection display-data.
     * This property gets data from the searchResults component, which in turn gets data from the page's data provider.
     * Be aware that this property can be updated multiple times during the component's life cycle
     * @type {ProductCardData[]} - an example of the array structure is shown in the example.
     * @example
     * [ { "id": "01tHn00000UMH9iIAH", "name": "Bella Chrome Coffee Machine (Sample)", "fields": [ { "name": "Name", "label": "Product Name", "value": "Bella Chrome Coffee Machine (Sample)", "tabStoppable": false }, { "name": "StockKeepingUnit", "label": "SKU", "value": "B-C-COFMAC-001", "tabStoppable": false } ], "image": { "url": "https://c.na139.content.force.com/servlet/servlet.ImageServer?id=0154W00000CxsJ0&oid=00D4W0000054JBn", "alternateText": "\"Bella Chrome Coffee Machine\"" }, "prices": { "currencyIsoCode": "USD", "listingPrice": null, "negotiatedPrice": null, "isLoading": false }, "productClass": "Simple", "purchaseQuantityRule": null, "variationAttributeSet": null, "isOnSale": false, "isOnClearance": false, "fieldsMap": { "Is_Finished_Good__c": "Y", "bwc_SwatchConfig__c": null, "Is_Accessory__c": null, "BWC_Is_Part__c": "false", "StockKeepingUnit": "B-C-COFMAC-001", "Name": "Bella Chrome Coffee Machine (Sample)" } } ]
     */
    @api
    displayData;

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

    /**
     * @description Array that holds the skus being compared. The purpose is to maintain state of which products have
     * been selected for product compare. This is a reactive property since it is referenced by other reactive properties.
     */
    comparedProducts = [];

    //@track normalizedDisplayData = [];

    /**
     * @description Gets the normalized card collection (displayData).
     * For product compare, the card collection is updated to indicate if a product is selected for comparison.
     * This is a reactive property since it is directly referenced in the HTML.
     * This property references the "displayData" property, so that makes "displayData" reactive as well.
     * @type {ProductCardData[]}
     * @readonly
     * @private
     */
    get normalizedDisplayData() {
        const numProducts = this.displayData?.length;
       // let defaultSku=this.displayData?.defaultSku;
        // lets clone displayData so that we can safely update it since it is a reactive property
        let clonedDisplayData = JSON.parse(JSON.stringify(this.displayData ?? []));
         console.log("clonedDisplayData ProductGrid", JSON.stringify(clonedDisplayData));

        // Check each product to determine if it should have a product compare checkbox or not
        clonedDisplayData.forEach(data => {
            console.log("data ProductGrid ", JSON.stringify(data),numProducts,this.shouldDisplayProductCompare(data));
            data.shouldDisplayProductCompare = numProducts > 1 && this.shouldDisplayProductCompare(data);
            data?.fields?.map(element => {if(element.label=='SKU'){
                console.log("shouldDisplayProductCompare PG element.value",element.value, data.shouldDisplayProductCompare);
            }
            })
            
            });
        // If we currently have compared products in the comparedProducts array then set the "isCompared" property so that
        // the checkbox will appear checked
        if (this.comparedProducts.length) {
            this.comparedProducts.forEach(comparedProduct => {
                let data = clonedDisplayData.find(p => p.fields.find(f => (f.name === FIELD_NAMES.SKU) && (f.value === comparedProduct)));
                if (data) {
                    data.isCompared = true;
                }
            });
        }
        return clonedDisplayData;
    }

    /**
     * @description Returns whether or not a product is eligible for product compare
     * @param {ProductCardData} data
     * @returns {Boolean}
     */
    shouldDisplayProductCompare(data) {
        console.log("shouldDisplayProductCompare ProductGrid & data", JSON.stringify(data) );
        const hasSpecsAndDetails = !!data?.fieldsMap?.[FIELD_NAMES.SPECS_AND_DETAILS];
        const isFinishedGood = data?.fieldsMap?.[FIELD_NAMES.IS_FINISHED_GOOD]?.toUpperCase()[0] === 'Y';
        const isAccessory = data?.fieldsMap?.[FIELD_NAMES.IS_ACCESSORY]?.toUpperCase()[0] === 'Y';
        //const isPart = data?.fieldsMap?.[FIELD_NAMES.IS_PART]?.toUpperCase()[0] === 'Y';
        const isPart = data?.fieldsMap?.[FIELD_NAMES.IS_PART] === true;
        console.log("shouldDisplayProductCompare ProductGrid & data",isFinishedGood, hasSpecsAndDetails, !isAccessory, !isPart, JSON.stringify(data) );

        return isFinishedGood && hasSpecsAndDetails && !isAccessory && !isPart;
    }

    /**
     * @description Gets the SLDS classes to apply the spacing for the product layout.
     * @type {string}
     * @readonly
     * @private
     */
    get layoutSpacingClasses() {
        const list = this?.querySelector('ul');
        const spacingRow = list && getComputedStyle(list).getPropertyValue('--ref-c-search-product-grid-spacing-row');
        const spacingCol =
            list && getComputedStyle(list).getPropertyValue('--ref-c-search-product-grid-spacing-column');
        const row = generateClassForSpacing(spacingRow || '', 'vertical');
        const col = generateClassForSpacing(spacingCol || '', 'horizontal');
        return `${row} ${col}`.trim();
    }

    /**
     * @description Gets the custom styles to apply to the elements of the product layout.
     * @type {string}
     * @readonly
     * @private
     */
    get layoutCustomStyles() {
        const gridMaxColumnsDisplayed = this.configuration?.gridMaxColumnsDisplayed || 4;
        const cardBasis = gridMaxColumnsDisplayed > 0 ? 100 / gridMaxColumnsDisplayed : 25;
        return generateStyleProperties({
            '--ref-c-search-product-grid-container-basis': `${Math.round(cardBasis * 100) / 100}%`,
        });
    }

    /**
     * @description Gets the grid specific class for the un-ordered list container if the
     * layout is 'grid', otherwise it returns empty string.
     * @type {string}
     * @readonly
     * @private
     */
    get layoutContainerClass() {
        return this.isGridLayout ? 'product-grid-container' : '';
    }

    /**
     * @description Gets whether the layout is grid or not.
     * @type {boolean}
     * @readonly
     * @private
     */
    get isGridLayout() {
        return this.configuration?.layout === 'grid';
    }

    /**
     * @description Arial label for the list.
     * @type {string}
     * @readonly
     * @private
     */
    get ariaLabelForSearchResults() {
        return i18n.searchResults;
    }

    /**
     * @description Product card configuration.
     * @type {?ProductCardConfiguration}
     * @readonly
     * @private
     */
    get cardConfiguration() {
        return this.configuration?.cardConfiguration;
    }

    /**
     * @description Handles the `addproducttocart` event which adds the product to the cart.
     * @param {CustomEvent} event An "addproducttocart" received from a product card
     * @private
     * @fires SearchProductGrid#addproducttocart
     */
    handleAddToCart(event) {
        event.stopPropagation();
        this.dispatchEvent(
            new CustomEvent(EVENT.ADD_PRODUCT_TO_CART_EVT, {
                detail: event.detail,
            })
        );
    }

    /**
     * @description Handles the `showproduct` event which navigates to a product detail page.
     * @param {CustomEvent} event A "showproduct" received from a product card
     * @private
     * @fires SearchProductGrid#showproduct
     */
    handleNavigateToProductPage(event) {
        event.stopPropagation();
        this.dispatchEvent(
            new CustomEvent(EVENT.SHOW_PRODUCT_EVT, {
                detail: event.detail,
            })
        );
    }

    /**
     * @description Handles key downs on the list.
     *
     * - Home moves focus to first item.
     * - End moves focus to last item.
     * - Up arrow moves focus to previous item.
     * - Down arrow moves focus to next item.
     *
     * When the Add to Cart button is present, user can navigate
     * the list using the Home, End, and Tab (default behavior) keys.
     *
     * When the Add to Cart button isn’t present, user can navigate
     * the list using the Home, End, Tab (default behavior), Up and Down keys.
     * @param {KeyboardEvent} event The keyboard event
     * @private
     */
    handleKeyDown(event) {
        const { code } = event;
        if (event.target instanceof HTMLElement) {
            const id = event.target.dataset.id;
            const index = this.normalizedDisplayData.findIndex((product) => product.id === id);
            const callToActionButtonEnabled = this.configuration?.cardConfiguration.showCallToActionButton;
            switch (code) {
                case KEY_CODE.ARROW_DOWN:
                    if (!callToActionButtonEnabled) {
                        event.preventDefault();
                        this.focusListItem(index, +1);
                    }
                    break;
                case KEY_CODE.ARROW_UP:
                    if (!callToActionButtonEnabled) {
                        event.preventDefault();
                        this.focusListItem(index, -1);
                    }
                    break;
                case KEY_CODE.HOME:
                    event.preventDefault();
                    this.focusListItem(0, 0);
                    break;
                case KEY_CODE.END:
                    event.preventDefault();
                    this.focusListItem(0, -1);
                    break;
                default:
                    break;
            }
        }
    }

    /**
     * @description Focuses a list item.
     * @param {number} baseIndex The base index position.
     * @param {number} steps The number of steps from the baseIndex position.
     * @private
     */
    focusListItem(baseIndex, steps) {
        const itemCount = this.normalizedDisplayData.length;
        let newActiveIndex = (baseIndex + steps) % itemCount;

        if (newActiveIndex < 0) {
            newActiveIndex = itemCount - 1;
        }
        Array.from(this.querySelectorAll('c-search-product-card')).at(newActiveIndex)?.focus();
    }

    /**
     * @description This handler function responds to the event thrown from the bwc_searchProductCard when
     * the bwc_searchProductCard detects that the current product is a Variation Parent.  If the current product
     * is a Variation Parent then the code will fetch the product data for the default variation product or the first
     * variation product found if no default is set on the product.  The Variation Product data is then passed back
     * to the parent object (bwc_searchProductGrid) so that it can replace the Variation Parent product in the list
     * with its Variation child product.
     * This is done so that subsequent code in bwc_searchProductGrid that looks at the product will function correctly
     * using the default Variation product's data as opposed to the Variation Parent's product data.
     *
     * @param {Object} event
     * @param {String} event.productId - Product Id of Variation Parent product
     * @param {Object} event.defaultVariationProduct - Default Variation Product Data
     */
    handleProductChanged(event) {
        event.stopPropagation();
        const {productId, defaultVariationProduct} = event.detail;
        console.log("handleProductChanged event", JSON.stringify(event.detail));
        let clonedDisplayData = JSON.parse(JSON.stringify(this.displayData ?? []));
       
        let index = clonedDisplayData.findIndex(p => p.id === productId);
        console.log("clonedDisplayData PG event handler", JSON.stringify(clonedDisplayData), index);
        if (index !== -1) {
            clonedDisplayData[index] = defaultVariationProduct;
             this.displayData = clonedDisplayData;       
            

        }
    }

    /**
     * @description Event handler for when a product is checked for comparison
     * The "sku" being compared is added to the "comparedProducts" array, which is reactive, so this causes
     * the display for the lwc to be updated.
     * @param {Object} event
     * @param {String} event.detail.sku
     */
    handleCompareEvent(event) {
        event.stopPropagation();
        const {sku} = event.detail;
        console.log("ProductGRid event::", JSON.stringify(event.detail));
        if (this.comparedProducts.length < PRODUCT_COMPARE_CONSTANTS.MAX) {
             console.log("ProductGRid comparedProducts::", JSON.stringify(this.comparedProducts));
            // Triggers UI to be updated
            this.comparedProducts = [...this.comparedProducts, sku];
             console.log("ProductGRid comparedProducts after::", JSON.stringify(this.comparedProducts));
        } else {
            bwc_CommonModal.open({
                label: productCompareLabels.max
            });
        }
    }

    /**
     * @description Event handler for when a product is un-checked for comparison
     * The "sku" being un-compared is removed from the "comparedProducts" array, which is reactive, so this causes
     * the display for the lwc to be updated.
     * @param {Object} event
     * @param {String} event.detail.sku
     */
    handleUnCompareEvent(event) {
        event.stopPropagation();
        const {sku} = event.detail;
        // Triggers UI to be updated
        this.comparedProducts = this.comparedProducts.filter(comparedProduct => comparedProduct != sku);
    }

    /**
     * @description This handler runs when the link for product compare is clicked on.
     * If there are too many products or only 1 product being compared then a modal window is shown.
     * Otherwise the user is redirected to the Product Compare page (/compare) with the list of SKU's
     * that are to be compared.
     *
     * @param {Object} event
     */
    handleCompareNowEvent(event) {
        event.stopPropagation();
        if (this.comparedProducts.length < PRODUCT_COMPARE_CONSTANTS.MIN) {
            bwc_CommonModal.open({
                label: productCompareLabels.min
            });
        } else if (this.comparedProducts.length > PRODUCT_COMPARE_CONSTANTS.MAX) {
            bwc_CommonModal.open({
                label: productCompareLabels.max
            });
        } else {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'Compare__c',
                },
                state: {
                    searchTerm: this.comparedProducts
                }
            });
        }
    }
}