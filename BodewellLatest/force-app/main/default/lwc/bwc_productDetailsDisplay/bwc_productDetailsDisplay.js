import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDisplayButton from '@salesforce/apex/BWC_DisplayProductButton.bwc_Available'
import getProductValues from '@salesforce/apex/BWC_ADC.getProductValues';
import zipCodeChannel from '@salesforce/messageChannel/zipCodeChange__c';
// import getProductAvailability from '@salesforce/apex/BWC_ADC.getADC_Details';

import { subscribe, MessageContext } from 'lightning/messageService';
import { CurrentPageReference } from 'lightning/navigation';
import { ProductAdapter, ProductPricingAdapter } from 'commerce/productApi';

// A fixed entry for the home page.
const homePage = {
    name: 'Home',
    type: 'standard__namedPage',
    attributes: {
        pageName: 'home'
    }
};

export default class Bwc_productDetailsDisplay extends NavigationMixin(LightningElement) {


    @track isShowAddtoCart = true;
    productIdInstance;
    @track zipCode;
    @api isAvailable;
    @api error;
    @track isShowModal = false;
    @track unitPrice;
    @track sku;
    @track isPurchase;
    @track isPart;
    @track partStat;
    @track supercedeCount;
    @track derivative;
    @track lifePhase;
    @track isOutOfStock = false;
    @track isPurchasable;


    @wire(MessageContext)
    messageContext;

    @api
    customFields;

    /**
     * Gets or sets whether the cart is locked
     *
     * @type {boolean}
     */
    @api
    cartLocked;

    /**
     * Gets or sets the name of the product.
     *
     * @type {string}
     */
    @api
    description;

    /**
     * Gets or sets the product image.
     *
     * @type {Image}
     */
    @api
    image;

    /**
     * Gets or sets whether the product is "in stock."
     *
     * @type {boolean}
     */
    @api
    inStock = false;

    /**
     * Gets or sets the name of the product.
     *
     * @type {string}
     */
    @api
    name;

    /**
     * Gets or sets the price - if known - of the product.
     * If this property is specified as undefined, the price is shown as being unavailable.
     *
     * @type {Price}
     */
    @api
    price;

    /**
     * Gets or sets teh stock keeping unit (or SKU) of the product.
     *
     * @type {string}
     */
    // @api
    // sku;

    _invalidQuantity = false;
    _quantityFieldValue = 1;
    _categoryPath;
    _resolvedCategoryPath = [];

    // A bit of coordination logic so that we can resolve product URLs after the component is connected to the DOM,
    // which the NavigationMixin implicitly requires to function properly.
    _resolveConnected;
    _connected = new Promise((resolve) => {
        this._resolveConnected = resolve;
    });

    connectedCallback() {
        console.log('intoChildComponent');
        if (localStorage.getItem('zipcode')) {
            //An Id key is in the local Storage
            this.localStorageZipCode = JSON.parse(localStorage.getItem('zipcode'));
            this.zipCode = this.localStorageZipCode.Zipcode;
            this.getData(this.zipCode);
        }
        this._resolveConnected();
    }

    disconnectedCallback() {
        this._connected = new Promise((resolve) => {
            this._resolveConnected = resolve;
        });
    }

    /**
     * Gets or sets the ordered hierarchy of categories to which the product belongs, ordered from least to most specific.
     *
     * @type {Category[]}
     */
    @api
    get categoryPath() {
        return this._categoryPath;
    }

    set categoryPath(newPath) {
        this._categoryPath = newPath;
        this.resolveCategoryPath(newPath || []);
    }

    get hasPrice() {
        return ((this.price || {}).negotiated || '').length > 0;
    }

    /**
     * Gets whether add to cart button should be displabled
     *
     * Add to cart button should be disabled if quantity is invalid,
     * if the cart is locked, or if the product is not in stock
     */

    handleQuantityChange(event) {
        if (event.target.validity.valid && event.target.value) {
            this._invalidQuantity = false;
            this._quantityFieldValue = event.target.value;
        } else {
            this._invalidQuantity = true;
        }
    }

