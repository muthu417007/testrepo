import { LightningElement, wire, api,track } from 'lwc';
import getBodewellOrdersItems from '@salesforce/apex/BWC_OrderConfirmationController.getBodewellOrderSummaryItems';
import USER_ID from '@salesforce/user/Id';
export default class Bwc_myaMyOrderItems extends LightningElement {

     bodewellOrderListItems;
   @api number;
    bodewellOrderNumber;
 
     
    @wire(getBodewellOrdersItems, { orderRefNumber: '$number'})
    BodewellOrderListItems({data , err}) {
        console.log('tthis.bodewellOrders in get order list items',this.number);
       this.isLoading = true;
       if (data) {
         this.bodewellOrderListItems=data;
         console.log('tthis.bodewellOrders in get order list items ',this.bodewellOrderListItems);
         this.isLoading = false;
       } 
       if (err) {
           console.log(err)
           this.isLoading = false;
           //this.showNextButtonflag = false;
       }
   }

   
    handleOrderDetails(event) {

        var rid = event.target.value;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'MYA_Order_Details__c'
            },
            state: {
                recordid: rid
            }
        });
    }

}