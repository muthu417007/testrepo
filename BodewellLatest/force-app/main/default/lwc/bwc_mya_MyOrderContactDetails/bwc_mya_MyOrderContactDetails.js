import { LightningElement,wire } from 'lwc';
import getOrderDeliveryGroupSummary from '@salesforce/apex/BWC_OrderConfirmationController.getOrderDeliveryGroupSummary';
import { CurrentPageReference } from 'lightning/navigation';

export default class Bwc_mya_MyOrderContactDetails extends LightningElement {
    orderBillingDetails;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.rid = currentPageReference.state.recordid;
            console.log('this.rid order summary ',this.rid );
            
        }
    }
    @wire(getOrderDeliveryGroupSummary, { orderSummaryId: '$rid'})
    BodewellShippingSummary({data , err}) {
        console.log('this.bodewell Summary Orders',data);
         if (data) {
         this.orderBillingDetails=data;
        console.log('this.orderBillingDetails',this.orderBillingDetails);
        }
         if (err) {
            console.log(err)
         }
    }
         
}