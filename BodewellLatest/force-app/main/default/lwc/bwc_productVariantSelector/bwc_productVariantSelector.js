import { api, LightningElement, track, wire } from 'lwc';
import { VARIANT_SELECTED_EVT } from './constants';
import { Labels } from './labels';
import { getAvailableOptions, getVariantStateFromProduct } from './productVariantSelectorUtils';
export { isVariantSupportedProductClass } from './productVariantSelectorUtils';
import { publish, MessageContext } from 'lightning/messageService';
import HARDWARE_SELECTED_CHANNEL from '@salesforce/messageChannel/BWC_HardwareSelected__c';
import getCustomHardwarePrices from '@salesforce/apex/BWC_SwatchController.getCustomHardwarePrices';

/**
 * @typedef {{[key: string]: *}} JsonData
 */

/**
 * An event fired when the user changes the variant selection
 * @event ProductVariantSelector#variantselected
 * @type {CustomEvent}
 * @property {object} detail CustomEvent details
 * @property {boolean} detail.isValid
 *  Represents whether the selected _`options`_ are valid, i.e. relate
 *  to an existing variant.
 * @property {Array<string>} detail.options
 *  The selected variant options.
 * @property {string} [detail.productId]
 *  The unique product identifier the selected _`option`_s relate to.
 * @property {string} [detail.urlName]
 *  The product URL the selected _`option`_s relate to.
 */

/**
 * @description Displays a list of dropdowns that represent the variant attributes
 * associated with a product. On each dropdown change it emits a `variantselected` event.
 * The width should be set by the consumer as it consumes all available width allocated.
 * If the product is configured for color swatches, then display a row of color images instead
 * of a dropdown.
 * @fires ProductVariantSelector#variantselected
 */
export default class bwc_ProductVariantSelector extends LightningElement {
    static renderMode = 'light';

    /**
     * @description A product variant attribute value option
     * @typedef {object} VariantOption
     * @property {string} label
     *  The label for the item option
     * @property {string} value
     *  The value for the item option
     */

    /**
     * @description A product variant attribute
     * @example
     * {
     *   id: 'item1',
     *   label: 'Item 1',
     *   options: [
     *     { label: 'Option 1', value: 'item1-option1' },
     *     { label: 'Option 2', value: 'item1-option2' },
     *     { label: 'Option 3', value: 'item1-option3' },
     *   ]
     * }
     * @typedef {object} Variant
     * @property {string} id
     *  A unique id for each item
     * @property {string} label
     *  A label for the item
     * @property {VariantOption[]} options
     *  A list of options for the item
     */

    /**
     * @description A normalized product variant attribute value option
     * @typedef {object} NormalizedVariantOption
     * @property {string} label
     *  The label for the item option
     * @property {string} value
     *  The value for the item option
     * @property {boolean} [disabled]
     *  Whether the option is disabled (Optional)
     * @property {boolean} [selected]
     *  Whether the option is currently selected (Optional)
     */

    /**
     * @description A product variant attribute with optional 'selected'
     * and 'disabled' properties in the options
     * @example
     * {
     *   id: 'item1',
     *   label: 'Item 1',
     *   value: 'item1-option3',
     *   options: [
     *     { label: 'Option 1', value: 'item1-option1' },
     *     { label: 'Option 2', value: 'item1-option2', disabled: true },
     *     { label: 'Option 3', value: 'item1-option3', selected: true },
     *   ]
     * }
     * @typedef {object} NormalizedVariant
     * @property {string} id
     *  A unique id for each item
     * @property {string} label
     *  A label for the item
     * @property {NormalizedVariantOption[]} options
     *  A list of options for the item
     */

    /**
     * @description An object representing a variant selector's current validation state
     * @typedef {object} ValidityState
     * @property {boolean} valueMissing
     *  True, if we are missing one or more variant selections from the user; otherwise, false
     * @property {boolean} badInput
     *  True, if the user selected options are not valid for the current list of validOptions; otherwise, false
     * @property {boolean} valid
     *  True, if the component meets all the validation constraints; otherwise, false
     */

