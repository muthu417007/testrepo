import { LightningElement, api, track, wire } from 'lwc';
import { generateUrl, navigate, NavigationContext } from 'lightning/navigation';
import { AppContextAdapter, SessionContextAdapter } from 'commerce/contextApi';
import { calculateImageSizes, imageSizesDefined } from 'c/bwc_productGalleryUtils';
import { CartStatusAdapter } from 'commerce/cartApi';
import { EVENT, PRODUCT_CLASS, QUANTITY_RULES, FIELD_NAMES } from './constants';
import { Labels } from './labels';
import { ProductAdapter, ProductPricingAdapter } from 'commerce/productApi';
import getActiveColors from '@salesforce/apex/BWC_SwatchController.getActiveColors';
import BWC_UI from '@salesforce/resourceUrl/BodewellTheme';


/**
 * @description An event fired when the add to cart button is clicked.
 * @event SearchProductCard#addproducttocart
 * @type {CustomEvent}
 * @property {object} detail CustomEvent details
 * @property {string} detail.productId
 *   The unique identifier of the product to be added to the cart.
 * @property {number} detail.quantity
 *   The quantity of the product to be added to the cart.
 */

/**
 * @description An event fired when the user indicates a desire to view the details of a product.
 * @event SearchProductCard#showproduct
 * @type {CustomEvent}
 * @property {object} detail CustomEvent details
 * @property {string} detail.productId
 *   The unique identifier of the product.
 * @property {string} detail.productName
 *   The name of the product.
 */

/**
 * @description The product card display-data.
 * @typedef {object} ProductCardData
 * @property {string} id
 *  The ID of the card item.
 * @property {string} name
 *  The name of the card item.
 * @property {(FieldValueData & FieldValueDetailData[])} fields
 *  The fields belonging to the card item.
 * @property {ProductSearchMediaData} image
 *  The image display-data.
 * @property {ProductSearchPricesData} prices
 *  The prices display-data.
 * @property {?string} productClass
 *  Type of the product(Variation, VariationParent or Simple).
 * @property {?PurchaseQuantityRuleData} purchaseQuantityRule
 *  Represents a rule that restricts the quantity of a product that may be purchased.
 * @property {?ProductAttributeSetSummary} variationAttributeSet
 *  A product variation attribute set
 * @property {?ProductSellingModelInformationData} productSellingModelInformation
 *  A product's selling model information.
 */

/**
 * @typedef {object} ProductSellingModelInformationData
 * @property {boolean} isSubscriptionProduct
 *  Whether the product is a subscription product.
 */

/**
 * @description The field value display-data.
 * @typedef {object} FieldValueData
 * @property {?string} value
 *  Value of the field.
 */

/**
 * @description The image display-data.
 * @typedef {object} ProductSearchMediaData
 * @property {string} url
 *  The URL of the card image.
 * @property {string} alternateText
 *  Alternative text for the card image.
 */

/**
 * @typedef {object} ProductMediaData
 * @augments ProductSearchMediaData
 * @property {Array<ImageData>} images
 *  An array of (sub)images, typically used for defining different resources
 *  for different form factors.
 */

/**
 * @typedef {object} ImageData
 * @property {string} sizes
 *  defines a set of source sizes, each containing a media condition and a size value
 * @property {string} srcSet
 *  defines image sources containing an url followed by a whitespace and either a width descriptor or pixel density
 * @property {string} [media]
 *  media condition that defines breakpoint
 *  optional - if unset the SLDS default can be used by setting the _`formFactor`_
 * @property {('mobile' | 'tablet' | 'desktop')} [formFactor]
 *  the SLDS breakpoints for different screen sizes
 */

/**
 * @description The prices display-data.
 * @typedef {object} ProductSearchPricesData
 * @property {string} [listingPrice]
 *  The list price for the card item.
 * @property {string} [negotiatedPrice]
 *  The negotiated price for the card item.
 * @property {string} [currencyIsoCode]
 *  The ISO 4217 currency code of all card item prices in the search result.
 * @property {boolean} isLoading
 *  Whether the price is in the loading state.
 */

/**
 * @description  Representation of Builder Field Item
 * @typedef {object} BuilderFieldItem
 * @property {string} name
 *  The name of the field.
 * @property {string} label
 *  The display label of the field.
 * @property {string} type
 *  The type of the field.
 * @property {boolean} showLabel
 *  Whether to show the field label.
 * @property {string} fontSize
 *  The font size of the field.
 *  Accepted values are: "small", "medium", and "large"
 * @property {string} fontColor
 *  Font color for the field, as 'rgb', 'rgba' or 'hex' CSS value.
 */

/**
 * @description The field display data value.
 * @typedef {object} FieldValueDetailData
 * @property {string} name
 *  The name of the field.
 * @property {string} label
 *  The display label of the field.
 * @property {string} type
 *  The type of the field.
 * @property {string} value
 *  The value of the field.
 * @property {boolean} tabStoppable
 *  The tabStoppable will be assigned accordingly to make only one field in the
 *  card lot to be tab-stoppable in keyboard navigation.
 */

/**
 * @description The Card UI configuration.
 * @typedef {object} ProductCardConfiguration
 * @property {boolean} addToCartDisabled
 *  Whether the add to cart button is disabled.
 * @property {string} addToCartButtonText
 *  The text for the Add to Cart button, a type of "Call to Action" button.
 * @property {string} addToCartButtonProcessingText
 *  The text for the Add to Cart button when cart is processing, a type of "Call to Action" button.
 * @property {string} layout
 *  The layout for the card collection. Card also requires this field for
 *  grid/list layout generation.
 * @property {boolean} showCallToActionButton
 *  Whether to show the "Call to Action" button.
 * @property {boolean} showProductImage
 *  Whether to show the product image.
 * @property {string} viewOptionsButtonText
 *  The text for the View Options button, a type of "Call to Action" button.
 * @property {boolean} showQuantitySelector
 *  Whether to show the quantity rules and inline quantity selector in product card.
 * @property {string} minimumQuantityGuideText
 *  The text showing the minimum quantity value of a product.
 * @property {string} maximumQuantityGuideText
 *  The text showing the maximum quantity value of a product.
 * @property {string} incrementQuantityGuideText
 *  The text showing the increment quantity value of a product.
 * @property {boolean} showQuantityRulesText
 *  Whether to show the quantity rules text in product card.
 * @property {string} quantitySelectorLabelText
 *  The text showing label next to inline quantity selector
 * @property {ResultsFieldConfiguration} fieldConfiguration
 *  The field UI configuration as a map with the field name as key.
 * @property {ProductSearchPriceConfiguration} priceConfiguration
 *  The price UI configuration.
 */

