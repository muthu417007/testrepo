import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import cancelOrderRequest from '@salesforce/apex/Bwc_OrderCancelButtonController.cancelOrderRequest';
export default class Bwc_OrderCancelButton extends LightningElement {

    orderSummaryIdInstance;
    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            console.log("currentPageReference-->", currentPageReference.attributes.recordId);
            this.orderSummaryIdInstance = currentPageReference.attributes.recordId;
        }
    }
    cancelOrderClick() {
        cancelOrderRequest({
            orderSummaryIdInstance: this.orderSummaryIdInstance
        })
            .then(result => {
                console.log('success');
                window.location.replace(window.location.origin+'/bodewellCommerce/OrderSummary/OrderSummary/Default');
            })
            .catch(error => {
                console.log('error');
            });
    }
}