    /**
     * @description An object representing selected product details and its variants
     * @type {?JsonData}
     * @private
     * @example
     * {
     *   id: string;
     *   ?variationAttributeSet: JsonData;
     *   ?variationInfo: JsonData;
     *   ?variationParentId: string;
     *   productClass: string;
     *   ?purchaseQuantityRule: JsonData;
     *   fields: JsonData;
     *   primaryProductCategoryPath: JsonData;
     *   ?mediaGroups: Array<JsonData>;
     *   defaultImage: JsonData;
     *   ?attributeSetInfo: JsonData;
     * }
     */
    _productDetails;

     /**
     * @description The color swatch configuration is stored as a JSON structure
     * on the Product2 object (bwc_SwatchConfig__c).
     * @type {?JsonData}
     * @private
     * @example
     * {
     *    "Color": {
     *           "Stainless Steel": "https://i.imgur.com/b0PxTwK.png",
     *           "Fingerprint Resistant Black Slate": "https://i.imgur.com/b0PxTwK.png",
     *           "Smudge Resistant Slate": "https://i.imgur.com/b0PxTwK.png"
     *       }
     * }
     *
     */
    _swatchConfig;

    /**
     * @description The custom hardware configuration is stored as a JSON structure
     * on the Product2 object (bwc_CustomHardwareConfig__c).
     * @example
        {
            "Custom Hardware": {
                "sku": "CTS90DP4NW2",
                "Brushed Stainless": {
                    "sku": "CXPR6HKPTSS",
                    "msrp": 549,
                    "imageUrl": "https://cdn11.bigcommerce.com/s-dj46qhetxl/images/stencil/640w/products/126726/298507/2474710965e993a0f3aedb71c5447d22e30b6c08__61340.1680838675.jpg?c=1)",
                    "swatchImageUrl": "https://cdn11.bigcommerce.com/s-pacto3wrn2/content/swatch-images/swatch_brushed_stainless.jpg"
                },
                "Brushed Black": {
                    "sku": "CXPR6HKPTBT",
                    "msrp": 549,
                    "imageUrl": "https://cdn11.bigcommerce.com/s-dj46qhetxl/images/stencil/640w/products/126726/298508/a8323be065ce0d26b74a5618315b3945dc721023__65860.1680838675.jpg?c=1)",
                    "swatchImageUrl": "https://cdn11.bigcommerce.com/s-pacto3wrn2/content/swatch-images/swatch_brushed_black.jpg"
                },
                "Brushed Bronze": {
                    "sku": "CXPR6HKPTBZ",
                    "msrp": 549,
                    "imageUrl": "https://cdn11.bigcommerce.com/s-dj46qhetxl/images/stencil/640w/products/126726/298509/c301a1b863e2778561f4f9726f7b93b8b385df38__93395.1680838675.jpg?c=1)",
                    "swatchImageUrl": "https://cdn11.bigcommerce.com/s-pacto3wrn2/content/swatch-images/swatch_brushed_bronze.jpg"
                },
                "Brushed Copper": {
                    "sku": "CXPR6HKPTCU",
                    "msrp": 549,
                    "imageUrl": "https://cdn11.bigcommerce.com/s-dj46qhetxl/images/stencil/640w/products/126726/298510/b83e146710579117b345771b1b524e7eb003ded4__65671.1680838676.jpg?c=1)",
                    "swatchImageUrl": "https://cdn11.bigcommerce.com/s-pacto3wrn2/content/swatch-images/swatch_brushed_copper.jpg"
                },
                "Brushed Brass": {
                    "sku": "CXPR6HKPTCG",
                    "msrp": 549,
                    "imageUrl": "https://cdn11.bigcommerce.com/s-dj46qhetxl/images/stencil/640w/products/126726/298511/b940e6dca8734563f2bb3fddd54a4ea38159a773__64474.1680838676.jpg?c=1)",
                    "swatchImageUrl": "https://cdn11.bigcommerce.com/s-pacto3wrn2/content/swatch-images/swatch_brushed_brass.jpg"
                },
                "Flat Black": {
                    "sku": "CXPR6HKPTFB",
                    "msrp": 549,
                    "imageUrl": "https://cdn11.bigcommerce.com/s-dj46qhetxl/images/stencil/640w/products/126726/298512/5b6f84aea9d2b3adae4839e17185a34546c01205__12764.1680838676.jpg?c=1)",
                    "swatchImageUrl": "https://cdn11.bigcommerce.com/s-pacto3wrn2/content/swatch-images/swatch_flat_black.jpg"
                }
            }
        }
     */
    _customHardwareConfig;

