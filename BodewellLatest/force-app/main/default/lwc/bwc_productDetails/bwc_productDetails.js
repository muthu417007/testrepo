import { LightningElement, wire, api } from "lwc";

import communityId from "@salesforce/community/Id";
import getProduct from "@salesforce/apex/BWC_GetInfo.getProduct";
import getCartSummary from "@salesforce/apex/BWC_GetInfo.getCartSummary";
// import checkProductIsInStock from '@salesforce/apex/BWC_GetInfo.checkProductIsInStock';
import addToCart from "@salesforce/apex/BWC_GetInfo.addToCart";
import createAndAddToList from "@salesforce/apex/BWC_GetInfo.createAndAddToList";
import getProductPrice from "@salesforce/apex/BWC_GetInfo.getProductPrice";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { resolve } from "c/bwc_cmsResourceResolver";
import ToastContainer from "lightning/toastContainer";
import { updateRecord } from 'lightning/uiRecordApi';
import SO_FREQUENCY_FIELD from '@salesforce/schema/CartItem.BWC_SO_Order_Frequency__c';
import ID_FIELD from '@salesforce/schema/CartItem.Id';

//SHubhada Changes
import { publish, subscribe, MessageContext } from "lightning/messageService";
import ServiceSKUChannel from "@salesforce/messageChannel/Bwc_ServicesSkuList__c";
//Shubhada Changes
import memberChannel from '@salesforce/messageChannel/bwc_membership__c';

export default class Bwc_productDetails extends LightningElement {
  //shubhada changes
  publisherMessage = "";
  subscription = null;
  deliverySku;
  zipCode;
  mcodeSku;
  installationSku;
  @wire(MessageContext) messageContext;

  /**
       * Gets the effective account - if any - of the user viewing the product.
       *
       * @type {string}
       */
  @api
  get effectiveAccountId() {
    return this._effectiveAccountId;
  }

  /**
     * Sets the effective account - if any - of the user viewing the product
     * and fetches updated cart information
     */
  set effectiveAccountId(newId) {
    this._effectiveAccountId = newId;
    this.updateCartInformation();
  }

  /**
     * Gets or sets the unique identifier of a product.
     *
     * @type {string}
     */
  @api recordId;

  /**
     * Gets or sets the custom fields to display on the product
     * in a comma-separated list of field names
     *
     * @type {string}
     */
  @api customDisplayFields;

  /**
     * The cart summary information
     *
     * @type {ConnectApi.CartSummary}
     * @private
     */
  cartSummary;

  /**
     * The stock status of the product, i.e. whether it is "in stock."
     *
     * @type {Boolean}
     * @private
     */
  // @wire(checkProductIsInStock, {
  //     //productId: '$recordId'
  //     productId: '01t5i000005zwVdAAI'
  // })
  // inStock;

  /**
     * The full product information retrieved.
     *
     * @type {ConnectApi.ProductDetail}
     * @private
     */
  @wire(getProduct, {
    communityId: communityId,
    productId: "$recordId",
    effectiveAccountId: "$resolvedEffectiveAccountId"
  })
  product;

  /**
     * The price of the product for the user, if any.
     *
     * @type {ConnectApi.ProductPrice}
     * @private
     */
  @wire(getProductPrice, {
    communityId: communityId,
    productId: "$recordId",
    effectiveAccountId: "$resolvedEffectiveAccountId"
  })
  productPrice;

  /**
     * The connectedCallback() lifecycle hook fires when a component is inserted into the DOM.
     */
  connectedCallback() {
    const toastContainer = ToastContainer.instance();
    toastContainer.maxShown = 5;
    toastContainer.toastPosition = "top-center";
    //shubhada changes
    this.handleSubscribe();
    this.updateCartInformation();
  }

  //shubhada changes
  handleSubscribe() {
    if (this.subscription) {
      return;
    }
    this.subscription = subscribe(
      this.messageContext,
      ServiceSKUChannel,
      message => {
        console.log("date------" + message.message);
        this.deliverySku = message.message;
        this.installationSku = message.message1;
        this.zipCode = message.message2;
        this.mcodeSku=message.mcodesSKU;
        console.log("deliverySku------" + this.deliverySku);
        console.log("installationSku------" + this.installationSku);
        console.log("mcodeSku------" + this.mcodeSku);
        console.log("zipCode------" + this.zipCode);
      }
    );
  }

  /**
     * Gets the normalized effective account of the user.
     *
     * @type {string}
     * @readonly
     * @private
     */
  get resolvedEffectiveAccountId() {
    const effectiveAccountId = this.effectiveAccountId || "";
    let resolved = null;

    if (
      effectiveAccountId.length > 0 &&
      effectiveAccountId !== "000000000000000"
    ) {
      resolved = effectiveAccountId;
    }
    return resolved;
  }

  /**
     * Gets whether product information has been retrieved for display.
     *
     * @type {Boolean}
     * @readonly
     * @private
     */
  get hasProduct() {
    return this.product.data !== undefined;
  }

