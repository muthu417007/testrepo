import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import CHECKOUT from "./bwc_chckoutInstallationServicesCheckout.html";
import CART from "./bwc_checkoutInstallationServicesCart.html";
import getRelatedCartItem from '@salesforce/apex/BWC_ProductViewServicesController.bwc_getRelatedCartItem';
import addPlanAdLineItemcartCodes from '@salesforce/apex/BWC_ProtectionPlanController.addPlanAdLineItemcartCodes';
import addDeliveryServices from '@salesforce/apex/BWC_ProtectionPlanController.addDeliveryServices';

export default class Bwc_checkoutInstallationServices extends LightningElement {
    @api cartItemId;
    @track installationFlag = false;
    @track _installationServices;

    _zipCode;
    @api
    get zipCode() {
        return this._zipCode;
    }
    set zipCode(value) {
        this._zipCode = value;
        console.log('this._zipCode===' + this._zipCode);
        this.getRelatedServices();
        this.getProductServices();
    }

    _productSku;
    @api
    get skuPro() {
        return this._productSku;
    }
    set skuPro(value) {
        this._productSku = value;
        console.log('this._productSku===' + this._productSku);
        this.getRelatedServices();
        this.getProductServices();
    }


    quantity;
    @api
    get productQuantity() {
        return this.quantity;
    }
    set productQuantity(value) {
        this.quantity = value;
        console.log('this.quantity===' + this.quantity);
        this.getRelatedServices();
    }
    @api isMember;



    _productId;
    @api
    get productId() {
        return this._productId;
    }
    set productId(value) {
        this._productId = value;
        console.log('this._productId===' + this._productId);
        this.getRelatedServices();
    }

    @api cartId;
    isLoading = true;
    //  
    connectedCallback() {

        this.getRelatedServices();
    }
    //(String itemId,String zipCode,String skuProduct,String cartId,String quantity)



    @api brand = 'GEA';