    @track
    _selectedColorValue;
    get selectedColorValue() {
        return this._selectedColorValue;
    }

    get hasCustomHardware() {
        return this._customHardwareConfig && Object.keys(this._customHardwareConfig).length > 1;
    }

    getDefaultHardware() {
        if (this.hasCustomHardware) {
            return Object.keys(this._customHardwareConfig)[0];
        }
    }

    @track
    _selectedHardware;
    get selectedHardware() {
        return this._selectedHardware;
    }

    /**
     * @description returned from the User expression
     * @type {?list}
     */
    @api
    buyerGroupNames;

    /**
     * @description List of SKUs for the custom hardware
     */
    _customHardwareProductSkus;

    @api
    get product() {
        return this._productDetails;
    }
    set product(value) {
        try {
            if (value) {
                try {
                    this._productDetails = value;
                    this._variantState = getVariantStateFromProduct(value);
                    this._swatchConfig = this.getSwatchConfigFromProduct(value);
                    this._customHardwareConfig = this.getHardwareConfigFromProduct(value);
                    this._customHardwareProductSkus = this.getCustomHardwareSkus();  //setting this triggers wired function getCustomHardwarePrices()
                } catch(e) {
                    console.log(`bwc_productVariantSelector::set product::error = ${e}`);
                }
            }
        } catch(e) {
            console.log(`bwc_productVariantSelector::set product::error = ${e}`);
        }
    }

    /**
     * @description Parses and returns the product's swatch configuration
     * @param {string} value
     * @returns {JsonData}
     */
    getSwatchConfigFromProduct(value) {
        try {
            const swatchConfig = value?.fields?.bwc_SwatchConfig__c;
            if (swatchConfig) {
                return JSON.parse(swatchConfig);
            }
        } catch(e) {
            console.log(`bwc_productVariantSelector::getSwatchConfigFromProduct::error = ${e}`)
        }
    }

    /**
     * @description Parses and returns the product's custom hardware configuration
     * @param {string} value
     * @returns {JsonData}
     */
    getHardwareConfigFromProduct(value) {
        try {
            const hardwareConfig = value?.fields?.bwc_CustomHardwareConfig__c;
            if (hardwareConfig) {
                const config = JSON.parse(hardwareConfig);
                if (config['Custom Hardware']) {
                    delete config['Custom Hardware']['sku']; //delete the 'sku' entry which is not used
                    return config['Custom Hardware'];
                }
            }
        } catch (e) {
            console.log(`bwc_productVariantSelector::getHardwareConfigFromProduct::error = ${e}`);
        }
    }

    /**
     * @description Get the list of SKUS that are in the custom hardware configuration.
     * These will later be used to query the PriceBookEntry object
     * @returns {Array<String>}
     * @private
     */
    getCustomHardwareSkus() {
        try {
            if (this.hasCustomHardware) {
                let skus = [];
                Object.keys(this._customHardwareConfig).forEach(hardwareColor => {
                    let hardwareObject = this._customHardwareConfig[hardwareColor];
                    if (!skus.includes(hardwareObject.sku)) {
                        skus.push(hardwareObject.sku);
                    }
                });
                return skus;
            }
        } catch (e) {
            console.log(`bwc_productVariantSelector::getCustomHardwareSkus::error = ${e}`);
        }
    }

    /**
     * @description An object representing the state of all the prices for the custom hardware related to a product
     * This property is used later in customHardwareOptions() getter function
     * @type {?JsonData}
     */
    _customHardwarePrices;

    @wire(getCustomHardwarePrices, {buyerGroupNames: '$buyerGroupNames', customHardwareSkus: '$_customHardwareProductSkus'})
    wiredGetCustomHardwarePrices({ error, data }) {
        if (data) {
            this._customHardwarePrices = data;
        } else if (error) {
            console.error(`bwc_productVariantSelector::wiredGetCustomHardwarePrices::error = ${error}`);
        }
    }

    get isCentered() {
        return false;
    }
    get numSwatches() {
        return 6;
    }

    /**
     * @description An object representing the state of all the variants of selected product
     * @type {?JsonData}
     * @private
     * @example
     * {
     *   variants: Array<Variant>;
     *   validVariants: Array<Array<string>>;
     *   selected: Array<*>;
     *   selectionToProductIdMap: Map<string, Object.<string, *>>;
     * }
     */
    _variantState;

