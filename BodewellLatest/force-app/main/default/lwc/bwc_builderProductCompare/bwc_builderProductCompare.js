import { LightningElement, wire, api } from "lwc";
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { addItemToCart } from 'commerce/cartApi';
import getProductInformation from '@salesforce/apex/BWC_TagController.getProductInformation';
import { ProductSearchAdapter, ProductPricingCollectionAdapter } from 'commerce/productApi';
import { SessionContextAdapter } from 'commerce/contextApi';
import { Labels } from './labels';
import CommonModal from 'c/bwc_commonModal';
const MAX_GRID_COLS = 4;

export default class bwc_builderProductCompare extends NavigationMixin(LightningElement) {

    sessionContext;
    buyerGroupNames;
    currentPageReference;
    searchQuery;
    searchResults;
    productIds;
    _productIds;
    productCompareSkus;

    /**
     * @description Default fields to show in results
     * @type {?string}
     */
    @api
    searchResultsFields;

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
     * @type {CardContentMappingItem[]}
     * @readonly
     * @private
     */
    get normalizedCardContentMapping() {
        return JSON.parse(this.cardContentMapping ?? '[]');
    }

    get productCompareCount() {
        return this.productIds?.length;
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
        return this._processedSearchResults || this.searchResults;
    }

    @wire(SessionContextAdapter)
    wireSessionContext({ data }) {
        this.sessionContext = data;
        this.buyerGroupNames = this.sessionContext?.buyerGroups.map(bg => bg.name)
    }

    grouping = {
        groupingOption: "NoGrouping"
    };
    
