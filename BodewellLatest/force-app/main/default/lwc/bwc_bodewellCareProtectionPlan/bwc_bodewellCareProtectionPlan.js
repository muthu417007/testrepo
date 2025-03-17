import { LightningElement, api, wire, track } from 'lwc';
import { CartSummaryAdapter } from 'commerce/cartApi';
import getProductDetails from '@salesforce/apex/BWC_ProtectionPlanController.getProductDetails';
import { SessionContextAdapter } from 'commerce/contextApi';
import memberChannel from '@salesforce/messageChannel/bwc_membership__c';
import { subscribe, MessageContext } from 'lightning/messageService';
import COMMUNITY_ID from '@salesforce/community/Id';
import { CurrentPageReference } from 'lightning/navigation';
import BWC_UI from '@salesforce/resourceUrl/BodewellTheme';
import getRelatedProPan from '@salesforce/apex/BWC_ProtectionPlanController.getRelatedProPan';
import getBuyerGroup from '@salesforce/apex/BWC_CartController.getBuyerGroup';
import BuyerGroup from '@salesforce/label/c.BWC_BuyerGroup';
import addDeliveryServices from '@salesforce/apex/BWC_ProtectionPlanController.addDeliveryServices';
import ServiceSKUChannel from "@salesforce/messageChannel/Bwc_ServicesSkuList__c";
import { NavigationMixin } from 'lightning/navigation';
import zipCodeChannel from '@salesforce/messageChannel/zipCodeChange__c';

import addPlanAdLineItem from '@salesforce/apex/BWC_ProtectionPlanController.addPlanAdLineItem';
export default class Bwc_bodewellCareProtectionPlan extends NavigationMixin(LightningElement) {
    _serviceContracts;
    mcodeServices;

    @api
    get serviceContracts() {
        return this._serviceContracts;
    }
    set serviceContracts(val) {
        this._serviceContracts = val;
        this.getProductData();
    }
    _cartItemId;
    @api
    get cartItemId() {
        return this._cartItemId;

    }
    set cartItemId(val) {
        this._cartItemId = val;
        console.log('this._cartItemId===' + this._cartItemId);
        this.getRelatedPlan();
    }
    quantity;
    @api
    get productQuantity() {
        return this.quantity;
    }
    set productQuantity(value) {
        this.quantity = value;
        console.log('this.quantity===' + this.quantity);
        this.getRelatedPlan();
    }
    @api isMember;
    isGuestUser;
    _effectiveAccountId;
    @wire(SessionContextAdapter)
    wireSessionContext({ data }) {
        if (data) {
            console.log(`bwc_guestCartListener::wireSessionContext::data = ${JSON.stringify(data, null, 2)}`);
            this._effectiveAccountId = data.effectiveAccountId || '';
            this.isGuestUser = data.isLoggedIn;
            console.log('bwc_guestCartListener::wireSessionContext::data ='+data.buyerGroups[0].name);

            if(data.buyerGroups[0].name===BuyerGroup)
            {
                this.isMember=true;
            }
            else{
                this.isMember=false;
            }

        }
    }

   
    _productId;
    @api
    get productId() {
        return this._productId;
    }
    set productId(value) {
        this._productId = value;
        console.log('this._productId===' + this._productId);

    }

    @api cartId;

    Protection_LOGO = BWC_UI + '/icons/Bodewell-Care-Icon.svg';
    Protection_LOGO_PLUS = BWC_UI + '/icons/Bodewell-Care-Plus.svg';