    /**
     * @description The type of product. Valid product types include 'VariationParent'
     * and 'Variation'. Only 'Variation' products are available to buy.
     * @type {?string}
     * @readonly
     * @private
     */
    get productClass() {
        return this.product?.productClass;
    }

    /**
     * @description Currently Selected Options represented as an array of
     * ordered string values (matching the variant option order).
     * @type {Array<string>}
     * @readonly
     * @private
     * @example
     * ['Red', 'Large']
     */
    get selectedOptions() {
        return this._variantState?.selected;
    }

    /**
     * @description The list of available variant options
     * @type {?Array<Variant>}
     * @readonly
     * @private
     */
    get variants() {
        return this._variantState?.variants;
    }

    /**
     * @description A list of valid variants
     * @type {?Array<Array<string>>}
     * @readonly
     * @private
     * @example
     * [
     *   ['Small', 'Blue', 'Cotton'],
     *   ['Medium', 'Yellow', 'Cotton'],
     * ]
     */
    get validVariantsList() {
        return this._variantState?.validVariants;
    }

    /**
     * @description An object representing a map of attribute values strings to product id strings.
     * The key represents the valid variant attribute values as a string and the value
     * is an object with the product id and the valid variant attribute values as a list.
     * @type {Map<string, JsonData>}
     * @readonly
     * @private
     * @example
     * [
     *   'Red_Small_Cotton',
     *   {
     *     productId: '01tRM000000PWydYAG',
     *     attributes: ['Red', 'Small', 'Cotton],
     *   }
     * ]
     */
    get variantSelectionToProductIdMap() {
        return this._variantState?.selectionToProductIdMap;
    }

    /**
     * @description This is true if the variant selector satifies all the validation constraints,
     * defined in the 'validity' property
     * @type {boolean}
     */
    @api
    checkValidity() {
        return this.validity.valid;
    }

    /**
     * @description The label for required variant options
     * @type {string}
     * @readonly
     * @private
     */
    get requiredPicklistLabel() {
        return Labels.labelRequired;
    }

    /**
     * @description The label for the placeholder text
     * @type {string}
     * @readonly
     * @private
     */
    get placeholderLabel() {
        return Labels.placeholderText;
    }

    /**
     * @description The label for custom hardware
     * @type {string}
     * @readonly
     * @private
     */
    get customHardwareLabel() {
        return Labels.customHardwareText;
    }

    /**
     * @description An object representing the current validation state for the variant selector.
     * @type {ValidityState}
     * @readonly
     */
    @api
    get validity() {
        const numberOfAvailableAttributes = this.variants?.length;
        const numberOfSelectedAttributes = this.currentlySelectedOptions.filter((attribute) => !!attribute).length;
        const valueMissing = numberOfSelectedAttributes !== numberOfAvailableAttributes;
        const badInput = !this.validVariantsListContainsSelectedOptions;
        return Object.freeze({
            valueMissing,
            badInput,
            valid: !valueMissing && !badInput,
        });
    }

    /**
     * @description The currently selected variant options
     * @type {Array<string>}
     * @example
     * ['Red', 'Large']
     * @readonly
     */
    @api
    get currentlySelectedOptions() {
        let items = [...this.querySelectorAll('select')].map((item) => item.value);
        return [...items, this._selectedColorValue];
    }

    /**
     * @description Tracks the index of the last focused item
     * @type {?number}
     * @private
     */
    _selectedAttributeIndex;

    /**
     * @description Whether the valid variants list contains the currently selected options
     * @type {boolean}
     * @readonly
     * @private
     */
    get validVariantsListContainsSelectedOptions() {
        if (
            this.variants?.length !== this.currentlySelectedOptions.length ||
            this.currentlySelectedOptions.includes('')
        ) {
            return false;
        }
        const currentlySelectedOptionsAsStr = JSON.stringify(this.currentlySelectedOptions);
        const listOfVariantsAsStr = this.validVariantsList?.map((variant) => JSON.stringify(variant));
        return Boolean(listOfVariantsAsStr?.includes(currentlySelectedOptionsAsStr));
    }

