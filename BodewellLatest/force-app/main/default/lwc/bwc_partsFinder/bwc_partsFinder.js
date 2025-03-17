import { LightningElement, api } from 'lwc';
import getProductBySearchKey from '@salesforce/apex/BWC_PartsSearchController.getProductBySearchKey';

export default class Bwc_partsFinder extends LightningElement {

    productSkuPassed = false;
    productToDisplay = false;
    partsExplorer = false;
    productsToDisplay = [];
    mfgSkuSelected;
    productId;
    initialSearch = true;

    @api productSku;
    @api isCommerceView;
    @api currentUser;
    @api isLaunchedViaManageParts;

    async connectedCallback() {
        this.currentUser = this.currentUser ? this.currentUser : 'Service';
        this.isLaunchedViaManageParts = this.isLaunchedViaManageParts == null || this.isLaunchedViaManageParts === undefined ? false : this.isLaunchedViaManageParts;
        this.productSkuPassed = this.productSku ? true : false;
        if(this.productSkuPassed){
            const result = await getProductBySearchKey({key : this.productSku});
            if(result.products.length > 0){
                if(!this.productsToDisplay.showPDP){
                    this.productsToDisplay = result;
                    this.productToDisplay = true;
                } else if(this.productsToDisplay.showPDP){
                    this.partsExplorer = true;
                    this.productId = result.products[0].Id;
                    this.mfgSkuSelected = result.produts[0].StockKeepingUnit;
                }
            } else{
                this.productSkuPassed = false;
                this.initialSearch = false;
            }
        }
    }

    handleSelectedPartEvent(event){
        const data = event.detail;
        if(data){
            this.partsExplorer = true;
            this.productToDisplay = false;
            this.mfgSkuSelected = data.mfgskuClicked;
            this.productId = data.productIdClicked;
        }
    }

    handlePartsSearchResult(event){
        this.productToDisplay = true;
        this.productsToDisplay = event.detail;
        this.productSkuPassed = true;
    }

    handlePartsFinderClose(event){
        this.partsExplorer = false;
    }
}