    /**
     * Emits a notification that the user wants to add the item to their cart.
     *
     * @fires ProductDetailsDisplay#addtocart
     * @private
     */
    notifyAddToCart() {
        let quantity = this._quantityFieldValue;
        this.dispatchEvent(
            new CustomEvent('addtocart', {
                detail: {
                    quantity
                }
            })
        );
    }

    /**
     * Emits a notification that the user wants to add the item to a new wishlist.
     *
     * @fires ProductDetailsDisplay#createandaddtolist
     * @private
     */
    notifyCreateAndAddToList() {
        this.dispatchEvent(new CustomEvent('createandaddtolist'));
    }

    /**
     * Updates the breadcrumb path for the product, resolving the categories to URLs for use as breadcrumbs.
     *
     * @param {Category[]} newPath
     *  The new category "path" for the product.
     */
    resolveCategoryPath(newPath) {
        const path = [homePage].concat(
            newPath.map((level) => ({
                name: level.name,
                type: 'standard__recordPage',
                attributes: {
                    actionName: 'view',
                    recordId: level.id
                }
            }))
        );

        this._connected
            .then(() => {
                const levelsResolved = path.map((level) =>
                    this[NavigationMixin.GenerateUrl]({
                        type: level.type,
                        attributes: level.attributes
                    }).then((url) => ({
                        name: level.name,
                        url: url
                    }))
                );

                return Promise.all(levelsResolved);
            })
            .then((levels) => {
                this._resolvedCategoryPath = levels;
            });
    }

    /**
     * Gets the iterable fields.
     *
     * @returns {IterableField[]}
     *  The ordered sequence of fields for display.
     *
     * @private
     */
    get _displayableFields() {
        // Enhance the fields with a synthetic ID for iteration.
        return (this.customFields || []).map((field, index) => ({
            ...field,
            id: index
        }));
    }

    // getData(zipCode) {
    //     console.log('productId>>>' + this.productIdInstance);
    //     console.log('zipCodeIntoGetDataInADC>>>' + zipCode);
    //     getDisplayButton({ productId: this.productIdInstance, postalCodeInstance: zipCode })
    //         .then(result => {
    //             console.log('res>>>' + result);
    //             this.isAvailable = result;
    //             console.log('available>>>' + this.isAvailable);
    //             console.log('available>>>', this.isAvailable);
    //             if(this.isShowAddtoCart==true && this.isAvailable==true && this.isPurchasable!=="false" && this.zipCode!=undefined && this.zipCode!==null){
    //                 this.isShowAddtoCart=true;
    //                 this.isOutOfStock=false;
    //             }
    //             else if(this.zipCode!=undefined && this.zipCode!==null){
    //                this.isShowAddtoCart=false;
    //                 this.isOutOfStock=true;
    //             }
    //             else{
    //                 this.isShowAddtoCart=false;
    //                 this.isOutOfStock=false;
    //             }
    //         })
    //         .catch(error => {
    //             this.error = error;
    //             console.log('err>>' + JSON.stringify(this.error));
    //         })
    // }
    // @wire(getProductValues, { productId: '$productIdInstance' })
    // wiredData({ data, error }) {
    //     if (data) {
    //         this.partStat = data.BWC_PARTSTAT__c;
    //         this.supercedeCount = data.BWC_SUPERCEDE_COUNT__c;
    //         this.derivative = data.BWC_Derivative__c;
    //         this.lifePhase = data.Item_Lifecycle_Phase__c;
    //     }
    //     else if(error){
    //         console.log('errorINAdcProduct',error);
    //     }
    // }