    /**
     * @description A normalized list of variants.
     * This representation includes a 'value' property.
     * Additionally, the selected options has the 'selected' property set
     * @type {Array<NormalizedVariant>}
     * @readonly
     * @private
     */
    get normalizedVariants() {
        let variants = (this.variants || []).map((variant, variantIndex) => {
            const isSwatchAttribute = variant.label === 'Color';
            return {
                id: variant.id,
                label: variant.label,
                value: this.selectedOptions[variantIndex],
                isSwatchAttribute,
                options: variant.options.map((option) => {
                    let item = {
                        label: option.label,
                        value: option.value,
                        selected: this.isOptionSelected(option.value, variantIndex),
                        disabled: !this.isOptionAvailable(option.value, variantIndex),
                    };
                    if (isSwatchAttribute) {
                        let url = this._swatchConfig['Color']?.[option.value] || this._swatchConfig['color']?.[option.value];
                        item = {...item, url: url};
                        if (item.selected) {
                            this._selectedColorValue = item.value;
                        }
                    }
                    return item;
                }),
            };
        });

        const hasNoVariants = variants.length === 0;
        const hasSwatchAttributes = !!this._swatchConfig;

        if (hasNoVariants && hasSwatchAttributes) {
            // Product has no variants but does have a swatch configuration so
            // we render the 1st swatch color only
            const keys = Object.keys(this._swatchConfig['Color'] || this._swatchConfig['color']); //Assumes "Color" is the only swatch attribute
            if (keys.length > 1) {
                this._selectedColorValue = keys[1];
                let url = this._swatchConfig['Color']?.[keys[1]] || this._swatchConfig['color']?.[keys[1]];
                variants =  [{
                    id: 'Color',
                    label: 'Color',
                    value: 'Color',
                    isSwatchAttribute: true,
                    options: [{
                        label: keys[1],
                        value: keys[1],
                        url
                    }]
                }];
            }
        }

        return variants;
    }


    /**
     * @description Stores a list of options that are available for
     * the attribute the user just selected
     * @example
     * {'Small', 'Medium'}
     * @type {Set<string>}
     * @private
     */
    @track
    _availableOptions;

    /**
     * @description List of available options for each attribute index.
     * The product variant (child product) references this list to improve performance.
     * @example
     * [Set(['Small']), Set(['Red', 'Green']), Set(['Cotton'])]
     * @type {Array<Set<string>>}
     * @private
     */
    _availableOptionsList = [];

    /**
     * @description Checks whether the available options list has been created.
     * Populates the available options list if it hasn't already been created.
     * @type {boolean}
     * @readonly
     * @private
     */
    get checkAndPopulateAvailableOptionsList() {
        if (
            this.productClass === 'Variation' &&
            !this._availableOptionsList?.length &&
            !this.currentlySelectedOptions.includes('')
        ) {
            this._availableOptionsList = this.variants?.map((variant, index) =>
                getAvailableOptions(index, this.currentlySelectedOptions, this.validVariantsList)
            );
            return true;
        }
        return false;
    }

    /**
     * @description returns a list of custom hardware option objects - this is used for products that have custom
     * hardware color swatches
     * @returns {Json}
     * @example
            [
                {
                    label: 'Brushed Stainless',
                    value: 'Brushed Stainless',
                    selected: false,
                    disabled: false,
                    url: 'https://cdn11.bigcommerce.com/s-pacto3wrn2/content/swatch-images/swatch_brushed_stainless.jpg'
                    hardwareColorName: 'Brushed Stainless',
                    hardwarePrice: 549
                    },
                ...
            ];
     */
    get customHardwareOptions() {
        let options = [];
        if (this.hasCustomHardware) {
            options = Object.keys(this._customHardwareConfig).map((hwColorName, index) => {
                let selected = index == 0;
                let sku = this._customHardwareConfig[hwColorName]?.sku;
                let price = (sku && this._customHardwarePrices && this._customHardwarePrices[sku]) || this._customHardwareConfig[hwColorName]?.price;
                let url = this._customHardwareConfig[hwColorName]?.swatchImageUrl;

                return {
                    label: hwColorName,
                    value: hwColorName,
                    selected,
                    url,
                    hardwareColorName: hwColorName,
                    hardwarePrice: price
                }
            });
        }
        return options;
    }

    _initialRender = true;