/**
 * @description The field UI configuration.
 * @typedef {object} ResultsFieldConfiguration
 * @property {boolean} showLabel
 *  Whether to show the field label.
 * @property {string} fontSize
 *  The font size of the field.
 *  Accepted values are: "small", "medium", and "large"
 * @property {string} fontColor
 *  Font color for the field, as 'rgb', 'rgba' or 'hex' CSS value.
 */

/**
 * @description The price UI configuration.
 * @typedef {object} ProductSearchPriceConfiguration
 * @property {boolean} showNegotiatedPrice
 *  Whether to show the negotiated price.
 * @property {boolean} showListingPrice
 *  Whether to show the original/list price.
 */

/**
 * @typedef {object} ProductAttributeSetSummary
 * @property {?string} apiName
 *  The API name of the attribute set.
 * @property {?string} label
 *  The label of the attribute set.
 * @property {ProductAttributeSummary[]} attributes
 *  The attributes inside the attribute set.
 */

/**
 * @typedef {object} ProductAttributeSummary
 * @property {string} apiName
 *  The API name of the attribute.
 * @property {string} label
 *  The label of the attribute.
 * @property {number} sequence
 *  The attribute's sequence.
 *  @property {string} value
 *  The attribute value.
 */

/**
 * @typedef {object} ProductField
 * @property {(FieldValueData & FieldValueDetailData)} displayData
 *  The UI display data.
 * @property {ResultsFieldConfiguration} configuration
 *  The field UI configuration.
 */

/**
 * @typedef {object} PurchaseQuantityRuleData
 * @property {number} minimum The minimum allowed value
 * @property {number} maximum The maximum allowed value
 * @property {number} increment The allowed step/increment size
 */

/**
 * @description A UI control to show a product card.
 * @fires SearchProductCard#addproducttocart
 * @fires SearchProductCard#showproduct
 */
export default class bwc_searchProductCard extends LightningElement {
    static renderMode = 'light';

    @track
    _imageSizes = {
        mobile: 0,
        tablet: 0,
        desktop: 0,
    };

    _displayData;
    _navigationContext;
    _productUrl;

    @wire(NavigationContext)
    wiredNavigationContext(context) {
        this._navigationContext = context;
        this.updateCallToActionButtonUrl();
    }

    @wire(SessionContextAdapter)
    sessionContext;

    @wire(AppContextAdapter)
    appContext;

    @wire(CartStatusAdapter)
    cartStatus;

    /**
     * @description Map of color name to product Id, used to get the product Id when user clicks on color swatch
     */
    _colorToProductIdMap = {};

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

    @api
    numProducts;

    @api
    isCompared;

    /**
     * @description Used for centering the color swatch component
     */
    get isCentered() {
        return true;
    }

    /**
     * @description Used for limiting how many colros the color swatch component shows on a row before
     * moving to next row
     */
    get numSwatches() {
        return 6;
    }

    isAvailable;
    /**
     * @description Gets or sets the card display-data.
     * @type {?ProductCardData}
     */

    connectedCallback() {
        //this.addEventListener('availableEvent', this.handleCustomEvent.bind(this));
    }
    handleCustomEvent(event) {
        //this.isAvailable= event.detail;
        // console.log('isavail>>'+event.detail);
    }
    @api handleAvailableEvent(event) {
        //  console.log('event>>>',event);
        //  console.log('eventdetail>>',event.detail);
        this.isAvailable = event.detail;
        //  console.log('this.isAvailable>>>'+this.isAvailable)
    }

