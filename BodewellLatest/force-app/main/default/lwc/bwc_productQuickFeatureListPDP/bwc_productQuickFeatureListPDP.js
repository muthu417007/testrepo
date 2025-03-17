/**
 * @description Display a quick list of product features and anchor to detailed features on PDP page 
 */

import { LightningElement, api, wire } from 'lwc';
import BWC_MessageChannel from '@salesforce/messageChannel/Bwc_MessageChannel__c';
import { publish, MessageContext } from 'lightning/messageService';
export default class Bwc_productQuickFeatureListPDP extends LightningElement {
  /**
      * @type {?JsonData}
      * to save all features 
      */
  _features;
  /**
   * @type {?JsonData}
   * @private
   */
  _productDetails;
  /**
   * @type {?JsonData}
   * to take 1st three features 
   */
  firstThreeItemsFeature;
  /**
   * to get product dimension from spec field
   * @type {?JsonData}
   * @private
   */
  _specDetails;
  _productDimensions;
height;
width;
depth;

  /**
   * The product data .
   * @type {?JsonData}
   */
  @api
  get product() {
    return this._productDetails;
  }
  set product(val) {
    this._productDetails = val;

    if (val) {
      this._specDetails = JSON.parse(val?.fields?.BWC_ProductSpecAndDetails__c);
      this._features = JSON.parse(val?.fields?.BWC_Benefit_Copy__c);
this.height=val?.fields?.BWC_Height__c;
this.width=val?.fields?.BWC_Width__c;
this.depth=val?.fields?.BWC_Depth__c;
    }

    if (this._features) {
      this.divideJSON(this._features);

    }

  }
  // Method to divide the main JSON into three different JSON objects function 
  divideJSON(mainJSON) {
    this.firstThreeItemsFeature = { "BenefitCopy": mainJSON.BenefitCopy.slice(0, 3) };


  }

  @wire(MessageContext)
  messageContext;
  message;
  // LMS used to send scroll event to Bwc_productDetailTabs for scrolling to that div element.
  scrollHandler(event) {
    let message = { message: 'scroll' };
    publish(this.messageContext, BWC_MessageChannel, message);

  }

}