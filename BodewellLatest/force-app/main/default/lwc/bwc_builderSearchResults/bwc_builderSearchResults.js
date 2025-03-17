import { LightningElement, api, wire } from 'lwc';
import { navigate, NavigationContext } from 'lightning/navigation';
import { createCartItemAddAction, createSearchFiltersUpdateAction, dispatchAction } from 'commerce/actionApi';
import getProductInformation from '@salesforce/apex/BWC_TagController.getProductInformation';
import CommonModal from 'c/bwc_commonModal';
import { Labels } from './labels';

/**
 * @description Component that displays products for search and category page.
 */
export default class bwc_BuilderSearchResults extends LightningElement {
    static renderMode = 'light';

    @wire(NavigationContext)
    navContext;

    /**
     * @description Results returned from the Search Data Provider
     * @type {?ProductSearchResultSummary}
     */
    @api
    searchResults;

    /**
     * @description Default fields to show in results
     * @type {?string}
     */
    @api
    searchResultsFields;

    /**
     * @description The layout of the results tiles.
     * @type {?('grid' | 'list')}
     */
    @api
    resultsLayout;

    /**
     * @description The size of the spacing between the grid columns.
     * @type {?('small' | 'medium' | 'large'| 'none')}
     */
    @api
    gridColumnSpacing;

    /**
     * @description The size of the spacing between the grid rows.
     * @type {?('small' | 'medium' | 'large'| 'none')}
     */
    @api
    gridRowSpacing;

    /**
     * @description The maximum number of grid columns to be displayed.
     * Accepted values are between 1 and 8.
     * @type {?number}
     */
    @api
    gridMaxColumnsDisplayed;

    /**
     * @description The size of the spacing between the list rows.
     * @type {?('small' | 'medium' | 'large'| 'none')}
     */
    @api
    listRowSpacing;

    /**
     *@description  Font color for the card background field, as 'rgb', 'rgba' or 'hex' CSS value.
     * @type {?string}
     */
    @api
    cardBackgroundColor;

    /**
     * @description The alignment of the results cards.
     * @type {?('right' | 'center' | 'left')}
     */
    @api
    cardAlignment;

    /**
     * @description Font color for the card border field, as 'rgb', 'rgba' or 'hex' CSS value.
     * @type {?string}
     */
    @api
    cardBorderColor;

    /**
     * @description The value of the border radius for the results card.
     * @type {?string}
     */
    @api
    cardBorderRadius;

    /**
     * @description Font color for the card divider field, as 'rgb', 'rgba' or 'hex' CSS value.
     * @type {?string}
     */
    @api
    cardDividerColor;

    /**
     * @description The font size of the negotiated price.
     * @type {?('small' | 'medium' | 'large')}
     */
    @api
    negotiatedPriceTextSize;

    /**
     * @description Whether to display the negotiated price.
     * @type {boolean}
     * @default false
     */
    @api
    showNegotiatedPrice = false;

    /**
     * @description Font color for the negotiated price text field, as 'rgb', 'rgba' or 'hex' CSS value.
     * @type {?string}
     */
    @api
    negotiatedPriceTextColor;

    /**
     * @description Whether to display the original price.
     * @type {boolean}
     * @default false
     */
    @api
    showOriginalPrice = false;

    /**
     * @description The font size of the original price.
     * @type {?('small' | 'medium' | 'large')}
     */
    @api
    originalPriceTextSize;

    /**
     * @description Font color for the original price text field, as 'rgb', 'rgba' or 'hex' CSS value.
     * @type {?string}
     */
    @api
    originalPriceTextColor;

    /**
     * @description Whether to display the product image.
     * @type {boolean}
     * @default false
     */
    @api
    showProductImage = false;

    /**
     * @description The product fields to display in the productCard cmp.
     * @type {string}
     */
    @api
    cardContentMapping;

    /**
     * @description Whether to display the action button.
     * @type {boolean}
     * @default false
     */
    @api
    showCallToActionButton = false;

    /**
     * @description The text for the add to cart button
     * @type {?string}
     */
    @api
    addToCartButtonText;

    /**
     * @description The button style for add to cart button
     * Accepted values primary, secondary, tertiary
     * @type {?('primary' | 'secondary' | 'tertiary')}
     */
    @api
    addToCartButtonStyle;

    /**
     * @description The text for the add to cart button when cart is processing
     * @type {?string}
     */
    @api
    addToCartButtonProcessingText;

    /**
     * @description The text for the view options button
     * @type {?string}
     */
    @api
    viewOptionsButtonText;

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
     * @description The current page number of the results.
     * @type {?string}
     */
    @api
    currentPage;

    /**
     * @description returned from the User expression
     * @type {?list}
     */
    @api
    buyerGroupNames;

    @api
    showPurchasableProductsOnly;

    /**
     * @type {CardContentMappingItem[]}
     * @readonly
     * @private
     */
    get normalizedCardContentMapping() {
        return JSON.parse(this.cardContentMapping ?? '[]');
    }

    /**
     * @description Getter to retrieve the product IDs from the search results.
     * @type {string[]}
     * @readonly
     * @private
     */
    get productIds() {
        return this.searchResults?.cardCollection?.map(product => product.id);
    }

    /**
     * @description The processed search results.
     * @type {object}
     * @private
     */
    _processedSearchResults;

