import { LightningElement, api, wire } from 'lwc';
import { navigate, NavigationContext } from 'lightning/navigation';
import COMMUNITY_ID from '@salesforce/community/Id';
import USER_ID from '@salesforce/user/Id';

import getAccount from '@salesforce/apex/BWC_WaterFilterVariationController.getAccount';
import getProductPrice from '@salesforce/apex/BWC_WaterFilterVariationController.getProductPrice';
import getProductDetails from '@salesforce/apex/BWC_WaterFilterVariationController.getProductDetails'
export default class Bwc_waterFilterVariations extends LightningElement {

    _saveAmount;
    _navigationContext;
   
    loggedInUserAccountId;


    /**
   * @type {?Boolean}
   * @private
   */

    _isThreePack = false;
    _isSinglePack = false;

    /**
     * @type {?String}
     * @private
     */
    _singlePackModel;
    relatedProductId;
    _threePackModel;
    _modelSku;
    _productDetails;
    _productPricing;


    @wire(NavigationContext)
    wiredNavigationContext(context) {
        this._navigationContext = context;
    }
    connectedCallback() {


    
        this.getAccountData();
    }

    /**
         * The product pricing  data 
         * @type {?JsonData}
         */


    @api
    get pricing() {
        return this._productPricing;
    }
    set pricing(val) {
        this._productPricing = val;
        //console.log('_productPricing====' + JSON.stringify(val));
    }

    /**
         * The product   data 
         * @type {?JsonData}
         */
    @api
    get product() {
        return this._productDetails;
    }
    set product(val) {
        this._productDetails = val;
        //console.log('val====' + JSON.stringify(val));

        this._singlePackModel = val?.fields?.BWC_Single_Pack_Model__c;
        this._threePackModel = val?.fields?.BWC_Three_Pack_Model__c;
       // console.log(' this._singlePackModel====' + this._singlePackModel);
       // console.log(' this._threePackModel====' + this._threePackModel);
        if (this._singlePackModel) {
            this._isSinglePack = true;
            this._isThreePack = false;
            this._modelSku = this._singlePackModel;
        }
        if (this._threePackModel) {
            this._isThreePack = true;
            this._isSinglePack = false;
            this._modelSku = this._threePackModel;
        }
        //console.log('this._modelSku====' + this._modelSku);
        if (this._modelSku != undefined) {
            this.getProductData();
        }


    }
    getProductData() {

        getProductDetails({ modelSku: this._modelSku, accId: this.loggedInUserAccountId, communityId: COMMUNITY_ID })
            .then(results => {
               // console.log(`results: ${JSON.stringify(results)}`);
                this.relatedProductId = results.products[0].id;
                getProductPrice({ communityId: COMMUNITY_ID, productId: results.products[0].id, accId: this.loggedInUserAccountId })
                    .then(resultPrice => {
                       // console.log(`resultPrice: ${JSON.stringify(resultPrice)}`);
                        if (this._isThreePack) {
                            this._saveAmount = Math.trunc(((this._productPricing.unitPrice) * 3) - (resultPrice.unitPrice));

                        }
                        // this._saveAmount=Math.trunc((resultPrice.unitPrice)-(this._productPricing.unitPrice));
                       // console.log(this._saveAmount);

                    })
            })

            .catch(error => {
                //console.log(`Error: ${JSON.stringify(error)}`);
                this._isSinglePack = false;
                this._isThreePack = false;
            });
    }


    onclickHandler(event) {
     
        navigate(this._navigationContext, {
            type: 'standard__recordPage',
            attributes: {
                objectApiName: 'Product2',
                recordId: this.relatedProductId,
                actionName: 'view'
            }
        });
    }


    getAccountData() {
        getAccount({ userId: USER_ID })
            .then(result => {
                //console.log('AccountId:' + result);
                this.loggedInUserAccountId = result;
            })
            .catch(error => {
                this.error = error;
            })
    }
}