import { LightningElement, api, wire } from 'lwc';
import PDP_TAB_LABELS from './labels';
import addToCart from "@salesforce/apex/BWC_GetInfo.addToCart";
import communityId from "@salesforce/community/Id";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
/**
 * @slot productSection1
 * @slot productSection2
 * @slot productSection3
 * @slot productSection4
 * @slot productSection5
 */

export default class Bwc_productTabs extends LightningElement {
    value = '1';
    // Future release, consider adding this object into the LWC property panel
    // Create a string property and have admin list tab titles comma separated > retrieve and build out an object to pass to LWCs
    get options() {
        let _labels = PDP_TAB_LABELS.PDP_TAB_LABELS;
        return [
            { label: _labels.features, value: '1' },
            { label: _labels.specs, value: '2' },
            { label: _labels.reviews, value: '3' },
            { label: _labels.support, value: '4' },
            { label: _labels.related, value: '5' }
        ];
    }

    connectedCallback() {
        let _this = this;
        window.onscroll = function () {
            _this.isScrolledIntoView();
        };
    }

    isScrolledIntoView() {
        const el = this.template.querySelector('.product-tab-nav');
        let rect = el.getBoundingClientRect();
        let elemTop = rect.top;
        let elemBottom = rect.bottom;

        // top of the sticky nav <= the height of the product features nav
        let isVisible = (elemTop <= 5) && (elemBottom <= window.innerHeight);
        const sticky = this.template.querySelector('.product-header--sticky');
        if (isVisible) {
            sticky.classList.add('is-active');
        } else {
            sticky.classList.remove('is-active');
        }
    }

    handleScroll(event) {
        this.value = event.currentTarget.dataset.id;
        let sectionChoosen = this.template.querySelector('.product-section_' + this.value);
        sectionChoosen.scrollIntoView({ block: 'start', behavior: 'smooth' });
    }

    /**
    * Product data 
    * @type {?JSONData}
    */
    _product;

    /**
    * @type {?String}
    */
    _productImage;
    _productName;
    _productSku;

    @api
    get product() {
        return this._product;
    };
    set product(value) {
        if (value) {
            this._product = value;
            const media = value?.fields?.BWC_Main_Image__c;
            if (media) {
                this._productImage = this.mediaConversion(media);
            }

            this._productName = value?.fields?.BWC_Product_Marketing_Description__c;
            this._productSku = value?.fields?.StockKeepingUnit;
        }
    }

    mediaConversion(img) {
        let size = '--/w_100,h_100/';
        let smallFormat = img.replace('--/', size);
        return smallFormat;
    }

    /**
    * Product Pricing 
    * @type {?JSONData}
    */
    _pricing;

    /**
    * @type {?String}
    */
    _originalPrice;
    _negotiatedPrice;
    _currencyCode;

    @api
    get pricing() {
        return this._pricing;
    };
    set pricing(value) {

        if (value) {
            console.log('Pricing data==' + JSON.stringify(value));
            this._pricing = value;
            this._originalPrice = value?.listPrice;
            this._negotiatedPrice = value?.negotiatedPrice;
            this._currencyCode = value?.currencyIsoCode;
            console.log('Pricing _originalPrice==' + this._originalPrice);
            console.log('Pricing _currencyCode==' + this._currencyCode);
            console.log('Pricing _negotiatedPrice==' + this._negotiatedPrice);
        }
    }
    addToCart(event) {
        addToCart({
            communityId: communityId,
            productId: this._product.id,
            quantity: 1,
            effectiveAccountId: null,
            deliverySku: null,
            installationSku: null,
            mcodeSku: null,
            zipCode: null
        })
            .then(result => {
                // this.updateCartItemInformation(result.cartInformation.cartItemId);
                if (result.isAddedToCart === true) {
                    //this.sendNotificationToProtectionModal(result);
                }
                if (result.isAddedToCart === false) {
                    this.showToastMessage('Error', result.errorMessage, "error", "dismissable");
                }
                else {
                    this.dispatchEvent(
                        new CustomEvent("cartchanged", {
                            bubbles: true,
                            composed: true
                        })
                    );
                    this.showToastMessage('Success', "Your cart has been updated.", "success", "dismissable");
                }
            })
            .catch(error => {
                console.log("error apex class-->", error);
                this.showToastMessage('Error', "This product has a maximum purchase limit. Check quantity limits", "error", "dismissable");
            })
    }

    showToastMessage(titleInstance, messageInstance, variantInstance, modeInstance) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: titleInstance,
                message: messageInstance,
                variant: variantInstance,
                mode: modeInstance
            })
        );
    }
}