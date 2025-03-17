import { LightningElement, api, wire, track } from 'lwc';
import getProductServices from '@salesforce/apex/BWC_ProductViewServicesController.getProductServices';
import zipCodeChannel from '@salesforce/messageChannel/zipCodeChange__c';
//import addRelatedToCart from '@salesforce/apex/BWC_ProductViewServicesController.bwc_CreateCartItems';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import { getRecord } from 'lightning/uiRecordApi';
import User_Id from '@salesforce/user/Id';
import UserAccountIdFIELD from '@salesforce/schema/User.AccountId';
import getBuyerGroup from '@salesforce/apex/BWC_CartController.getBuyerGroup';

import { CurrentPageReference } from 'lightning/navigation';
import { ProductAdapter, ProductPricingAdapter } from 'commerce/productApi';
import ServiceSKUChannel from '@salesforce/messageChannel/Bwc_ServicesSkuList__c';
export default class Bwc_bundleProductServices extends LightningElement {
    sessionStorageZipCode;
    isLoading = true;
    isMember = false;
    localStorageZipCode;
    _productSKU;
    _accountId;
    deliverySKU = [];
    installationSKU = [];
    @track serviceSku = [];
    @track _deliveryServices = [];
    @track deliveryFlag=false;

    @track installationFlag=false;
    @track _installationServices;
    publisherMessage = '';
    subscription = null;

    @wire(MessageContext)
    messageContext;
    connectedCallback() {
        // console.log('connected callback');
        //check if any values were passed in
        // if (sessionStorage.getItem('zipcode')) {
        //     //An Id key is in the session Storage
        //     this.sessionStorageZipCode = JSON.parse(sessionStorage.getItem('zipcode'));
        //     this.zipCode = this.sessionStorageZipCode.Zipcode;
        //     //Clear session storage after getting the Id

        // }

        if (localStorage.getItem('zipcode')) {
            //An Id key is in the local Storage
            this.localStorageZipCode = JSON.parse(localStorage.getItem('zipcode'));
            this.zipCode = this.localStorageZipCode.Zipcode;
            //Clear local storage after getting the values

        }
        //console.log(' sessionStorageOptionId' + this.sessionStorageZipCode);
        //console.log(' localStorageOptionId' + this.localStorageZipCode);



        this.handleSubscribe();


    }
    @wire(getRecord, { recordId: User_Id, fields: [UserAccountIdFIELD] })
    currentUserInfo({ error, data }) {
        if (data) {

            this._accountId = data.fields.AccountId.value;
            console.log('data===' + JSON.stringify(data));

        } else if (error) {
            this.error = error;
        }
    }
    @wire(getBuyerGroup, { acctId: '$_accountId' })
    buyerGroups({ data, error }) {

        if (data) {
            console.log("buyerGroups data" + JSON.stringify(data));
            console.log("buyerGroups acctId" + this._accountId);
            //considering user belongs to only one buyer group at a time

            if (data[0].BuyerGroup != undefined && data[0].BuyerGroup.Name != undefined) {
                if (data[0].BuyerGroup.Name === 'Member') {
                    this.isMember = true;

                }
                else {
                    this.isMember = false;

                }
            }


        }
        else if (error) {
            console.log('buyerGroups error ' + JSON.stringify(error));
        }
    }
    mcodeServices;
    mcodesListSKU = [];
    getProductServices(val, zip) {
        this.isLoading = true;
        this.deliverySKU = [];
        this.installationSKU = [];
        this._deliveryServices = [];
        this._installationServices=[];
        this.mcodesListSKU = [];
        getProductServices({ skuProduct: val, zipcode: zip })
            .then(results => {
                this.serviceSku = [];
                this._deliveryServices = [];
                console.log('zip ==' + zip);
                console.log('results==' + JSON.stringify(results));
                let deliveryServicesNew = results.deliveryServices;


                if ((results.deliveryServices).length > 0) {
                    // console.log('true');
                    this.deliveryFlag = true;
                    for (let key in deliveryServicesNew) {
                        this.serviceSku.push(deliveryServicesNew[key].Product_Sf_Id__c);
                        this.deliverySKU.push(deliveryServicesNew[key].Product_SKU__c);
                        if (deliveryServicesNew[key].BWC_Member_Price__c === 0) {
                            this._deliveryServices.push({ label: deliveryServicesNew[key].MasterLabel, price: deliveryServicesNew[key].Price__c, memberPrice: deliveryServicesNew[key].BWC_Member_Price__c, description: deliveryServicesNew[key].Description__c, free: true })

                        }
                        else {
                            this._deliveryServices.push({ label: deliveryServicesNew[key].MasterLabel, price: deliveryServicesNew[key].Price__c, memberPrice: deliveryServicesNew[key].BWC_Member_Price__c, description: deliveryServicesNew[key].Description__c, free: false })

                        }
                    }
                    this.isLoading = false;
                }
                else {
                    // console.log('false');
                    this.deliveryFlag = false;
                    this.isLoading = false;
                }
                this._installationServices = results.installationServices;
                if ((results.installationServices).length > 0) {
                    //console.log('true');
                    this.installationFlag = true;
                    for (let key in this._installationServices) {
                        this.serviceSku.push(this._installationServices[key].Product_Sf_Id__c);
                        this.installationSKU.push(this._installationServices[key].Product_SKU__c);
                    }
                    this.isLoading = false;
                }
                else {
                    // console.log('false');
                    this.installationFlag = false;
                    this.isLoading = false;
                }


                let McodeServices = results.mcodesServices;
                this.mcodeServices= results.mcodesServices;

                if ((results.mcodesServices).length > 0) {

                    for (let key in McodeServices) {
                        this.mcodesListSKU.push(McodeServices[key].Product_SKU__c);

                    }
                    this.isLoading = false;
                }
                console.log('MCodes List===' + JSON.stringify(this.mcodesListSKU));

                this.sendSkuListToAddToCartButton();
            })
            .catch(error => {
                // console.log('Error:' + JSON.stringify(error));
                this.isLoading = false;
            })


    }