     _defaultSku;
     _marketingDescription;
     _isPart;
     _prodSpecAndDetails;
     _isAccessory;
    _swatchConfig;
     _finishedGood;
    _mainImage;
    /**
     * @description Gets or sets the card display-data.
     * @type {ProductCardData}
     */
    @api
    set displayData(data) {
        this._displayData = data;        
        this._originalSku = data.fields.find(field => field.name === 'StockKeepingUnit')?.value;
       console.log("data displayData PC", this._originalSku, JSON.stringify(data));
        // The swatch selector component may not be available so we use setTimeout to run this
        // bit of code after everything else has been executed so that the default color is selected
        setTimeout(x => {
            if (data.defaultColorName) {
                if (this.querySelector('c-bwc_swatch-selector')) {
                    this.querySelector('c-bwc_swatch-selector').value = data.defaultColorName;
                }
            }
           
        }, 0);

        this.updateCallToActionButtonUrl();

        // If the current product is a Parent product get the active color swatches
        console.log("this._displayData", JSON.stringify(this._displayData), this._originalSku);
        if (this._displayData.productClass === 'VariationParent') {
            getActiveColors({ variantParentId: data.id })
                .then(results => {
                    this._colorToProductIdMap = results.map(activeColor => {
                        return {
                            color: activeColor.Color__c,
                            productId: activeColor.ProductId,
                            isDefault: activeColor.Product.bwc_DefaultVariant__c,
                            sku: activeColor.Product.StockKeepingUnit,
                            marketingDescription:  activeColor.Product.BWC_Product_Marketing_Description__c,
							isPart:	activeColor.Product.BWC_Is_Part__c,
							prodSpecAndDetails:	activeColor.Product.BWC_ProductSpecAndDetails__c,
							isAccessory:	activeColor.Product.Is_Accessory__c,
							swatchConfig:	activeColor.Product.bwc_SwatchConfig__c,
							finishedGood:	activeColor.Product.Is_Finished_Good__c,
							mainImage:	activeColor.Product.BWC_Main_Image__c
                        }
                    })
                        .reduce((acc, { color, productId, isDefault, sku,marketingDescription,isPart,prodSpecAndDetails,
                        isAccessory,swatchConfig,finishedGood,mainImage }) => {
                            acc[color] = {
                                productId,
                                isDefault: isDefault,
                                sku: sku,
                                marketingDescription:marketingDescription,
                                isPart:isPart,
                                prodSpecAndDetails:prodSpecAndDetails,
                                isAccessory:isAccessory,
                                swatchConfig:swatchConfig,
                                finishedGood:finishedGood,
                                mainImage:mainImage

                            };
                            return acc;
                        }, {});

                    //Find default color variant, if not found then use the 1st color variant product returned
                    console.log("this._colorToProductIdMap", JSON.stringify(this._colorToProductIdMap), Object.values(this._colorToProductIdMap),this._originalSku);
                    this._defaultVariantProductId = Object.values(this._colorToProductIdMap).filter(x => x.isDefault)[0]?.productId;
                    console.log("_defaultVariantProductId", this._defaultVariantProductId);

                    if (!this._defaultVariantProductId) {
                        this._defaultVariantProductId = Object.values(this._colorToProductIdMap)[0].productId;
                    }
                    console.log("_defaultVariantProductId when defaultVar false", this._defaultVariantProductId);

                    for (let color in this._colorToProductIdMap) {
                        if (this._colorToProductIdMap[color].productId == this._defaultVariantProductId) {
                            this._defaultColorName = color;
                            console.log("this._defaultColorName", this._defaultColorName);
                            this._defaultSku = this._colorToProductIdMap[color].sku;
                            console.log("this._defaultSku", this._defaultSku);
                            this._marketingDescription=this._colorToProductIdMap[color].marketingDescription;
                            this._isPart=this._colorToProductIdMap[color].isPart;
                            this._prodSpecAndDetails=this._colorToProductIdMap[color].prodSpecAndDetails;
                            this._isAccessory=this._colorToProductIdMap[color].isAccessory;
                            this._swatchConfig=this._colorToProductIdMap[color].swatchConfig;
                            this._finishedGood=this._colorToProductIdMap[color].finishedGood;
                            this._mainImage=this._colorToProductIdMap[color].mainImage;
                        }
                    }
                })
                .catch(error => {
                    console.log(`bwc_searchProductCard::displayData::Error = ${JSON.stringify(error)}`);
                });
        }
    }

    /**
     * @description Getter for the display data.
     * @type {?object}
     * @readonly
     * @private
     */
    get displayData() {
        return this._displayData;
    }

    /**
     * @description Checks if the product is on sale, based on the _displayData property.
     * @type {?boolean}
     * @readonly
     * @private
     */
    get isOnSale() {
        return this._displayData?.isOnSale;
    }

    /**
     * @description Checks if the product is on clearance by looking for the 'BWC_Clearance__c' field in the _displayData property.
     * @type {?boolean}
     * @readonly
     * @private
     */
    get isOnClearance() {
        return this._displayData?.isOnClearance;
    }

    // This section of code makes 2 fetch calls to data adapters to get product data
    // and price data for the default variant product so that info in the product card reflects
    // the default variant and not the variation parent
    _defaultVariantProductId;
    _defaultColorName;
    _defaultVariantData;
    _defaultVariantQuantity;

