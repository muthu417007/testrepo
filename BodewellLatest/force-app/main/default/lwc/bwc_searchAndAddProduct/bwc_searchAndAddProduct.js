import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
//import { ProductAdapter, ProductPricingAdapter } from 'commerce/productApi';
import getProductBySearchKey from '@salesforce/apex/BWC_OrderOnBehalfOfController.getProductBySearchKey';
import getPriceFromConnectApi from '@salesforce/apex/BWC_OrderOnBehalfOfController.getPriceFromConnectApi'; //POC


export default class Bwc_searchAndAddProduct extends LightningElement {

    @api selectedStoreId;
    @api selectedUserAccountId;
    showAddProductModal = false;
    searchKey;
    @track productInfo = {};
    @track productInfoAvailable = false;
    @track orderQty = "1";
    @track productListToDisplay = [];
    @track productList = [];
    showProductList = false;
    isProductSelected = false;
    minimunLengthError = false;
    numSwatches = 6; //POC
    swatchItems = [{label: 'green', value: 'green', selected: false, disabled: false, url: 'https://products-salsify.geappliances.com/image/upload/s--2XMPRW57--/305cb8f8166d58df5cb1a69bd02e5397f8f846f8.jpg'}, {label: 'blue', value: 'blue', selected: false, disabled: false, url: 'https://products-salsify.geappliances.com/image/upload/s--trkghcRV--/f4b23389b97fad75932e0a69c16f3ce2771b5ea2.jpg'}];//POC


    // @wire(ProductAdapter, {
    //     productSku: '$searchKey'
    // })
    // wireDefaultVariantProduct({data}) {
    //     if (data) {
    //         console.log('Product from Wire Is > ', data);
    //     }
    // }

    connectedCallback(){
        console.log('User and Store Id in Search Product > ',this.selectedStoreId, ' Selected User Acc > ',this.selectedUserAccountId);
    }

    handleAddProductClick(){
        this.showAddProductModal = true;
    }
    
    handleCancelClick(){
        this.showAddProductModal = false;
        this.productInfoAvailable = false;
        this.productInfo = {};
        this.productList = [];
        this.productListToDisplay = [];
    }

    handlePreviousClick(){

    }

    handleNextClick(){
        if(this.productInfo && this.orderQty){
            const customEvt = new CustomEvent('addproductnextclick', {
                detail: {product: this.productInfo, quantity: this.orderQty}
            });
            this.dispatchEvent(customEvt);
        }
    }

    hideModalBox() {
        this.showAddProductModal = false;
        this.productInfoAvailable = false;
        this.productInfo = {};
        this.productList = [];
        this.productListToDisplay = [];
    }

    handleSearchInput(event){
        const inputValue = event.target.value;
        this.searchKey = inputValue;
        console.log('Value Entered -> ',this.searchKey);
    }

    async handleSearchClick(event){
        console.log('Search Key ', this.searchKey, ' Selected Store > ',this.selectedStoreId, ' Selected Account Is > ',this.selectedUserAccountId);
        if(this.searchKey?.length < 3){
            this.minimunLengthError = true;
        }else if(this.selectedStoreId && this.selectedUserAccountId){
            console.log('If passed');
            this.minimunLengthError = false;
            const product = await getProductBySearchKey({accountId: this.selectedUserAccountId, productSku: this.searchKey});
            this.productList = product;
            console.log('Product Is > ',product);
            if(product && product.length){
                //this.productInfo = product[0];
                this.productInfoAvailable = true;
                this.showProductList = true;
            } else{
                const evt = new ShowToastEvent({
                    title: '',
                    message: `No product found with matching sku - ${this.searchKey}`,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }
        }
    }

    handleQuantityChange(event){
        this.orderQty = event.target.value;
    }

    handleAddClick(){
        if(this.productInfoAvailable){
            this.productInfo.orderQty = this.orderQty;
            this.productInfo.lineSubtotal = this.orderQty * this.productInfo.unitPrice;
            this.productListToDisplay.push(this.productInfo);
            this.showAddProductModal = this.productInfoAvailable = false;
            this.orderQty = "1"; 
            this.productInfo = {};
        }
    }

    handleOnChanged(event){   //POC
     const detail = event.detail;
     console.log('Event Details Are > ',detail);
    }

    handeClickFromList(event){
        const selectedPdtId = event.target.dataset.id;
        this.productInfo = this.productList.find(pdt => pdt.Id === selectedPdtId);
        this.isProductSelected = true;
        this.showProductList = false;
    }
}