    sendSkuListToAddToCartButton() {

        let message = {
            message: this.deliverySKU,
            message1: this.installationSKU, message2: this.zipCode, mcodesSKU: this.mcodesListSKU,
            mcodeServices:this.mcodeServices
        };
        publish(this.messageContext, ServiceSKUChannel, message);
    }
    /**
   * The product sku
   * @type {?JsonData}
   */

    @api
    get productSku() {
        return this._productSKU;
    }
    set productSku(val) {
        // console.log('val===' + val);

        if (val) {
            this._productSKU = val?.fields?.StockKeepingUnit;
        }


        if (this._productSKU && this.zipCode) {
            this.getProductServices(this._productSKU, this.zipCode);
        }
        else {
            this.isLoading = false;
        }
    }

    handleSubscribe() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(this.messageContext, zipCodeChannel, (message) => {
            console.log(message.message);

            const fullAddress = message.message;
            this.zipCode = fullAddress.Zipcode;
            if (this._productSKU && this.zipCode) {
                this.getProductServices(this._productSKU, this.zipCode);
            }
            else {
                this.isLoading = false;
            }

        });
    }

    sendSkuListToAddToCart() {
        // console.log('this.serviceSku' + this.serviceSku);
        let message = { message: this.serviceSku };
        publish(this.messageContext, ServiceSKUChannel, message);

    }
    productIdInstance;
    unitPrice;
    //String productId,String quantity,String unitPrice,String sku,List<String> servicesListDelivery,List<String> servicesListInstallation
    addToCartRelated() {
        console.log('installationSKU' + this.installationSKU);
        addRelatedToCart({ productId: this.productIdInstance, quantity: "1", unitPrice: this.unitPrice, sku: this._productSKU, servicesListDelivery: this.deliverySKU, servicesListInstallation: this.installationSKU })
            .then(result => {


                console.log('result===' + JSON.stringify(result));
            })
            .catch(error => {
                console.log('error===' + JSON.stringify(error));
            })
    }
    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            this.productIdInstance = currentPageReference.attributes.recordId;
            // console.log('pagerefId>>>'+this.productIdInstance);
        }
    }

    @wire(ProductPricingAdapter, { productId: '$productIdInstance' })
    ProductPricingAdapterMethod({ error, data }) {
        if (data) {
            // console.log('ProductPricingAdapter data-->',data);

            this.unitPrice = data.unitPrice

        }
        else {
            //console.log('error order-->', error);
        }
    }


}