    /**
     * @description Returns product data for a specific product Id
     *
     * Note:
     * The example below is pretty long hence, its on one line. You can reformat it to see the full JSON structure.
     * @example
     * { "attributeSetInfo": { "Color": { "attributeInfo": { "Color__c": { "allowableValues": ["Stainless Steel", "Light Gray", "Custom Panel and Handle Required", "Almond on almond"], "apiName": "Color__c", "availableValues": ["Stainless Steel", "Fingerprint Resistant Slate", "Fingerprint Resistant Stainless"], "fieldEnumOrId": "00N8B0000083iqR", "label": "Color", "objectName": "ProductAttribute", "sequence": 0 } }, "description": null, "developerName": "Color", "id": "0iY8B00000000E3UAI", "masterLabel": "Color", "sequence": null } }, "defaultImage": { "alternateText": "", "contentVersionId": null, "id": null, "mediaType": "Image", "sortOrder": 0, "thumbnailUrl": null, "title": "image", "url": "/img/b2b/default-product-image.svg" }, "fields": { "ADA_Compliant__c": null, "Carton_Height__c": "73.3", "Carton_Width__c": "33.2", "CloneSourceId": null, "Connectivity_Type__c": "RJ45 Newfi only", "CreatedById": "0054P00000C3cPn", "CreatedDate": "2021-02-01T14:30:52Z", "Custom_Fields__c": null, "Description__c": "21.9 Cu Ft, LED, Glass FZ Shelves", "Description": "Profile 22 cuft Counter-Depth SxS", "Display_Name__c": "GE Profile Series | PZS22MYKFS", "DisplayUrl": null, "ExternalId": null, "Family": null, "Is_Accessory__c": "No", "Is_Finished_Good__c": "Yes", "IsActive": "true", "IsArchived": "false", "IsDeleted": "false", "IsSerialized": "false", "LastModifiedById": "0058B000002hlef", "LastModifiedDate": "2023-11-22T22:35:28Z", "LastReferencedDate": null, "LastViewedDate": null, "Name": "GE Profile-PZS22MYKFS", "ProductClass": "Variation", "ProductCode": "52141501", "QuantityUnitOfMeasure": null, "RecordTypeId": "0124P000000uVy3", "StockKeepingUnit": "PZS22MYKFS", "SystemModstamp": "2023-11-22T22:35:28Z", "Type": null, "UserRecordAccessId": null }, "id": "01t4P00000BWztVQAT", "mediaGroups": [{ "developerName": "productListImage", "id": "2mg4P0000008P3xQAE", "mediaItems": [{ "alternateText": "", "contentVersionId": null, "id": null, "mediaType": "Image", "sortOrder": 0, "thumbnailUrl": null, "title": "image", "url": "/img/b2b/default-product-image.svg" }], "name": "Product List Image", "usageType": "Listing" }, { "developerName": "productDetailImage", "id": "2mg4P0000008P3wQAE", "mediaItems": [{ "alternateText": "", "contentVersionId": null, "id": null, "mediaType": "Image", "sortOrder": 0, "thumbnailUrl": null, "title": "image", "url": "/img/b2b/default-product-image.svg" }], "name": "Product Detail Images", "usageType": "Standard" }], "primaryProductCategoryPath": { "path": [{ "description": null, "id": "0ZG8B00000007P3WAI", "name": "Appliances", "urlName": null }, { "description": null, "id": "0ZG8B00000007PCWAY", "name": "Refrigeration", "urlName": null }] }, "productClass": "Variation", "purchaseQuantityRule": null, "urlName": null, "variationAttributeSet": { "attributes": { "Color__c": "Fingerprint Resistant Stainless" }, "developerName": "Color", "id": "0iU8B0000000PrOUAU" }, "variationInfo": { "attributesToProductMappings": [{ "canonicalKey": "Fingerprint Resistant Stainless", "productId": "01t4P00000BWztVQAT", "selectedAttributes": [{ "apiName": "Color__c", "label": "Color", "sequence": 0, "value": "Fingerprint Resistant Stainless" }], "urlName": null }, { "canonicalKey": "Fingerprint Resistant Slate", "productId": "01t4P00000BWIBwQAP", "selectedAttributes": [{ "apiName": "Color__c", "label": "Color", "sequence": 0, "value": "Fingerprint Resistant Slate" }], "urlName": null }, { "canonicalKey": "Stainless Steel", "productId": "01t4P00000BWIBvQAP", "selectedAttributes": [{ "apiName": "Color__c", "label": "Color", "sequence": 0, "value": "Stainless Steel" }], "urlName": null }], "variationAttributeInfo": { "Color__c": { "allowableValues": ["Stainless Steel", "Light Gray", "Custom Panel and Handle Required", "Almond on almond", "White on White", "Black", "White", "Cool White", "Bisque on Bisque", "Light Cool Gray", "Ruby Red", "Flat Black", "Stainless Steel/Black", "Cameo White", "Brushed Bronze", "Fingerprint Resistant Slate", "Bisque", "Stainless Steel/Gray", "Vermillion Red", "Gray", "Matte White", "Black on Black", "Stainless with Black Case", "High-Gloss Black", "Fingerprint Resistant Black Stainless", "Brushed Copper", "Brass", "Diamond Gray", "Champagne", "High-Gloss White", "Matte Black", "Custom Panels Required", "Brushed Black", "Stainless Steel on Black", "Chrome", "CleanSteelâ„¢", "Warm Gray Beige", "Almond", "Stainless (With Gray Case)", "White on White with Silver Backsplash", "Panel Required", "Grey-Beige", "Glass Canopy", "Silver", "Stainless Steel-Wrapped", "Soft Gray", "Fingerprint Resistant Black Slate", "True White", "White/Olive", "Fingerprint Resistant Stainless", "Metallic Silver", "Silver Metallic", "Graphite Metallic", "Steel Silver", "Brushed Brass", "CleanSteelâ„¢ Appearance", "Black Stainless", "Grey", "True Bisque", "Titanium on White", "Titanium", "Satin Nickel", "Platinum Glass", "High Gloss Bisque", "Granite Gray", "Carbon Black", "Light Cool Grey", "Glass", "Pigeon Gray", "Textured White", "Sapphire Blue", "Anodized Aluminum", "Metallic Red", "White/Stainless Steel", "Stainless Metallic", "Brushed Aluminum", "Metallic Carbon", "Carbon Graphite", "True Bisque on True Bisque", "Brushed Nickel", "Door Panels Required", "Black/Stainless Steel", "Soft Stainless", "No Color", "Medium Cool Grey", "White with Clear Accents", "Brushed Stainless", "Dark Platinum", "Graphite", "Metallic", "Fingerprint Resistant Stainless Steel", "Stainless Steel/Professional", "Woodgrain", "White with Matte Black Backsplash", "Silver on Gray", "Textured Bisque", "Stone White", "Brushed Chrome", "Virtual Steel", "Stratus Grey", "Red", "Black Painted Steel", "Warm Gray Metallic", "Oil Rubbed Bronze", "Maple", "Medium Cool Gray", "Stainless Steel Appearance", "Mineral Silver", "Camouflage", "Aluminum", "Charcoal", "Textured Black", "Black Case with Stainless Trim", "Stainless", "Nickel", "Green", "Clear with White Accents", "Silver Metallic/Dark Gray", "Oil-Rubbed Bronze"], "apiName": "Color__c", "availableValues": ["Stainless Steel", "Fingerprint Resistant Slate", "Fingerprint Resistant Stainless"], "fieldEnumOrId": "00N8B0000083iqR", "label": "Color", "objectName": "ProductAttribute", "sequence": 0 } } }, "variationParentId": "01t8B000009eJ9qQAE" }
     * @param {String} productId
     */
    @wire(ProductAdapter, {
        productId: '$_defaultVariantProductId'
    })
    wireDefaultVariantProduct({ data }) {
        if (data) {
            this._defaultVariantData = data;
            this._defaultVariantQuantity = 1;  //Triggers wireProductPrice
        }
    }

    /**
     * @description Gets product pricing data
     *
     * Note:
     * The example below is pretty long hence, its on one line. You can reformat it to see the full JSON structure.
     * @example
     * {
            "currencyIsoCode": "USD",
            "listPrice": null,
            "lowestUnitPrice": null,
            "priceAdjustment": null,
            "pricebookEntryId": "01u8B00000c92aIQAQ",
            "productPriceEntries": [
                {
                "error": {},
                "listPrice": null,
                "lowestUnitPrice": null,
                "priceAdjustment": null,
                "pricebookEntryId": "01u8B00000c92aIQAQ",
                "productSellingModelId": null,
                "success": true,
                "unitPrice": "1400"
                }
            ],
            "productSellingModelId": null,
            "unitPrice": "1400",
            "negotiatedPrice": "1400"
        }
     */
    _productPricing;