    protectionPlansCarePlus;
    protectionPlansCareYearly;
    @track isLoading = false;
    @track isPlanFlag = false;
    @track noPlanFlag = false;
    carePlusFlag = false;
    careFlag = false;
    @api eventDispatched=false;
    getRelatedPlan() {
        
        console.log('this.cartItemId===' + this.cartItemId);

        if (this.cartItemId && this.quantity) {


            this.isLoading = true;

            getRelatedProPan({ cartItemId: this.cartItemId,quantity:this.quantity })
                .then(data => {


                    console.log('this.cartItemId===' + this.cartItemId);
                    console.log('this.cartItemId===' + this.cartItemId);
                    if (data) {

                        this.protectionPlansCarePlus = data.monthlyPlan;
                        this.protectionPlansCareYearly = data.yearlyPlan;


                        console.log('this.protectionPlansCarePlus===' + JSON.stringify(this.protectionPlansCarePlus));
                        console.log('this.protectionPlansCareYearly===' + JSON.stringify(this.protectionPlansCareYearly));
                        
                                                        let proPlanMonthly=this.protectionPlansCarePlus;
                                                        let proPlanYearly=this.protectionPlansCareYearly;
                        if(this.isMember)
                        {
                        
                            // service.BWC_Service_Price__c=(pbm.UnitPrice)* Decimal.valueOf(quantity);
                            // service.BWC_Member_Price__c=(pbmMember.memberPrice)* Decimal.valueOf(quantity);
                            if(this.protectionPlansCarePlus)
                            {
                                proPlanMonthly = proPlanMonthly.map(item => {
                                    if(item.BWC_Member_Price__c==item.BWC_Service_Price__c)
                                    {
                                        item.isSame=true;
                                    }
                                    else
                                    {
                                        item.isSame=false;
                            
                                    }
                                    if(item.BWC_Member_Price__c==0.0)
                                    {
                                        item.isfree=true;
                                    }
                                    else{
                                        item.isfree=false;
                                    }
                        return item;
                                });
                            }
                           
                        if(this.protectionPlansCareYearly)
                        {
                            proPlanYearly = proPlanYearly.map(item => {
                                if(item.BWC_Member_Price__c==item.BWC_Service_Price__c)
                                {
                                    item.isSame=true;
                                }
                                else
                                {
                                    
                                    item.isSame=false;
                        
                                }
                                if(item.BWC_Member_Price__c==0.0)
                                {
                                    item.isfree=true;
                                }
                                else{
                                    item.isfree=false;
                                }
                                return item;
                            });
                            
                        }
                        }
                           
                        
                        console.log('this.proPlanMonthly===' + JSON.stringify(proPlanMonthly));
                        console.log('this.proPlanYearly===' + JSON.stringify(proPlanYearly));
                        
                        this.protectionPlansCarePlus=proPlanMonthly;
                        this.protectionPlansCareYearly=proPlanYearly;
                        

                        if (this.protectionPlansCarePlus.length > 0 || this.protectionPlansCareYearly.length > 0) {
                            if (this.protectionPlansCarePlus.length > 0) {
                                this.carePlusFlag = true;
                                this.careFlag = false;




                            }
                            else {
                                this.careFlag = true;
                                this.carePlusFlag = false;
                            }


                        }
                        else {
                            this.isPlanFlag = true;
                            this.carePlusFlag = false;
                            this.careFlag = false;
                            this.isLoading = false;
                        }
                        console.log('this.protectionPlansCarePlus.length=' + this.protectionPlansCarePlus.length);

                        console.log('this.protectionPlansCareYearly.length=' + this.protectionPlansCareYearly.length);
                        this.isLoading = false;
                        console.log("Flags", this.careFlag, this.carePlusFlag, this.isPlanFlag,this.openModal);

                        
                       /*Madhavi 1/23
                       // if(this.careFlag==true || this.carePlusFlag==true){ 
                       if(this.callPPChangeEvent===true){
                        this.dispatchEvent(
                            new CustomEvent('protectionplanupdated'),
                            { bubbles: true, composed: true, openModal:this.openModal });
                        console.log("event dispatched from pp");
                        } */

                       // Dispatching a Protection Plan change event
                        this.dispatchEvent(
                            new CustomEvent('protectionplanupdated'),
                            { bubbles: true, composed: true });
                        //console.log("event dispatched from pp");
                        
                    }

                })
                .catch(error => {
                    this.isLoading = false;
                    console.log('error===' + JSON.stringify(error))
                })
        }
    }
    openModal = false;
    mcodeFlag = false;
    zipCode;
    //shubhada changes
    subscription = null;
    @wire(MessageContext)
    messageContext;
    connectedCallback() {
        
        if (localStorage.getItem('zipcode')) {
            //An Id key is in the local Storage
            this.localStorageZipCode = JSON.parse(localStorage.getItem('zipcode'));
            this.zipCode = this.localStorageZipCode.Zipcode;
            //Clear local storage after getting the values

        }
        this.handleSubscribe();
    }

    messageData;
    handleSubscribe() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(this.messageContext, memberChannel, (message) => {
            console.log('Protection------' + message.message);
            console.log('Result add to cart------' + JSON.stringify(message.result));
            if(message.result)
            {  let cartInfo = message.result;
                this._cartId = cartInfo.cartInformation.cartId;
                this._cartItemId = cartInfo.cartInformation.cartItemId;
                this.quantity=cartInfo.cartInformation.quantity;
    

            }
          
            this.messageData = message.message;
            if (this.messageData === 'Protection' && this._serviceContracts) {
                console.log('date------protection');

                this.openModalPlan();
            }

        });


        this.subscription = subscribe(this.messageContext, ServiceSKUChannel, (message) => {
            console.log('mcodeServices------' + JSON.stringify(message.mcodeServices));

            this.mcodeServices = message.mcodeServices;

            if ((this.mcodeServices).length > 0) {
              //  this.mcodeFlag = true;

            }

        });
      
