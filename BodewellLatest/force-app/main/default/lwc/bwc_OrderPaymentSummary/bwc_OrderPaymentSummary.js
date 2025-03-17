import { LightningElement,api ,wire} from 'lwc';
import getOrderDeliveryPaymentSummary from '@salesforce/apex/BWC_OrderConfirmationController.getOrderDeliveryPaymentSummaryStripe';
export default class Bwc_OrderPaymentSummary extends LightningElement {

    orderPaymentDetails;
    @api rid;
    @wire(getOrderDeliveryPaymentSummary, { orderSummaryId: '$rid'})
    BodewellPaymentSummary({data , err}) {
        console.log(' PaymentSummary Orders',data);
         if (data) {
         this.orderPaymentDetails=data;
        }
        else{
            console.log(err)  
            this.rid=this.rid+' ';
        }
      
   }
}