    @wire(ProductPricingAdapter, {
        productId: '$_defaultVariantProductId',
        qauntity: '$_defaultVariantQuantity'
    })
    wireProductPrice({ data }) {
        if (data) {
            // Create a copy of the current product data and update it with the default Variation Product
            // data that was retrieved for the Variation Parent. The Variation Parent Id and default Variation Product
            // data are then sent back to the parent lwc (bwc_searchProductGrid) (via an event) to replace the
            // Variation Parent in its list of products.
            this._productPricing = data;
            console.log('productPricing->',this._productPricing);
            let originalProductId = this._displayData.id;
            console.log('this.displayData->',this._displayData);
            let displayDataClone = JSON.parse(JSON.stringify(this._displayData));
            displayDataClone.id = this._defaultVariantProductId;
            displayDataClone.name = this._defaultVariantData?.fields?.Name;

            for (let i = 0; i < displayDataClone.fields.length; i++) {
                let name = displayDataClone.fields[i].name;
                if (this._defaultVariantData?.fields[name]) {
                    displayDataClone.fields[i].value = this._defaultVariantData?.fields[name];
                }
            }

            displayDataClone.fieldsMap = displayDataClone.fieldsMap || {};
            for (let field in displayDataClone.fieldsMap) {
                if (this._defaultVariantData?.fields[field]) {
                    displayDataClone.fieldsMap[field] = this._defaultVariantData?.fields[field];
                }

            }


            displayDataClone.prices.currencyIsoCode = this._productPricing.currencyIsoCode;
            displayDataClone.prices.listingPrice = this._productPricing.unitPrice;
            displayDataClone.prices.negotiatedPrice = this._productPricing.negotiatedPrice;
            displayDataClone.purchaseQuantityRule = this._defaultVariantData?.purchaseQuantityRule;
            displayDataClone.productClass = this._defaultVariantData?.productClass;
            displayDataClone.colorToProductIdMap = this._colorToProductIdMap;
            displayDataClone.defaultColorName = this._defaultColorName;
            
            // To show the defaultSku on UI
            displayDataClone.defaultSku = this._defaultSku;
            displayDataClone.fields.map(field => {
                if (field.name == 'StockKeepingUnit') {
                    field.value = this._defaultSku;
                } return false;
            });

            console.log("this._colorToProductIdMap", JSON.stringify(this._colorToProductIdMap));
            if(this._defaultSku == this._colorToProductIdMap[this._defaultColorName].sku){
            displayDataClone.fieldsMap.StockKeepingUnit=this._defaultSku;
            displayDataClone.fieldsMap.BWC_Main_Image__c=this._mainImage;
            displayDataClone.fieldsMap.Is_Finished_Good__c=this._finishedGood;
            displayDataClone.fieldsMap.bwc_SwatchConfig__c=this._swatchConfig;
            displayDataClone.fieldsMap.Is_Accessory__c=this._isAccessory;
            displayDataClone.fieldsMap.BWC_ProductSpecAndDetails__c=this._prodSpecAndDetails;
            displayDataClone.fieldsMap.BWC_Is_Part__c=this._isPart;
            displayDataClone.fieldsMap.BWC_Product_Marketing_Description__c=this._marketingDescription;
            }
            this._displayData = displayDataClone;
            //this.displayData(displayDataClone);
            this._originalSku = displayDataClone.fields.find(field => field.name === 'StockKeepingUnit')?.value;

            console.log("cloned this._displayData", JSON.stringify(this._displayData), this._originalSku);

            // This triggers an update in the parent lwc (bwc_searchProductGrid) which in turn causes the UI to update
            // which in turn causes this lwc to get updated again.  This 2nd round of updates will now be using the
            // default Variation product data since the Variation Parent data has now been over-written in the parent lwc.
            this.dispatchEvent(
                new CustomEvent(EVENT.PRODUCT_CHANGED, {
                    detail: {
                        productId: originalProductId,
                        defaultVariationProduct: displayDataClone
                       

                    }

                })
            );
           
        }
    }

    /**
     * @description Gets or sets the card UI configuration.
     * @type {?ProductCardConfiguration}
     */
    @api
    configuration;

    @api
    focus() {
        if (this.configuration?.showCallToActionButton) {
            const focusTarget = this.querySelector('c-common-link') || this.querySelector('c-common-button');
            focusTarget?.focus();
        } else {
            const index = this.fields?.findIndex((field) => field.displayData.tabStoppable) || 0;
            const focusTarget = Array.from(this.querySelectorAll('c-search-product-field'))[index];
            focusTarget?.focus();
        }
    }

    /**
     * @description Gets the prices display-data.
     * @type {ProductSearchPricesData}
     * @readonly
     * @private
     */
    get pricingInfo() {
        const prices = this.displayData?.prices;
        return {
            negotiatedPrice: prices?.negotiatedPrice ?? '',
            listingPrice: prices?.listingPrice ?? '',
            currencyIsoCode: prices?.currencyIsoCode ?? '',
            isLoading: !!prices?.isLoading,
        };
    }

    /**
     * @description Gets the aria-label for the Add to Cart button, a type of CTA button
     * @type {string}
     * @readonly
     * @private
     */
    get addToCartButtonAriaLabel() {
        if (this.displayData?.name) {
            return Labels.addToCartAriaLabel.replace('{productTitle}', this.displayData.name);
        }
        return '';
    }

    /**
     * @description Gets the aria-label for the View Options button, a type of CTA button
     * @type {string}
     * @readonly
     * @private
     */
    get viewOptionsButtonAriaLabel() {
        if (this.displayData?.name) {
            return Labels.viewOptionsAriaLabel.replace('{productTitle}', this.displayData.name);
        }
        return '';
    }