        this.subscription = subscribe(this.messageContext, zipCodeChannel, (message) => {
            console.log(message.message);

            const fullAddress = message.message;
            this.zipCode = fullAddress.Zipcode;
         

        });
    }

    cartProFlag = false;
    checkoutFlag = false;
    sldsSize;
    orderFlag = false;
    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {

            // this.recordId = currentPageReference.attributes.recordId || null;
            this.pageAttributes = currentPageReference.attributes.name;
            // let states = currentPageReference.state;
            // let type = currentPageReference.type;
            console.log('currentPageReference', JSON.stringify(currentPageReference), this.pageAttributes);
            if (this.pageAttributes == 'Current_Cart' ) {
                this.cartProFlag = true;


            }
            else
                this.cartProFlag = false;
            console.log("bannerFlag", this.cartProFlag);
            if (this.pageAttributes == 'Current_Checkout') {
                this.sldsSize = 'slds-size_11-of-12';

            }
            else {
                this.sldsSize = 'slds-size_10-of-12';
            }
            if (this.pageAttributes == 'Order'|| this.pageAttributes == 'Current_Checkout') {
                this.orderFlag = true;
                
                this.checkoutFlag = true;
            }
        }
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
    _isSmallAppliance=false;
 @api get isSmallAppliance() {
        return this._isSmallAppliance;
    }
    set isSmallAppliance(val) {
        this._isSmallAppliance = val;
        console.log('_isSmallAppliance=='+this._isSmallAppliance);
       // this.getProductData();
    }
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
            this._serviceContracts = value?.fields?.BWC_Service_Contracts__c;
            this._isSmallAppliance=value?.fields?.BWC_Small_Appliance__c;
            console.log('_isSmallAppliance pdp=='+this._isSmallAppliance);
            this.getProductData();
            this.getProductServices();
        }
    }
    addServicesList=[];
    getProductServices()
    {
        //addDeliveryServices(String skuProduct,String zipcode)
        console.log('this._productSku'+this._productSku);
        console.log('this.zipCode'+this.zipCode);

        addDeliveryServices({skuProduct:this._productSku,zipCode:this.zipCode})
        .then(results => {
            console.log(`results add services: ${JSON.stringify(results)}`);
            
let services=results.addServices.services;
services = services.map(item => {
    this.addServicesList.push({description:item.description,id:item.id,marketing_text:item.marketing_text,required:item.required,price:0});
})
console.log('@@@ add services: '+JSON.stringify(this.addServicesList));
let pricesList=JSON.parse(results.prices).P_ITEM_LIST_TAB;
console.log('pricesList',pricesList);
let cloneServices=this.addServicesList;
for(let i=0;i<this.addServicesList.length;i++)
{
   for(let key in pricesList)
   {
    console.log('key',key);
    if(key==='ITEM_LIST'+i)
    {
       console.log(' pricesList[key].UNIT_PRICE'+ pricesList[key].UNIT_PRICE);
        cloneServices[i].price= pricesList[key].UNIT_PRICE;
    }
   }
}

console.log('cloneServices==='+JSON.stringify(cloneServices));
this.addServicesList=cloneServices;
if(this.addServicesList)
{
    this.mcodeFlag=true;
}
        })

        .catch(error => {
            console.log(`error add services:: ${JSON.stringify(error)}`);

        });
    }
 

    monthlyCarePlanList;
    yearlyCarePlanList;
    monthlyCarePlanListMember;
    yearlyCarePlanListMember;
    getProductData() {

        getProductDetails({ modelSku: this._serviceContracts, accId: this._effectiveAccountId, communityId: COMMUNITY_ID })
            .then(results => {
                console.log(`results: ${JSON.stringify(results)}`);
                if ((results.monthlyPlan).length > 0) {
                    this.monthlyCarePlanList = results.monthlyPlan;
                }
                if ((results.yearlyPlan).length > 0) {
                    this.yearlyCarePlanList = results.yearlyPlan;
                }
                if ((results.monthlyPlanMember).length > 0) {
                    this.monthlyCarePlanListMember = results.monthlyPlanMember;
                }
                if ((results.yearlyPlanMember).length > 0) {
                    this.yearlyCarePlanListMember = results.yearlyPlanMember;
                }


            })

            .catch(error => {
                console.log(`Error: ${JSON.stringify(error)}`);

            });
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
            console.log('Bwc_bodewellCareProtectionPlan Pricing data==' + JSON.stringify(value));
            this._pricing = value;
            this._originalPrice = value?.listPrice;
            this._negotiatedPrice = value?.negotiatedPrice;
            this._currencyCode = value?.currencyIsoCode;
            console.log('Bwc_bodewellCareProtectionPlan Pricing _originalPrice==' + this._originalPrice);
            console.log('Bwc_bodewellCareProtectionPlan Pricing _currencyCode==' + this._currencyCode);
            console.log('Bwc_bodewellCareProtectionPlan Pricing _negotiatedPrice==' + this._negotiatedPrice);
        }
    }




    callPPChangeEvent=false;
    openModalPlan() {
        this.openModal = true;
        /* Madhavi 1/23
        this.callPPChangeEvent=true;
        this.getRelatedPlan();
        console.log("this.openModal", this.openModal,this.callPPChangeEvent);
        */
    }
    cancelAndClose() {
        this.openModal = false;

    }



    _cartId;
    _cartItemId;
    _uniqueProductCount;
    _subTotal;
    @wire(CartSummaryAdapter)
    wireCartSummary({ data }) {
        if (data) {
            console.log(`Bwc_bodewellCareProtectionPlan::wireCartSummary::data = ${JSON.stringify(data, null, 2)}`);
            this._cartId = data.cartId;
            this._uniqueProductCount = data.uniqueProductCount;
            this._subTotal = data.grandTotalAmount;
        }

    }