    /**
     * @description This function runs once the component has been rendered and it publishes 
     * an event on a message channel so that other components can respond to that event.  The event
     * in this case is the hardware being selected as "default".  This ensures that other components
     * know to react when the default hardware is selected when the page is first loaded.
     */
    renderedCallback() {
        if (this._initialRender && this.hasCustomHardware) {

            setTimeout(() => {
                this._selectedHardware = this.getDefaultHardware();
                const payload = this._customHardwareConfig[this._selectedHardware];
                payload.default = this.getDefaultHardware() === this._selectedHardware;
                payload.price = this._customHardwarePrices?.[payload.sku] || payload.price;
                payload.name = this._selectedHardware;
                publish(this.messageContext, HARDWARE_SELECTED_CHANNEL, payload);
                this._initialRender = false;
            }, 100);

            this._initialRender = false;
        }
    }

    /**
     * @description Checks if the option is selected or not
     * @param {string} optionValue
     *  Value of the given option (e.g. 'Small')
     * @param {number} variantIndex
     *  Index of the variant that the option belongs to
     * @returns {boolean}
     *  True if option is in selectedOptions, otherwise false.
     * @private
     */
    isOptionSelected(optionValue, variantIndex) {
        const currentlySelectedOptions = this.currentlySelectedOptions;

        if (currentlySelectedOptions.includes('') && this.selectedOptions.length > 0) {
            return optionValue === currentlySelectedOptions[variantIndex];
        }
        return optionValue === this.selectedOptions[variantIndex];
    }

    /**
     * @description Whether the provided optionsValue is in the list of available options
     * @param {string} optionValue
     *  Value of the given option (e.g. 'Small')
     * @param {number} variantIndex
     *  Index of the variant that the option belongs to
     * @returns {boolean}
     *  True if
     *      - availableOptions is not yet defined (currently only defined when the user selects an option)
     *      - the option given doesn't belong the selected attribute index
     *      - the option value is in the list of available options
     *  False if
     *      - the option value is not in the list of available options
     * @private
     */
    isOptionAvailable(optionValue, variantIndex) {
        return (
            !this._availableOptions ||
            variantIndex !== this._selectedAttributeIndex ||
            this._availableOptions.has(optionValue)
        );
    }

    @wire(MessageContext)
    messageContext;

    /**
     * @description Handler for the 'focus' event
     * @param {FocusEvent} event Received whenever a variant selection is focused
     * @private
     */
    handleFocus(event) {
        if (event.target.dataset.index !== null && event.target.dataset.index !== undefined) {
            this._selectedAttributeIndex = +event.target.dataset.index;

            this._availableOptions = this.checkAndPopulateAvailableOptionsList
                ? this._availableOptionsList && this._availableOptionsList[this._selectedAttributeIndex]
                : getAvailableOptions(
                      this._selectedAttributeIndex,
                      this.currentlySelectedOptions,
                      this.validVariantsList
                  );
        }
    }

    /**
     * @description Handler for the 'change' event fired whenever a variant selection changes
     * It fires a custom event 'variantselected'
     * @private
     * @fires ProductVariantSelector#variantselected
     */
    handleChange() {
        if (this.variants.length === 0) {
            return;
        }
        this._selectedColorValue = this.querySelector('#colorSwatch')?.value;
        const isValid = this.checkValidity();
        const currentVariantSelectionsAsStr = this.currentlySelectedOptions.join('_');
        const selection = this.variantSelectionToProductIdMap?.get(currentVariantSelectionsAsStr);
        const productId = selection?.productId;
        const urlName = selection?.urlName || undefined;
        this.dispatchEvent(
            new CustomEvent(VARIANT_SELECTED_EVT, {
                detail: {
                    productId,
                    isValid,
                    options: this.currentlySelectedOptions,
                    urlName,
                },
            })
        );
    }

    /**
     * @description Handler for the 'change' event fired whenever a custom hardware selection changes
     */
    handleCustomHardwareChange() {
        this._selectedHardware = this.querySelector('#customHardwareSwatch')?.value;
        const payload = this._customHardwareConfig[this._selectedHardware];
        payload.default = this.getDefaultHardware() === this._selectedHardware;
        payload.price = this._customHardwarePrices?.[payload.sku] || payload.price;
        payload.name = this._selectedHardware;
        publish(this.messageContext, HARDWARE_SELECTED_CHANNEL, payload);
    }
}