    /**
     * @description Gets a merged representation of BuilderFieldItem.
     * NOTE: This code looks for a special field named "bwc_SwatchConfig__c" which is used
     * for color swatch functionality.
     * @type {ProductField[]}}
     * @readonly
     * @private
     * @returns a copy of the fields stored in this.displayData.fields but augmented with a new element
     * for color swatches if the product has a swatch configuration.
       @example A before and after example of the displayData.fields
       BEFORE:
        [ { "name": "Name", "label": "Product Name", "value": "Cafe 36\" Oven - Child - Stainless Steel", "tabStoppable": false }, { "name": "StockKeepingUnit", "label": "SKU", "value": "Cafe36-StainlessSteel", "tabStoppable": false } ]
       AFTER:
        [ { "name": "Name", "hasSwatchColorConfig": false, "displayData": { "name": "Name", "label": "Product Name", "value": "Cafe 36\" Oven - Child - Stainless Steel", "tabStoppable": false }, "configuration": { "fontSize": "medium", "showLabel": false } }, { "name": "StockKeepingUnit", "hasSwatchColorConfig": false, "displayData": { "name": "StockKeepingUnit", "label": "SKU", "value": "Cafe36-StainlessSteel", "tabStoppable": false }, "configuration": { "fontSize": "medium", "showLabel": false } }, { "name": "ColorSwatches", "hasSwatchColorConfig": true, "swatchItems": [ { "label": "Matte White", "value": "Matte White", "url": "https://cdn11.bigcommerce.com/s-pacto3wrn2/content/swatch-images/swatch_matte_white.jpg" }, { "label": "Matte Black", "value": "Matte Black", "url": "https://cdn11.bigcommerce.com/s-pacto3wrn2/content/swatch-images/swatch_matte_black.jpg" }, { "label": "Stainless Steel", "value": "Stainless Steel", "url": "https://cdn11.bigcommerce.com/s-pacto3wrn2/content/swatch-images/swatch_stainless_steel.jpg" } ] } ]
      */
    get fields() {
        let clonedFields = this.displayData.fields.map(field => {
            console.log('this.displayData-->', JSON.stringify(this.displayData));
            return {
                name: field.name,
                hasSwatchColorConfig: false,
                displayData: field,
                configuration: this.configuration?.fieldConfiguration[field.name] ?? {}
            }
        });
        const shouldProcessColorSwatches = !!this.displayData?.fieldsMap?.[FIELD_NAMES.SWATCH_CONFIG] && !!this.displayData.colorToProductIdMap;
        console.log("shouldProcessColorSwatches", JSON.stringify(shouldProcessColorSwatches));
        if (shouldProcessColorSwatches) {
            const swatchConfigValue = JSON.parse(this.displayData.fieldsMap[FIELD_NAMES.SWATCH_CONFIG]);
            const hasSwatchColorConfig = !!swatchConfigValue?.color;
            if (hasSwatchColorConfig) {
                const swatchItems = Object.keys(swatchConfigValue.color)
                    .filter(color => {
                        return Object.keys(this.displayData.colorToProductIdMap).includes(color);
                    })
                    .map(color => {
                        return {
                            label: color,
                            value: color,
                            url: swatchConfigValue.color[color]
                        }
                    });
                //Add the color swatch field to the list of fields
                clonedFields.push({
                    name: 'ColorSwatches',
                    hasSwatchColorConfig,
                    swatchItems
                })
            }
        }
        console.log("clonedFields", JSON.stringify(clonedFields));
        return clonedFields;

    }

    /**
     * @description Gets the default image
     * @type {ProductMediaData}
     * @readonly
     * @private
     */
    get image() {
        calculateImageSizes(this.querySelector('.imageArea'), this._imageSizes);
        // const img = this.displayData?.image;
        // console.log('@@@find display data ' + JSON.stringify(this.displayData));
        const altText = this.displayData?.name ?? 'Bodewell';
        const img = (this.displayData?.fieldsMap?.BWC_Main_Image__c) ? this.resizeImage(this.displayData?.fieldsMap?.BWC_Main_Image__c) : BWC_UI + '/img/Image-Not-Avail.png';

        return {
            // alternateText: img?.alternateText ?? '',
            alternateText: altText,
            url: img,
            // url: resolve(img?.url ?? '', false, {
            //     height: 460,
            //     width: 460,
            // }),
            // images:
            //     img?.url && isCmsResource(img?.url) && imageSizesDefined(this._imageSizes)
            //         ? createImageDataMap(img.url, this._imageSizes, [1, 2])
            //         : [],
        };
    }

    resizeImage(img) {
        // Update the PLP/Search Salsify image size. The images loaded on the Product are 2000px or 3000px big
        // Updating the intrinisic size with string replace and adding width & height
        let size = '--/w_225,h_225/';
        let formattedSize = img.replace('--/', size);
        return formattedSize;
    }