    // @wire(CurrentPageReference)
    // getPageReferenceParameters(currentPageReference) {
    //     if (currentPageReference) {
    //         this.productIdInstance = currentPageReference.attributes.recordId;
    //         console.log('pagerefId>>>' + this.productIdInstance);
    //     }
    // }
    // @wire(ProductAdapter, { productId: '$productIdInstance' })
    // ProductAdapterMethod({ error, data }) {
    //     if (data) {
    //         console.log('ProductAdapter data-->', data);
    //         this.exploadedParts = data.fields.BWC_Exploded_Diagram_Parts__c;
    //         console.log('explodedParts>>' + data.fields.BWC_Exploded_Diagram_Parts__c);
    //         if (data.fields.ProductClass == 'VariationParent') {
    //             var jsonString = data.fields.BWC_Exploded_Diagram_Parts__c;
    //             var jsonObject = JSON.parse(jsonString);
    //             this.sku = jsonObject['Exploded Diagram Parts']['sku'];
    //             console.log('SKU Value:', this.sku);
    //         }
    //         else{
    //             this.sku = data.fields.StockKeepingUnit;
    //         }
    //         this.isPurchasable = data.fields.BWC_IsPurchasable__c;
    //         if (data.fields.ProductClass === 'VariationParent') {
    //             if (data.fields.BWC_IsPurchasable__c === "true" && data.fields.BWC_Is_Part__c == "true" && (this.partStat != 0 || this.partStat != 1 || this.supercedeCount != 0 || this.lifePhase === 'Near End of Life') && (this.zipCode != undefined && this.zipCode != null)) {
    //                 this.isShowAddtoCart = true;
    //                 this.isOutOfStock = false;
    //             }
    //             else if (data.fields.BWC_IsPurchasable__c === "true" && data.fields.BWC_Is_Part__c == "true" && this.derivative != 'DUAL' && this.lifePhase == 'Near End of Life' && (this.zipCode != undefined && this.zipCode != null)) {
    //                 this.isShowAddtoCart = true;
    //                 this.isOutOfStock = false;
    //             }
    //             else if (data.fields.BWC_IsPurchasable__c === "false" && data.fields.BWC_Is_Part__c == "false" && (this.zipCode != undefined && this.zipCode != null)) {
    //                 this.isOutOfStock = true;
    //                 this.isShowAddtoCart = false;
    //             }
    //             else if(data.fields.BWC_IsPurchasable__c === "true" && (this.zipCode != undefined && this.zipCode != null)){
    //                   this.isShowAddtoCart = true;
    //                 this.isOutOfStock = false;
    //             }
    //             else if (this.zipCode != undefined && this.zipCode != null) {
    //                 this.isOutOfStock = true;
    //                 this.isShowAddtoCart = false;
    //             }
    //             else {
    //                 this.isOutOfStock = false;
    //                 this.isShowAddtoCart = false;
    //             }
    //         }
    //         else if (data.fields.BWC_IsPurchasable__c === "true" && (this.zipCode != undefined && this.zipCode != null)) {
    //             this.isOutOfStock = false;
    //             this.isShowAddtoCart = true;
    //         }
    //         else if (this.zipCode != undefined && this.zipCode != null) {
    //             this.isShowAddtoCart = false;
    //             this.isOutOfStock = true;
    //         }
    //         else {
    //             this.isShowAddtoCart = false;
    //             this.isOutOfStock = false;
    //         }
    //         console.log('showAddToCart>>>' + this.isShowAddtoCart);

    //         console.log('this.zipCode' + this.zipCode);
    //     }
    //     else {
    //         console.log('error order-->', error);
    //     }
    // }



    handleSubscribe() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(this.messageContext, zipCodeChannel, (message) => {
            console.log('msg>>>' + message.message);

            const fullAddress = message.message;
            this.zipCode = fullAddress.Zipcode;
            if (this.zipCode) {
                this.getData(this.zipCode)
            }

        });
    }

    handleCart() {
        this.notifyAddToCart();
        this.showModalBox();

    }
    handleGotoCart() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Current_Cart'
            }
        });
        setTimeout(() => {
            window.location.reload();
        }, 1000);
    }


    showModalBox() {
        this.isShowModal = true;
    }

    hideModalBox() {
        this.isShowModal = false;
    }
}