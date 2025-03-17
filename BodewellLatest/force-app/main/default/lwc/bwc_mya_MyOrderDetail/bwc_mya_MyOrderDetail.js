import { LightningElement,track,wire,api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getOrderDeliveryPaymentSummary from '@salesforce/apex/BWC_OrderConfirmationController.getOrderDeliveryPaymentSummary';
//import getBodewellOrderItems from '@salesforce/apex/BWC_OrderConfirmationController.getBodewellOrdersItems'
import MEMBER_SKU from '@salesforce/label/c.BWC_BodewellMemberSKU';
import basePath from '@salesforce/community/basePath';
export default class Bwc_mya_MyOrderDetail extends LightningElement {
     
rid;
orderPaymentDetails;
bodewellOrderItems;
@track _memberSKU = false;
@track _memberList = [];

get homeUrl() {
    return basePath+'/mya-my-orders';
}

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
      if (currentPageReference) {
          this.rid = currentPageReference.state.recordid;
          console.log('this.rid order summary ',this.rid );
      }
  }

 /* @wire(getBodewellOrderItems, {Id: '$rid'})
  getBodewellOrderItems({data , err}){
    console.log('Bodewell Orders', data);
    if(data){
     this.bodewellOrderItems =data;
     console.log('Bodewell Order Items',this.bodewellOrderItems);
     this.getBodewellMember();
    }
    if(err){
    console.log(err);
     }
  } */

     getBodewellMember(){
     if(this.bodewellOrderItems){
        console.log('inside getBodewellMember',this.bodewellOrderItems);
        for (let i = 0; i < this.bodewellOrderItems.length; i++) {
            console.log('MEMber sku',this.bodewellOrderItems[i].Product2.StockKeepingUnit);
            if (this.bodewellOrderItems[i].Product2.StockKeepingUnit == MEMBER_SKU) {
                console.log("Found Membership SKU");
                this._memberList.push(this.bodewellOrderItems[i]);
            }
         }
    }
    if (this._memberList) {
        if (this._memberList.length > 0) {
            this._memberSKU = true;
        } else this._memberSKU = false;
    }
}

  @wire(getOrderDeliveryPaymentSummary, { orderSummaryId: '$rid'})
  BodewellPaymentSummary({data , err}) {
      console.log(' PaymentSummary Orders',data);
       if (data) {
       this.orderPaymentDetails=data;
       console.log('this.orderPaymentDetails');
      }
     if (err) {
         console.log(err)
      }
 }
}