    /**
     * @description Gets the container class for the card. The container class will vary
     * depending upon the layout property.
     * @type {string}
     * @readonly
     * @private
     */
    get cardContainerClass() {
        return this.isGridLayout ? 'cardContainerGrid' : 'cardContainerList';
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
     * @description Gets the variant to apply to the action buttons.
     * @type {('primary' | 'secondary' | 'tertiary')}
     * @readonly
     * @private
     */
    get actionButtonVariant() {
        const section = this?.querySelector('section');
        const variant =
            section && getComputedStyle(section).getPropertyValue('--ref-c-search-product-card-button-variant');
        return ['primary', 'secondary', 'tertiary'].includes(variant) ? variant : 'primary';
    }

    /**
     * @description Get the text for minimum quantity guide
     * @type {?string}
     * @readonly
     * @private
     */
    get minimumText() {
        const min = Number.parseInt(this.quantityRules?.minimum ?? '', 10);
        return this.configuration?.minimumQuantityGuideText.replace('{0}', `${min}`);
    }

    /**
     * @description Get the text for maximum quantity guide
     * @type {?string}
     * @readonly
     * @private
     */
    get maximumText() {
        const max = Number.parseInt(this.quantityRules?.maximum ?? '', 10);
        return this.configuration?.maximumQuantityGuideText.replace('{0}', `${max}`);
    }

    /**
     * @description Get the text for increment quantity guide
     * @type {?string}
     * @readonly
     * @private
     */
    get incrementText() {
        const increment = Number.parseInt(this.quantityRules?.increment ?? '', 10);
        return this.configuration?.incrementQuantityGuideText.replace('{0}', `${increment}`);
    }

    /**
     * @description Whether the quantity provided is valid
     * @type {boolean}
     * @private
     */
    isQuantityValid = true;

    /**
     * @description Gets or sets whether the 'add to cart' button is disabled
     * @type {boolean}
     * @readonly
     * @private
     */
    get addToCartButtonDisabled() {
        const hasNegotiatedPrice = !!this.displayData?.prices?.negotiatedPrice;
        console.log('this.isAvailable2222>>>' + this.isAvailable);
        console.log('isCartProcessing>>' + this.isCartProcessing);
        console.log('this.configuration?.addToCartDisabled>>' + this.configuration?.addToCartDisabled);
        console.log('!this.isQuantityValid>>' + this.isQuantityValid);
        console.log('hasNegotiatedPrice>>' + hasNegotiatedPrice);
        if (this.isAvailable !== undefined) {
            if (this.isAvailable === false) {
                return 'true';
            }
            else {
                return this.isCartProcessing || this.configuration?.addToCartDisabled || !this.isQuantityValid || !hasNegotiatedPrice;
            }
        }
    }

    /**
     * @description The computed text for add to cart button.
     * @type {?string}
     * @readonly
     * @private
     */
    get addToCartButtonText() {
        return this.isCartProcessing && this.configuration?.addToCartButtonProcessingText
            ? this.configuration?.addToCartButtonProcessingText
            : this.configuration?.addToCartButtonText;
    }

    /**
     * @description Handler for the 'validationchanged' event fired from the
     * 'quantity-selector'
     * @param {CustomEvent} evt the event object
     * @private
     */
    handleValueChanged(evt) {
        this.isQuantityValid = evt.detail.isValid;
    }

    /**
     * @description Get all the quantity rules for quantity selector
     * @type {?PurchaseQuantityRuleData}
     * @readonly
     * @private
     */
    get quantityRules() {
        if (!this.displayData?.purchaseQuantityRule && this.configuration?.showQuantitySelector) {
            return {
                minimum: QUANTITY_RULES.DEFAULT_MIN.toString(),
                maximum: QUANTITY_RULES.DEFAULT_MAX.toString(),
                increment: QUANTITY_RULES.DEFAULT_INCREMENT.toString(),
            };
        }
        return this.displayData?.purchaseQuantityRule;
    }

    /**
     * @description The minimum quantity of the product that may be purchased
     * @type {?string}
     * @readonly
     * @private
     */
    get quantityRuleMinimum() {
        return this.quantityRules?.minimum;
    }

    /**
     * @description The maximum quantity of the product that may be purchased
     * @type {?string}
     * @readonly
     * @private
     */
    get quantityRuleMaximum() {
        return this.quantityRules?.maximum;
    }

    /**
     * @description The increment quantity of the product that is allowed to be purchased
     * @type {?string}
     * @readonly
     * @private
     */
    get quantityRuleIncrement() {
        return this.quantityRules?.increment;
    }

    /**
     * @description Get the label next to the inline quantity selector
     * @type {?string}
     * @readonly
     * @private
     */
    get quantitySelectorLabelText() {
        return this.configuration?.quantitySelectorLabelText;
    }

    /**
     * @description Gets all the quantity rules (merge min, max and increment text into one line)
     * @type {string}
     * @readonly
     * @private
     */
    get quantityRuleCombinedText() {
        const rules = [this.minimumText, this.maximumText, this.incrementText];
        return rules.filter((item) => item).join(' • ');
    }

    /**
     * @description Gets whether the "Call To Action" button is View Options button
     * @type {boolean}
     * @readonly
     * @private
     */
    get isCTAButtonViewOptions() {
        console.log('isCTAButtonViewOptions',this.displayData.productClass,this.displayData?.fieldsMap?.StockKeepingUnit, JSON.stringify(this.quantityRules),this.configuration.showQuantitySelector,this.isSubscriptionProduct);
        return (
            this.displayData?.productClass === PRODUCT_CLASS.VARIATION_PARENT ||
            this.displayData?.productClass === PRODUCT_CLASS.SET ||
            ((this.displayData?.productClass === PRODUCT_CLASS.SIMPLE ||
                this.displayData?.productClass === PRODUCT_CLASS.VARIATION) &&
                Boolean(this.quantityRules) &&
                !this.configuration?.showQuantitySelector) ||
            this.isSubscriptionProduct
        );
    }

    /**
     * @description Gets whether the "Call To Action" button is Add to cart button
     * @type {boolean}
     * @readonly
     * @private
     */
    get isCTAButtonAddToCart() {
        console.log('isCTAButtonAddToCart',this.displayData.productClass,this.displayData?.fieldsMap?.StockKeepingUnit, JSON.stringify(this.quantityRules),this.configuration.showQuantitySelector,this.isSubscriptionProduct);

        return (
            this.displayData?.productClass === PRODUCT_CLASS.SIMPLE ||
            this.displayData?.productClass === PRODUCT_CLASS.VARIATION ||
            this.displayData?.productClass === PRODUCT_CLASS.VARIATIONPARENT
        );
    }

    /**
     * @description Whether the to show inline quantity selector
     * @type {boolean}
     * @readonly
     * @private
     */
    get showInlineQuantitySelector() {
        return !!(this.quantityRules && this.configuration?.showQuantitySelector);
    }

    /**
     * @description Whether the to show inline quantity selector rules text
     * @type {boolean}
     * @readonly
     * @private
     */
    get showInlineQuantitySelectorText() {
        return !!(
            !this.isCTAButtonViewOptions &&
            this.configuration?.showQuantitySelector &&
            this.configuration?.showQuantityRulesText &&
            this.displayData?.purchaseQuantityRule
        );
    }

    /**
     * @description Click event handler for product card which navigates to the product detail page
     * @param {MouseEvent | KeyboardEvent} event The mouse event on click
     * @private
     * @fires SearchProductCard#showproduct
     */
    handleProductDetailPageNavigation(event) {
        event.preventDefault();
        const productId = this.displayData?.id;
        const productName = this.displayData?.name;

        this.dispatchEvent(
            new CustomEvent(EVENT.SHOW_PRODUCT_EVT, {
                detail: {
                    productId,
                    productName,
                },
            })
        );
    }

    /**
     * @description Whether the product is a subscription product
     * @type {boolean}
     * @readonly
     * @private
     */
    get isSubscriptionProduct() {
        return this.displayData?.productSellingModelInformation?.isSubscriptionProduct ?? false;
    }
    get subscriptionOptionsLabelText() {
        return Labels.subscriptionOptionLabel;
    }

    /**
     * @description Whether to show price information.
     * Don't show price if both show listing and negotiated prices are disabled.
     * @type {boolean}
     * @readonly
     * @private
     */
    get showPrice() {
        const { showListingPrice, showNegotiatedPrice } = this.configuration?.priceConfiguration || {};
        return !!(showListingPrice || showNegotiatedPrice);
    }
    get showNegotiatedPrice() {
        return !!this.configuration?.priceConfiguration?.showNegotiatedPrice;
    }
    get showOriginalPrice() {
        return !!this.configuration?.priceConfiguration?.showListingPrice;
    }

    /**
     * @description Gets the class list to apply to the internal div element
     * @type {string}
     * @readonly
     * @private
     */
    get quantitySelectorClassList() {
        const classes = [];
        if (this.showInlineQuantitySelector) {
            classes.push('quantitySelectorContainer');
            if (this.isGridLayout) {
                classes.push('stacked');
            }
        }
        return classes.join(' ');
    }

    /**
     * @description Whether to show the showProductImage
     * @type {boolean}
     * @readonly
     * @private
     */
    get showProductImage() {
        return this.configuration?.showProductImage ?? false;
    }

    /**
     * @description Whether to show the showCallToActionButton
     * @type {boolean}
     * @readonly
     * @private
     */
    get showCallToActionButton() {
        return this.configuration?.showCallToActionButton ?? false;
    }

    /**
     * @description Gets whether the cart is processing or still loading.
     * @type {boolean}
     * @readonly
     * @private
     */
    get isCartProcessing() {
        return !!this.cartStatus?.data?.isProcessing || !!this.cartStatus?.loading;
    }

    /**
     * @description If add to cart is enabled based on guest permission.
     * @type {boolean}
     * @readonly
     * @private
     */
    get isAddToCartEnabled() {
        const isLoggedIn = Boolean(this.sessionContext?.data?.isLoggedIn);
        const guestCartEnabled = Boolean(this.appContext?.data?.guestCartEnabled);
        return isLoggedIn || guestCartEnabled;
    }

    get shouldDisplayProductCompareClose() {
        let comparedProductCount = this.displayData?.comparedProductCount ?? 0;
        return this.displayData?.onProductComparePage && (comparedProductCount > 2);
    }

    get shouldDisplayProductCompare() {
        console.log('shouldDisplayProductCompare ProductCard',this.displayData?.shouldDisplayProductCompare,!this.displayData?.onProductComparePage, JSON.stringify(this.displayData));
        return this.displayData?.shouldDisplayProductCompare && !this.displayData?.onProductComparePage;
    }

    _originalSku;
    get productCompareSku() {
        console.log("original SKU to PC", this._originalSku);
        return this._originalSku;
    }

    disconnectedCallback() {
        this.querySelector('.closeProductCompare')?.removeEventListener('click', event => {
            console.log(`closeProductCompare`);
        });
    }

    _productCompareCloseListenerAdded;
    renderedCallback() {
        if (!this._productCompareCloseListenerAdded) {
            this.querySelector('.closeProductCompare')?.addEventListener('click', event => {
                this.dispatchEvent(
                    new CustomEvent(EVENT.CLOSE_PRODUCT_COMPARE, {
                        bubbles: true,
                        detail: {
                            sku: this.displayData.fields.find(field => field.name === 'StockKeepingUnit')?.value
                        },
                    })
                );
            });
            this._productCompareCloseListenerAdded = true;
        }
        calculateImageSizes(this.querySelector('.imageArea'), this._imageSizes);
    }

    handleAddToCart() {
        if (!this.isAddToCartEnabled) {
            this.navigateToLogin();
            return;
        }
        if (this.isCartProcessing) {
            return;
        }
        const productId = this.displayData?.id;
        const quantity = this.quantityRules?.minimum || 1;
        this.dispatchEvent(
            new CustomEvent(EVENT.ADD_PRODUCT_TO_CART_EVT, {
                detail: {
                    productId,
                    quantity,
                },
            })
        );
    }

    /**
     * @description Handle the keydown event from product image and name.
     * @param {KeyboardEvent} evt the event object
     * @private
     */
    handleKeydown(evt) {
        if (evt.key === 'Enter') {
            this.handleProductDetailPageNavigation(evt);
        }
    }

    /**
     * @description Handler for the 'click' event fired from the add to cart button
     * which should redirect the user to the login page
     * @private
     */
    navigateToLogin() {
        navigate(this._navigationContext, {
            type: 'comm__namedPage',
            attributes: {
                name: 'Login',
            },
        });
    }

    updateCallToActionButtonUrl() {
        if (this._navigationContext && this?._displayData?.id) {
            this._productUrl = generateUrl(this._navigationContext, {
                type: 'standard__recordPage',
                attributes: {
                    objectApiName: 'Product2',
                    recordId: this._displayData.id,
                    actionName: 'view',
                },
            });
        }
    }

    handleOnChanged(e) {
        let selectedColor = this.querySelector('c-bwc_swatch-selector').value;
        let variantProductId = this.displayData.colorToProductIdMap[selectedColor].productId;
        navigate(this._navigationContext, {
            type: 'standard__recordPage',
            attributes: {
                objectApiName: 'Product2',
                recordId: variantProductId,
                actionName: 'view'
            }
        });
    }
}