    @track pageAttributes;
    @track cartPage = false;
    @track checkoutPage = false;

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {

            // this.recordId = currentPageReference.attributes.recordId || null;
            this.pageAttributes = currentPageReference.attributes.name;
            // let states = currentPageReference.state;
            // let type = currentPageReference.type;
            console.log('currentPageReference', JSON.stringify(currentPageReference), this.pageAttributes);
            if (this.pageAttributes == 'Current_Cart') {
                this.cartPage = true;
                console.log("cartPage", this.cartPage);
            }
            else
                this.checkoutPage = true;
            console.log("checkoutPage", this.checkoutPage);
        }
    }
    // UI render based on brand and user status
    render() {
        console.log("cartPage", this.cartPage);
        console.log("checkoutPage", this.checkoutPage);
        if (this.cartPage == true) {
            return CART;
        } else if (this.checkoutPage == true) {
            return CHECKOUT;
        }

    }
    getRelatedServices() {
        console.log('this.cartItemId===' + this.cartItemId);
        console.log('this._zipCode===' + this._zipCode);
        console.log('this.productId===' + this._productId);
        console.log('this.cartId===' + this.cartId);
        console.log('this.quantity===' + this.quantity);

        if (this.cartItemId && this._zipCode && this._productId && this.cartId && this.quantity) {


            this.isLoading = true;

            getRelatedCartItem({ itemId: this.cartItemId, zipCode: this._zipCode, skuProduct: this._productId, cartId: this.cartId, quantity: this.quantity })
                .then(data => {


                    console.log('this.productId===' + this.productId);
                    if (data) {
                        console.log('data' + data)
                        this._installationServices = data;
                        if (this._installationServices.length > 0) {
                            this.installationFlag = true;
                        }
                        else {
                            this.installationFlag = false;
                        }
                        let updatedCartItems = JSON.parse(JSON.stringify(this._installationServices));
                        if (this._installationServices.length > 0) {

                            updatedCartItems = updatedCartItems.map(item => {
                                if (item.BWC_Member_Price__c === 0) {
                                    item.free = true;
                                }
                                else {
                                    item.free = false;
                                    if (item.BWC_Member_Price__c === item.BWC_Service_Price__c) {
                                        item.isSame = true;
                                    }
                                    else {
                                        item.isSame = false;
                                    }
                                }

                                return item;

                            });
                        }
                        this._installationServices = updatedCartItems;
                        this.isLoading = false;
                        console.log('this._installationServices==' + JSON.stringify(this._installationServices));

                        // Dispatching a installation  change event
                        this.dispatchEvent(new CustomEvent('install'));

                    }
                })
                .catch(error => {
                    this.isLoading = false;
                    console.log('error===' + JSON.stringify(error))
                })
        }
        this.isLoading = false;
    }


    openModalServices = false;
    openMoocodesChange() {
        this.openModalServices = true;
    }
    cancelAndClose() {
        this.openModalServices = false;
    }
    mcodeFlag = false;

   @track addServicesList = [];
    getProductServices() {
        this.addServicesList = [];
        //addDeliveryServices(String skuProduct,String zipcode)
        console.log('this._productSku' + this._productSku);
        console.log('this.zipCode' + this._zipCode);

        addDeliveryServices({ skuProduct: this._productSku, zipCode: this._zipCode })
            .then(results => {
                console.log(`results add services: ${JSON.stringify(results)}`);
                this.addServicesList = [];
                let services = results.addServices.services;
                services = services.map(item => {
                    this.addServicesList.push({ description: item.description, id: item.id, marketing_text: item.marketing_text, required: item.required, price: 0 });
                })
                console.log('@@@ add services: ' + JSON.stringify(this.addServicesList));
                let pricesList = JSON.parse(results.prices).P_ITEM_LIST_TAB;
                console.log('pricesList', pricesList);
                let cloneServices = this.addServicesList;
                for (let i = 0; i < this.addServicesList.length; i++) {
                    for (let key in pricesList) {
                        console.log('key', key);
                        if (key === 'ITEM_LIST' + i) {
                            console.log(' pricesList[key].UNIT_PRICE' + pricesList[key].UNIT_PRICE);
                            cloneServices[i].price = pricesList[key].UNIT_PRICE;
                        }
                    }
                }

                console.log('cloneServices===' + JSON.stringify(cloneServices));
                this.addServicesList = cloneServices;
                if (this.addServicesList) {
                    this.mcodeFlag = true;
                }
            })

            .catch(error => {
                console.log(`error add services:: ${JSON.stringify(error)}`);

            });
    }

    selectedMooCodes = [];
    AddandClose() {
        this.selectedMooCodes = []
        this.openModalServices = false;
        this.openModalServices = false;


        let addOnList = this.template.querySelectorAll(`[data-name="addons"]`);
        //   const changedIndex = event.target.dataset.index;
        //  console.log('==changedIndexchangedIndex' + changedIndex);
        for (let i = 0; i < addOnList.length; i++) {
            if (addOnList[i].checked == true) {
                let services = this.addServicesList.map(item => {
                    if (item.id == addOnList[i].value) {
                        this.selectedMooCodes = [...this.selectedMooCodes, JSON.stringify(item)];
                    }
                })
            }
        }
        console.log('this.selectedMooCodes=== cart' + JSON.stringify(this.selectedMooCodes));

        this.addPlanAsLineItem(this.selectedMooCodes);
    }

    addPlanAsLineItem(codes) {
        //String proId,string cartId,string cartItemId,String quantity,List<String> moocodeSelected
        //his.cartItemId && this._zipCode && this._productId && this.cartId && this.quantity
        addPlanAdLineItemcartCodes({proId:'test',cartId:this.cartId,cartItemId:this.cartItemId,quantity:this.quantity,moocodeSelected:codes,zipCode:this._zipCode})
        .then(result => {
            console.log('moocodes result===' + JSON.stringify(result));
           this.getRelatedServices();
        })
        .catch(error => {
            console.log(' moocodes error===' + JSON.stringify(error));


        })
    }

}