  /**
     * Gets the normalized, displayable product information for use by the display components.
     *
     * @readonly
     */
  get displayableProduct() {
    return {
      categoryPath: this.product.data.primaryProductCategoryPath.path.map(
        category => ({
          id: category.id,
          name: category.name
        })
      ),
      description: this.product.data.fields.Description,
      image: {
        alternativeText: this.product.data.defaultImage.alternativeText,
        url: resolve(this.product.data.defaultImage.url)
      },
      // inStock: this.inStock.data === true,
      name: this.product.data.fields.Name,
      price: {
        currency: ((this.productPrice || {}).data || {}).currencyIsoCode,
        negotiated: ((this.productPrice || {}).data || {}).unitPrice
      },
      sku: this.product.data.fields.StockKeepingUnit,
      customFields: Object.entries(
        this.product.data.fields || Object.create(null)
      )
        .filter(([key]) => (this.customDisplayFields || "").includes(key))
        .map(([key, value]) => ({ name: key, value }))
    };
  }

  /**
     * Gets whether the cart is currently locked
     *
     * Returns true if the cart status is set to either processing or checkout (the two locked states)
     *
     * @readonly
     */
  get _isCartLocked() {
    const cartStatus = (this.cartSummary || {}).status;
    return cartStatus === "Processing" || cartStatus === "Checkout";
  }

  /**
     * Handles a user request to add the product to their active cart.
     * On success, a success toast is shown to let the user know the product was added to their cart
     * If there is an error, an error toast is shown with a message explaining that the product could not be added to the cart
     *
     * Toast documentation: https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_toast
     *
     * @private
     */
  addToCart(event) {
    console.log("Inside event");
    addToCart({
      communityId: communityId,
      productId: this.recordId,
      quantity: event.detail.quantity,
      effectiveAccountId: this.resolvedEffectiveAccountId,
      deliverySku: this.deliverySku,
      installationSku: this.installationSku,
      mcodeSku:this.mcodeSku,
      zipCode: this.zipCode
    })
      .then(result => {
       console.log("result-->", result);
       console.log('cartItemId->',result.cartInformation.cartItemId);
       this.updateCartItemInformation(result.cartInformation.cartItemId);
       if (result.isAddedToCart === true) {
       this.sendNotificationToProtectionModal(result);
       }
        if (result.isAddedToCart === false) {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error",
              message: result.errorMessage,
              variant: "error",
              mode: "dismissable"
            })
          );
        }
        else {
          this.dispatchEvent(
            new CustomEvent("cartchanged", {
              bubbles: true,
              composed: true
            })
          );

          this.dispatchEvent(
            new ShowToastEvent({
              title: "Success",
              message: "Your cart has been updated.",
              variant: "success",
              mode: "dismissable"
            })
          );
        }
      })
      .catch(error => {
        console.log("error apex class-->", error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: "This product has a maximum purchase limit. Check quantity limits",
            variant: "error",
            mode: "dismissable"
          })
        );
      })
  }

  updateCartItemInformation(cartItemId){
    let so_Frequency = localStorage.getItem('so_Frequency');
    console.log('so_frequency_In_UpdateCartInfo->',so_Frequency);
    console.log('cartItemId_In_UpdateCartInfo->',cartItemId);

    const fields = {};
    fields[ID_FIELD.fieldApiName] = cartItemId;
    fields[SO_FREQUENCY_FIELD.fieldApiName] = so_Frequency;

    console.log('updateCartItem Field->',fields);

    const recordInput = { fields };
    console.log(recordInput);

    updateRecord(recordInput)
        .then(() => {
               console.log('Record Updated Successfully!');
        })
        .catch(error => {
               console.log('Record Update Failed!!!',error);
        });

  }

 //Shubhada Changes 
 sendNotificationToProtectionModal(result)
 {
         console.log(`add to cart:: protection lwc called`);
         let message = { message: 'Protection',result:result };
         publish(this.messageContext, memberChannel, message);
 }

  /**
     * Handles a user request to add the product to a newly created wishlist.
     * On success, a success toast is shown to let the user know the product was added to a new list
     * If there is an error, an error toast is shown with a message explaining that the product could not be added to a new list
     *
     * Toast documentation: https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_toast
     *
     * @private
     */
  createAndAddToList() {
    let listname ='My List';
    console.log('communityId',communityId);
    console.log('this.recordId',this.recordId);
    console.log('this.resolvedEffectiveAccountId',this.resolvedEffectiveAccountId);
    console.log('listname',listname);
    createAndAddToList({
      communityId: communityId,
      productId: this.recordId,
      wishlistName: 'My List',
      effectiveAccountId: '0018B00000OsSXjQAN'
    })
      .then(() => {
        this.dispatchEvent(new CustomEvent("createandaddtolist"));
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: 'Product added to wishlist successfully',
            messageData: [this.displayableProduct.name, listname],
            variant: "success",
            mode: "dismissable"
          })
        );
      })
      .catch(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message:
              "{0} could not be added to a new list. Please make sure you have fewer than 10 lists or try again later",
            messageData: [this.displayableProduct.name],
            variant: "error",
            mode: "dismissable"
          })
        );
      });
  }


  /**
     * Ensures cart information is up to date
     */
  updateCartInformation() {
    getCartSummary({
      communityId: communityId,
      effectiveAccountId: this.resolvedEffectiveAccountId
    })
      .then(result => {
        this.cartSummary = result;
      })
      .catch(e => {
        // Handle cart summary error properly
        // For this sample, we can just log the error
        console.log(e);
      });
  }
}