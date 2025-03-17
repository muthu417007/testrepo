import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Bwc_orderOnBehalfOf extends NavigationMixin(LightningElement) {

    @track currentStep = '1';
    @track showUserStoreSelector = true;
    @track showProductSelector = false;
    @track showAddressSelector = false;
    selectedStoreId;
    selectedUserAccountId;
    zipCodeEntered;
    selectedProduct;
    orderedQuantity;

    connectedCallback(){

    }

    handleOrderStoreNextClick(event){
        console.log('Event On Parent Is >> ',event.detail);
        this.selectedStoreId = event.detail.store;
        this.selectedUserAccountId = event.detail.user;
        this.zipCodeEntered = event.detail.zipCode;
        const curntStep = parseInt(this.currentStep) + 1;
        const updatedStep = curntStep?.toString();
        this.currentStep = '';
        this.currentStep = updatedStep;
        console.log(' this.currentStep Is > ',this.currentStep,' Type Of > ',typeof this.currentStep);
        this.showUserStoreSelector = false;
        this.showProductSelector = true;
    }

    handleOrderClick(){
        console.log("Order On Behalf Clicked >> ");
        this[NavigationMixin.Navigate]({
            type: "standard__navItemPage",
            attributes: {
                apiName: "Order_On_Behalf_Of"
            }
        });
    }

    handleProductNextClick(event){
        const pdtInfo = event.detail.productInfo;
        const orderQty = event.detail.quantity;
        this.showAddressSelector = true;
        this.showProductSelector = false;
        this.selectedProduct = pdtInfo;
        this.orderedQuantity = orderQty;
        this.updateProgressBar();
        console.log('Order Qty > ', this.orderedQuantity, ' PDT > ',this.selectedProduct);
    }

    updateProgressBar(){
        const curntStep = parseInt(this.currentStep) + 1;
        const updatedStep = curntStep?.toString();
        this.currentStep = '';
        this.currentStep = updatedStep;
    }
}