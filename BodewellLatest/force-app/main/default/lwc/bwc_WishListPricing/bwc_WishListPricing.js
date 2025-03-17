import { LightningElement, wire, api, track } from 'lwc';
import getProductPrice from "@salesforce/apex/BWC_GetInfo.getProductPrice";
import getAccount from '@salesforce/apex/BWC_WaterFilterVariationController.getAccount';
import USER_ID from '@salesforce/user/Id';
import communityId from "@salesforce/community/Id";
export default class Bwc_WishListPricing extends LightningElement {
  @api productId;
  loggedInUserAccountId;
  productPrices;
  communityId = communityId;

  @wire(getAccount, { userId: USER_ID })
  AccountDetails({ data, error }) {
    if (data) {
      this.loggedInUserAccountId = data;
      console.log('loggedInUserAccountId from wish list pricing', this.loggedInUserAccountId);
    }
  }

  /*  @wire(getProductPrice, {
        communityId: communityId,
        productId: "$recordId",
        effectiveAccountId: "$resolvedEffectiveAccountId"
      })
      productPrice; */

  @wire(getProductPrice, {
    communityId: '$communityId',
    productId: '$productId',
    effectiveAccountId: '$loggedInUserAccountId'
  })
  productPrices(
    { error, data }) {
    if (data) {
      this.productPrices = data;
      console.log('this.productPrices', this.productPrices);
    }
    else if (error) {
      console.log("error");
    }
  }


}