import { LightningElement, api, wire } from 'lwc';
import fetchPrices from '@salesforce/apex/BWC_CartController.fetchPrices';
import BWC_UI from '@salesforce/resourceUrl/BodewellTheme';
import { Labels } from './labels';
import displayOriginalPriceEvaluator from './productPricingUtils';
import { subscribe, unsubscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import { CurrentPageReference } from 'lightning/navigation';
import HARDWARE_SELECTED_CHANNEL from '@salesforce/messageChannel/BWC_HardwareSelected__c';
/**
 * @description A component that renders product pricing information
 */
export default class bwc_ProductPricing extends LightningElement {
     MEMBER_SKU = BWC_UI + '/icons/membership.svg';
     
    static renderMode = 'light';

    /**
     * @description The desired layout of price text.
     * horizontal will display on single line, with original/list price first (if visible)
     * vertical will display on 2 lines, with original/list price last (if visible)
     * @type {?('horizontal' | 'vertical')}
     */
    @api
    layout;

    /**
     * @description The localized negotiated price label for the item.
     * @type {?string}
     */
    _negotiatedPriceLabel;

    @api
    get negotiatedPriceLabel() {
        return this._negotiatedPriceLabel;
    };
    set negotiatedPriceLabel(value) {
        this._negotiatedPriceLabel = value;
    }

    /**
     * @description The localized original price label for the item.
     * @type {?string}
     */
    @api
    originalPriceLabel;

    /**
     * @description The localized label to display when no pricing is available
     * @type {?string}
     */
    @api
    unavailablePriceLabel;

    /**
     * @description The localized negotiated price of the item.
     * @type {?string}
     */
    _negotiatedPrice;

    @api
    get negotiatedPrice() {
        return Number(this._negotiatedPrice) + Number(this._hardwarePrice);
    }
    set negotiatedPrice(value) {
        this._negotiatedPrice = value;
    }

    _hardwareDefault;
    get hardwareDefault() {
        return this._hardwareDefault;
    }

    _hardwarePrice = 0;
    get hardwarePrice() {
        return this._hardwarePrice;
    }

    _hardwareName;
    _hardwareSKU;

    get hardwareInfo() {
        if (this._hardwareDefault) {
            return this._hardwareName;
        }
        return this._hardwareName + ' | ' + this._hardwareSKU;
    }

    get hasHardware() {
        return !!this._hardwareSKU;
    }

    /**
     * @description The localized original price of the item.
     * @type {?string}
     */
    @api
    originalPrice;

    /**
     * @description The ISO 4217 currency code for the product detail page
     * @type {?string}
     */
    @api
    currencyCode;

    /**
     * @description Whether to display the negotiated price
     * @type {boolean}
     */
    @api
    showNegotiatedPrice = false;

    /**
     * @description Whether to display the original price
     * @type {boolean}
     */
    @api
    showOriginalPrice = false;

    /**
     * @description Whether to display the tax included text
     * @type {boolean}
     */
    @api
    showTaxIndication = false;

    /**
     * @description The Tax Included label text.
     * @type {?string}
     */
    @api
    taxIncludedLabel;

    /**
     * @description Tax locale type for the product.
     * Possible values are "Gross" and "Net"
     * @type {?('Gross' | 'Net')}
     */
    @api
    taxLocaleType;

    /**
     * @description Tax rate for the product.
     * When a given product is exempt, taxRate will be 0
     * @type {?number}
     */
    @api
    taxRate;

    /**
     * @description Assistive text, required because screen-readers do not read out strikethrough styling
     * @type {string}
     * @private
     * @readonly
     */
    get strikethroughAssistiveText() {
        return Labels.strikethroughAssistiveText;
    }

    get negotiatedStandardHardwarePriceLabel() {
        return Labels.negotiatedStandardHardwarePriceText;
    }

    get negotiatedCustomHardwarePriceLabel() {
        return Labels.negotiatedCustomHardwarePriceText;
    }

    get negotiatedHardwarePriceLabel() {
        if (this._hardwareDefault) {
            return this.negotiatedStandardHardwarePriceLabel;
        }
        return this.negotiatedCustomHardwarePriceLabel;
    }

    /**
     * @description Gets whether Tax Information can be shown. Will only be true
     * when taxLocaleType is "Gross", showTaxIndication is configured to be shown and
     * taxRate is not 0 or when taxRate is undefined (this scenario occurs when CommerceTax perm is not enabled)
     * @type {boolean}
     * @readonly
     * @private
     */
    get taxInfoVisible() {
        return this.showTaxIndication && this.isPriceAvailable && this.taxLocaleType === 'Gross' && this.taxRate !== 0;
    }

    /**
     * @description Whether to display the original price
     * @returns {boolean} true if the original (list) price should be displayed, otherwise false
     * @readonly
     * @private
     */
    get displayOriginalPrice() {
        return displayOriginalPriceEvaluator(
            this.showNegotiatedPrice,
            this.showOriginalPrice,
            this.negotiatedPrice,
            this.originalPrice
        );
    }

    /**
     * @description Whether to display the negotiated price
     * @returns {boolean}
     * true if negotiated price is available and option to display it is also true
     * @readonly
     * @private
     */
    get displayNegotiatedPrice() {
        return this.showNegotiatedPrice && !!this.negotiatedPrice;
    }

    get displayNegotiatedPriceWithHardware() {
        return this.displayNegotiatedPrice && this.hasHardware;
    }

    get displayNegotiatedPriceWithoutHardware() {
        return this.displayNegotiatedPrice && !this.hasHardware;
    }

    /**
     * @description Whether to display the assistive text for strike-through text
     * @returns {boolean}
     * true if both negotiated and original prices are displayed
     * @private
     * @readonly
     */
    get displayAssistiveText() {
        return this.displayNegotiatedPrice && this.displayOriginalPrice;
    }

    /**
     * @description Whether the pricing information is available
     * @returns {boolean}
     * true if negotiated price exists and needs to be shown, otherwise false
     * @private
     * @readonly
     */
    get isPriceAvailable() {
        return this.showNegotiatedPrice && !!this.negotiatedPrice;
    }

    /**
     * @description Whether there is a negotiated price label to display.
     * @returns {boolean}
     * true if a negotiated price label has been supplied, otherwise false
     * @private
     * @readonly
     */
    get hasNegotiatedPriceLabel() {
        return !!this.negotiatedPriceLabel;
    }

    /**
     * @description Whether there is an original price label to display.
     * @returns {boolean}
     * true if an original (list) price label has been supplied, otherwise false
     * @private
     * @readonly
     */
    get hasOriginalPriceLabel() {
        return !!this.originalPriceLabel;
    }

    /**
     * @description Gets classes based on horizontal or vertical layout.
     * Note: for horizontal it reverses display so that originalPrice is first.
     * @type {string}
     * @private
     * @readonly
     */
    get layoutClass() {
        return `slds-grid price-container ${
            this.layout === 'horizontal' ? 'slds-grid_reverse' : 'slds-grid_vertical'
        }`;
    }

    @wire(MessageContext)
    messageContext;

    subscription;
    
    _productId;
    pageAttributes;
    pageObjectApiName;
    _memberSavings=0.0;
    
    @api
    get plpProductId() {
        return this._productId;
    }
    set plpProductId(val) {
        if (val) {
            this._productId = val;       
            console.log(' PLP product ID' + val);
        }
    }
 
    /**
     * @description Subscribe to custom hardware selected events
     */
    connectedCallback() {
        this.subscription =
            subscribe(
                this.messageContext,
                HARDWARE_SELECTED_CHANNEL,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        
        const currentURL = `${window.location.pathname}`;
        if( this.pageObjectApiName=='Product2')
        {
            const parts = currentURL.split('/');
            this._productId =parts[parts.length - 1];
            console.log("productId PDP",currentURL, this._productId);
            if (this._productId) 
            {
               this.handleMemProductSavings();
            }
        }      
        console.log("PLP Product ID CB", this._productId);
        if (this._productId) {
        this.handleMemProductSavings();
        }
    }

    /**
     * @description Un-subscribe to custom hardware selected events
     */
    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
   
     
      @wire(CurrentPageReference)
       getPageReferenceParameters(currentPageReference) {
       if (currentPageReference) {
         
          // this.recordId = currentPageReference.attributes.recordId || null;          
          // let states = currentPageReference.state;
          // let type = currentPageReference.type;
          this.pageAttributes = currentPageReference.attributes.name;
          this.pageObjectApiName = currentPageReference.attributes.objectApiName;
          //console.log('currentPageReference', JSON.stringify(currentPageReference),this.pageObjectApiName,this.pageAttributes);
          
       }
    }

    /**
     * @description Save the custom hardware information
     * @param {Jsondata} data
     */
    handleMessage(data) {
        this._hardwareName = data.name;
        this._hardwareDefault = data.default;
        this._hardwarePrice = data.default ? 0 : data.price;
        this._hardwareSKU = data.sku;
    }

     

     async handleMemProductSavings() {       
        await fetchPrices({ productIds: [this._productId], quantities: [1] })
            .then(result => {
                console.log("##productId method Product Pricing ", this._productId);
                //this._memberSavings = result.totalDifference;
                if (result.totalDifference != undefined && result.totalDifference > 0) {
                    this._memberSavings = (result.totalDifference).toFixed(2);
                }
                else {
                    this._memberSavings = 0.00;
                }
                console.log('##Product Savings from apex Product Pricing' + JSON.stringify(result));
            })
            .catch(error => {
                console.log('## Erro Product Savings from apex Product Pricing' + JSON.stringify(error));
            })
    }
}