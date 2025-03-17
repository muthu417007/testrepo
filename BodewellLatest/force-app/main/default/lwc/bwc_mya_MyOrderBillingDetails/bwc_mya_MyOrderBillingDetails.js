import { LightningElement,wire ,api} from 'lwc';
import getBodewellOrderSummary from '@salesforce/apex/BWC_OrderConfirmationController.getOrderDeliveryPaymentSummary';
import { CurrentPageReference } from 'lightning/navigation';
export default class Bwc_mya_MyOrderBillingDetails extends LightningElement {

orderBillingDetails;
_rid;
  
@api
get rid() {
    return this._rid;
}
set rid(value) {
    this._rid = value;
   console.log(' billing this.rid==='+ this._rid);
   //this.getRelatedServices();
}

displayPaymentFlag=true;
bgcolor = 'padding: 10px;background-color: white;';
itemTitle='padding-left: 20px;';


@wire(CurrentPageReference)
getStateParameters(currentPageReference) {
    if (currentPageReference) {
        if(currentPageReference.state.recordid)
        {
            this._rid = currentPageReference.state.recordid;
            this.itemTitle='padding-left: 20px;';
        }
        if(currentPageReference.state.orderNumber)
        {
            this._rid = currentPageReference.state.orderNumber;
            this.displayPaymentFlag = false;
            this.bgcolor = 'background-color: none;';
            this.itemTitle='padding-left: none;';
        }
       
        console.log('this.rid order summary ',this._rid );
        
    }
}

    @wire(getBodewellOrderSummary, { orderSummaryId: '$_rid'})
    BodewellOrderSummary({data , err}) {
        console.log('this.bodewell Summary Orders line 21',data);
         if (data) {
         this.orderBillingDetails=data;
         console.log('bodewell orders');
        
         }
     if(err)
     {
        console.log('Billing error '+JSON.stringify(err));
     }
   } 

  
}