/*
    openModalPlan() {
        this.openModal = true;
        this.callPPChangeEvent=true;
        this.getRelatedPlan();
        console.log("this.openModal", this.openModal,this.callPPChangeEvent);
    }
    cancelAndClose() {
        this.openModal = false;
    }
    */
   selectedMooCodes=[];
    AddandClose() {
        this.selectedMooCodes=[]
        let val = false;
        this.openModal = false;
        let radioList = this.template.querySelectorAll(`[data-name="Plan"]`);
        for (let i = 0; i < radioList.length; i++) {
            console.log('radioList[i].value' + radioList[i].value);
            if (radioList[i].checked == true) {
                console.log('radioList[i].value' + radioList[i].value);
                this.selectedPlan = radioList[i].value;
              


            }
        }

        let addOnList = this.template.querySelectorAll(`[data-name="addons"]`);
        //   const changedIndex = event.target.dataset.index;
        //  console.log('==changedIndexchangedIndex' + changedIndex);
        for (let i = 0; i < addOnList.length; i++) {
            if(addOnList[i].checked==true)
            {
              let   services = this.addServicesList.map(item => {
                if(item.id==addOnList[i].value)
                {
                    this.selectedMooCodes=[...this.selectedMooCodes,JSON.stringify(item)] ;
                }
                })
            }
        }
        console.log('this.selectedMooCodes==='+JSON.stringify(this.selectedMooCodes));

        this.addPlanAsLineItem(val,this.selectedMooCodes);
    }
    selectedPlan;
    handleCheckout() {
        this.selectedMooCodes=[];
        let val = true;
        this.openModal = false;
        let radioList = this.template.querySelectorAll(`[data-name="Plan"]`);
        for (let i = 0; i < radioList.length; i++) {
            console.log('radioList[i].value' + radioList[i].value);
            if (radioList[i].checked == true) {
                console.log('radioList[i].value' + radioList[i].value);
                this.selectedPlan = radioList[i].value;

           


            }
        }

        let addOnList = this.template.querySelectorAll(`[data-name="addons"]`);
        //   const changedIndex = event.target.dataset.index;
        //  console.log('==changedIndexchangedIndex' + changedIndex);
        for (let i = 0; i < addOnList.length; i++) {
            if(addOnList[i].checked==true)
            {
              let   services = this.addServicesList.map(item => {
                if(item.id==addOnList[i].value)
                {
                    this.selectedMooCodes=[...this.selectedMooCodes,JSON.stringify(item)] ;
                }
                })
            }
        }
        console.log('this.selectedMooCodes==='+JSON.stringify(this.selectedMooCodes));
      
        this.addPlanAsLineItem(val,this.selectedMooCodes);
    }



    addPlanAsLineItem(val,valMoocode) {
        console.log('this.selectedPlan' + this.selectedPlan);
        console.log('this._cartId' + this._cartId);
        console.log('this._cartItemId' + this._cartItemId);
        console.log('this.quantity' + this.quantity);
        //  (String proId,string cartId,string cartItemId)
        addPlanAdLineItem({ proId: this.selectedPlan, cartId: this._cartId, cartItemId: this._cartItemId,quantity:this.quantity, moocodeSelected:valMoocode,zipCode:this.zipCode})
            .then(result => {
                console.log('Protection result===' + JSON.stringify(result));
                if (this.cartProFlag == false && val == true) {
                    this.navigateToCheckout();

                }
                if (this.cartProFlag == true) {
                    this.getRelatedPlan();
                    this.isPlanFlag = false;
                }
            })
            .catch(error => {
                console.log(' protection error===' + JSON.stringify(error));


            })
    }


    navigateToCheckout() {
        const navContextPageName = this.isGuestUser ? 'Current_Checkout' : 'Login';
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: navContextPageName,
            }

        });
        setTimeout(() => {
            window.location.reload();
        }, 2000);
    }


}