    /**
     * @description Contains the product IDs that are currently on sale
     * @type {string[]}
     * @private
     */
    _promotionalData;

    /**
     * @description Contains the product IDs that are currently on clearance.
     * @type {string[]}
     * @private
     */
    _clearanceData;

    /**
     * @description Getter for the processed search results, returns the processed search results or the original search results if not processed.
     * @type {?object}
     * @readonly
     * @private
     */
    get processedSearchResults() {
        let results = this._processedSearchResults || this.searchResults;
        //console.log("results",JSON.parse(results));
        return results;      
    }

    /**
     * @description Get Sale and Clearance information for products
     * @param {object} result - The result object containing data and error information.
     * @private
     */
    @wire(getProductInformation, { buyerGroupNames: '$buyerGroupNames', productIds: '$productIds' })
    wiredGetProductInfo({ data }) {
        if (data) {
            this._clearanceData = data.clearance;
            this._promotionalData = data.sale;
            this.processResults();
        } 
    }

    /**
     * @description Processes the search results by checking the promotional and clearance data.
     * It marks products as on sale if their IDs are found in `promotionalData` and
     * as on clearance if their IDs are found in `clearanceData`.
     * If any of the data (promotional, clearance, or search results) is unavailable, the method does nothing.
     *
     * @private
     */
    processResults() {
        if (this.searchResults) {
            // Create a deep copy of the search results
            let searchResultsCopy = JSON.parse(JSON.stringify(this.searchResults));

            // Modify the copied search results
            searchResultsCopy.cardCollection
            .forEach(product => {
                // Process promotional and clearance data
                //"isOnSale" and "isOnClearance" is needed by the bwc_tag component
                if (this._promotionalData) {
                    product.isOnSale = this._promotionalData.includes(product.id);
                }
                if (this._clearanceData) {
                    product.isOnClearance = this._clearanceData.includes(product.id);
                }

                // Copy the fields data for use later on in the bwc_searchProductCard
                // This is needed because the bwc_searchProductCard will modify the "fields"
                // array by removing fields that are not specified in the "cardContentMapping" property
                // The original field data can be accessed now via the "fieldsMap" property

                /* Example of JSON structure for "product"
                { "id": "01tHn00000UMH9iIAH", "name": "Bella Chrome Coffee Machine (Sample)", "fields": { "bwc_SwatchConfig__c": { "value": null }, "BWC_Is_Part__c": { "value": "false" }, "StockKeepingUnit": { "value": "B-C-COFMAC-001" }, "Name": { "value": "Bella Chrome Coffee Machine (Sample)" } }, "image": { "url": "https://c.na139.content.force.com/servlet/servlet.ImageServer?id=0154W00000CxsJ0&oid=00D4W0000054JBn", "alternateText": "\"Bella Chrome Coffee Machine\"" }, "prices": { "currencyIsoCode": "USD", "listingPrice": null, "negotiatedPrice": null, "isLoading": false }, "productClass": "Simple", "purchaseQuantityRule": null, "variationAttributeSet": null },
                */
                product.fieldsMap = Object.keys(product.fields).reduce((acc, name) => {
                    acc[name] = product.fields[name].value;
                    return acc;
                }, {});
            });

            // Update the component's search results with the modified copy
            this._processedSearchResults = searchResultsCopy;
            //console.log("this._processedSearchResults", JSON.parse(this._processedSearchResults));
        }
    }

    /**
     * @description Handles the 'addproducttocart' event.
     * Adds the product to the cart and then on success opens the add to cart modal.
     * @param {CustomEvent<{ productId: string; quantity: number }>} event The event object
     * @private
     */
    handleAddToCart(event) {
        event.stopPropagation();
        const { productId, quantity } = event.detail;
        dispatchAction(this, createCartItemAddAction(productId, quantity), {
            onSuccess: () => {
                CommonModal.open({
                    label: Labels.messageSuccessfullyAddedToCart,
                    size: 'small',
                    secondaryActionLabel: Labels.actionContinueShopping,
                    primaryActionLabel: Labels.actionViewCart,
                    onprimaryactionclick: () => this.navigateToCart(),
                });
            },
        });
    }

    /**
     * @description Navigates to the cart page when the primary button is clicked
     * from the modal after adding an item to the cart
     * @private
     */
    navigateToCart() {
        // eslint-disable-next-line no-unused-expressions
        this.navContext && navigate(this.navContext, {
                type: 'comm__namedPage',
                attributes: {
                    name: 'Current_Cart',
                },
            });
    }

    /**
     * @description Handles navigating to the product detail page from the search results page.
     * @param {CustomEvent<{productId: string; productName: string}>} event The event object
     */
    handleNavigateToProductPage(event) {
        event.stopPropagation();

        // eslint-disable-next-line no-unused-expressions
        this.navContext && navigate(this.navContext, {
                type: 'standard__recordPage',
                attributes: {
                    objectApiName: 'Product2',
                    recordId: event.detail.productId,
                    actionName: 'view'
                },
                state: {
                    recordName: event.detail.productName,
                },
            });
    }

    /**
     * @description Trigger an update of the page number at the closest `SearchDataProvider`
     * @param {CustomEvent<{newPageNumber: number}>} event The event object
     * @private
     */
    handleUpdateCurrentPage(event) {
        event.stopPropagation();
        dispatchAction(this, createSearchFiltersUpdateAction({ page: event.detail.newPageNumber }));
    }
}