    @wire(CurrentPageReference)
    wiredCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        //console.log("currentPageReference ::", this.currentPageReference);
        if (this.currentPageReference.state?.searchTerm && this.searchResultsFields) {
            this.productCompareSkus = this.productCompareSkus ?? this.currentPageReference.state.searchTerm.split(',');
           // console.log("productCompareSkus ::", this.productCompareSkus);
            this.searchQuery = {
                searchTerm: this.productCompareSkus.join(' | '),
                fields: this.searchResultsFields.split(',').map(x => x.trim()),
                grouping: this.grouping.groupingOption

            };
           // console.log("Search Query ::", JSON.stringify(this.searchQuery));
          
        }
    }

    @wire(ProductSearchAdapter, {
        searchQuery: '$searchQuery',
    })
    wiredSearchResults({ data }) {
        // console.log("wiredSearchResults called", this.searchQuery);      
        if (data) {
            // console.log("Search Query wiredSearchResults :: ", this.searchQuery);
            // console.log("data productCompare ::", JSON.stringify(data));
            this.searchResults = this.transformData(data);
            this._productIds = this.searchResults?.cardCollection?.map(product => product.id);
            // console.log("_productIds ::", this._productIds);
        }
        
    }

    @wire(ProductPricingCollectionAdapter, {
        productIds: '$_productIds',
    })
    wiredProductPricingCollectionResults({ data }) {
        if (data) {
            this.searchResults = this.normalizeSearchResultsWithPricing(data);
            this.productIds = this.searchResults?.cardCollection?.map(product => product.id);
        }
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
            console.log("searchResultsCopy PC", JSON.stringify(searchResultsCopy));

            // Modify the copied search results
            searchResultsCopy.cardCollection.forEach(product => {
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
            })

            // Update the component's search results with the modified copy
            this._processedSearchResults = searchResultsCopy;
        }
    }

    _specAndDetails;
    _productsCount;
    rowClass;
    get specAndDetails() {
        if (this._processedSearchResults) {
            console.log("_processedSearchResults PC", JSON.stringify(this._processedSearchResults));
            this._specAndDetails = [];
            console.log("##this._processedSearchResults", JSON.stringify(this._processedSearchResults.cardCollection));
            this._productsCount = this._processedSearchResults?.cardCollection.length;
            this.rowClass = `slds-grid slds-nowrap slds-col slds-size_${this._productsCount * 3}-of-12 spec-category`;
            console.log("##_productsCount, rowClass", this._productsCount, this.rowClass);

            this._processedSearchResults?.cardCollection.forEach((product, index) => {
                console.log("##product,index", product, index);
                const specs = JSON.parse(product.fieldsMap['BWC_ProductSpecAndDetails__c'] || '{}').Spec;
                console.log("##specs", JSON.stringify(specs));

                Object.entries(specs).forEach(([key, value]) => {
                    if (key !== 'sku') {
                        const spec = this._specAndDetails.find(spec => spec.key === key);
                        if (spec) {
                            Object.keys(value).forEach(key => {
                                const specValue = spec.value.find(x => x.key === key);
                                if (specValue) {
                                    specValue['col' + index] = value[key];
                                }
                            });
                        } else {
                            this._specAndDetails.push({
                                key,
                                value: Object.keys(value).map(key => {
                                    return { key, ['col' + index]: value[key] }
                                })
                            });
                        }
                    }

                });


            });

            this._specAndDetails.map((detail) => {
                detail.value.map((val) => {
                    console.log("##val", val);
                    for (let i = 0; i < this._productsCount; i++) {
                        if (!val['col' + [i]]) {
                            val['col' + [i]] = '-';
                        }
                    }
                    return false;
                });

                return false;
            });

            console.log("this.__specAndDetails", JSON.stringify(this._specAndDetails));
            return this._specAndDetails;
        }
    }

    get productPresent() {
        return this._processedSearchResults && this._processedSearchResults.cardCollection.length > 0;
    }

    /**
     * @description Handles navigating to the product detail page from the search results page.
     * @param {CustomEvent<{productId: string; productName: string}>} event The event object
     */
    handleNavigateToProductPage(event) {
        event.stopPropagation();
        const { productId, productName } = event.detail;
        // eslint-disable-next-line no-unused-expressions
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                objectApiName: 'Product2',
                recordId: productId,
                actionName: 'view'
            },
            state: {
                recordName: productName,
            },
        });
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
        addItemToCart(productId, quantity)
            .then(() => {
                CommonModal.open({
                    label: Labels.messageSuccessfullyAddedToCart,
                    size: 'small',
                    secondaryActionLabel: Labels.actionContinueShopping,
                    primaryActionLabel: Labels.actionViewCart,
                    onprimaryactionclick: () => this.navigateToCart(),
                });
            });
    }

    handleCloseProductCompare(event) {
        event.stopPropagation();
        const { sku } = event.detail;
        if (this.productCompareSkus.length > 2) {
            const cloneSearchQuery = JSON.parse(JSON.stringify(this.searchQuery));
            this.productCompareSkus = this.productCompareSkus.filter(x => x !== sku);
            cloneSearchQuery.searchTerm = this.productCompareSkus.join(' | ');
            this.searchQuery = cloneSearchQuery;
        }
    }

    /**
     * @description Navigates to the cart page when the primary button is clicked
     * from the modal after adding an item to the cart
     * @private
     */
    navigateToCart() {
        // eslint-disable-next-line no-unused-expressions
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Current_Cart',
            },
        });
    }

    transformData(results) {
        console.log("results ProductCompare ::", JSON.stringify(results));
        const productsPageDefault = {
            currencyIsoCode: '',
            total: 0,
            products: [],
            pageSize: 20,
            categoryName: undefined,
            resultDescription: undefined,
        };
        const categoryId = results?.categories?.category?.id;
        const categoryName = results?.categories?.category?.name;
        const { productsPage = productsPageDefault } = results || {};
        const { currencyIsoCode, products } = productsPage;
        return {
            cardCollection: (products || []).map(
                ({
                    id,
                    name,
                    defaultImage = {},
                    fields,
                    prices,
                    productClass = '',
                    variationAttributeSet,
                    purchaseQuantityRule,
                    productSellingModelInformation,
                    urlName,
                }) => {
                    const {
                        unitPrice: negotiatedPrice = '',
                        listPrice: listingPrice = '',
                        isLoading = false,
                    } = prices || {};
                    const transformeddDta =
                    {
                        id,
                        name,
                        fields,
                        image: {
                            url: defaultImage?.url ?? '',
                            alternateText: defaultImage?.alternateText ?? '',
                        },
                        prices: {
                            currencyIsoCode: currencyIsoCode ?? '',
                            listingPrice,
                            negotiatedPrice,
                            isLoading,
                        },
                        productClass,
                        purchaseQuantityRule,
                        variationAttributeSet,
                        productSellingModelInformation,
                        urlName,
                        onProductComparePage: true,
                        comparedProductCount: this.productCompareSkus?.length
                    };
                    console.log("transformeddDta ::", JSON.stringify(transformeddDta));
                    return transformeddDta;
                }
            ),
            categoryName: categoryId ? categoryName : undefined
        };
    }

    normalizeSearchResultsWithPricing(pricingData) {
        if (!pricingData) {
            return this.searchResults;
        }
        const productToPricesMap = this.createProductToPricesMap(pricingData?.pricingLineItemResults);

        const productSearchResultsClone = JSON.parse(JSON.stringify(this.searchResults));

        productSearchResultsClone.cardCollection = productSearchResultsClone.cardCollection.map((item) => {
            const product = Object.assign({}, item);
            if (product.id) {
                const id = product.id;
                product.prices.listingPrice = productToPricesMap[id]?.listPrice;
                product.prices.negotiatedPrice = productToPricesMap[id]?.unitPrice;
                product.prices.currencyIsoCode = pricingData?.currencyIsoCode;
                product.prices.isLoading = false;
            }
            return product;
        });

        return productSearchResultsClone;
    }

    createProductToPricesMap(prices) {
        return (prices || []).reduce((pricesMap, price) => {
            const productId = price.productId;
            pricesMap[productId] = price;
            return pricesMap;
        }, {});
    }
}