import { LightningElement ,wire,track,api} from 'lwc';
import bannerImageResource from '@salesforce/resourceUrl/BannerImage';
import PRODUCTIDMEMBER from "@salesforce/label/c.BWC_Product_Id_For_Member";
import getBodewellOrdersItems from '@salesforce/apex/BWC_OrderConfirmationController.getBodewellOrdersItems';
import { CurrentPageReference } from 'lightning/navigation';
import updatePAMembershipDetails from '@salesforce/apex/BWC_PAController.updatePAMembershipDetails';
   /**
 * @description A component used to show membership banner on order page
 */
export default class Bwc_orederConfirmationMembershipBanner extends LightningElement {
    bannerImage = bannerImageResource;
   @track isMemberPresent;
    bodewellOrderListItems;
  /**
      * Gets the effective account - if any - of the user viewing the product.
      *
      * @type {string}
      */
  @api
  get effectiveAccountId() {
    return this._effectiveAccountId;
  }
 /**
     * Sets the effective account - if any - of the user viewing the product
     * and fetches updated cart information
     */
 set effectiveAccountId(newId) {
    this._effectiveAccountId = newId;

  }

   @track  rid;
    @wire(CurrentPageReference)
       getStateParameters(currentPageReference) {
           if (currentPageReference) {
               if(currentPageReference.state.recordid)
               {
                  
   
                   this.rid = currentPageReference.state.recordid;
               }
               if(currentPageReference.state.orderNumber)
               {
                 
                   this.rid = currentPageReference.state.orderNumber; 
               }
               
       
               console.log('this.rid order summary banner ',this.rid );
               
           }
       }


    @wire(getBodewellOrdersItems, { Id: '$rid' })
    BodewellOrderListItems({ data, err }) {
        console.log(' banner id',this.rid);
        //this.isLoading = true;
        if (data) {
            this.bodewellOrderListItems = data;
            this.filterCartItems();
            console.log(' banner this.bodewellOrders in get order list items ', this.bodewellOrderListItems);
        }
        else
         {
            this.rid=this.rid+' ';
            console.log('banner order error==='+JSON.stringify(err));
        }
    }
    filterCartItems() {

        console.log('this.bodewellOrderListItems->', JSON.stringify(this.bodewellOrderListItems));
        this.bodewellOrderListItems = this.bodewellOrderListItems.map((item) => {
            console.log("Item Order" + JSON.stringify(item));
            if (item.Product2.Id === PRODUCTIDMEMBER) {
                this.isMemberPresent = true;
                this.updatePADetails();
            }


        })

    }
      /**
    * Gets the normalized effective account of the user.
    *
    * @type {string}
    * @readonly
    * @private
    */
  get resolvedEffectiveAccountId() {
    const effectiveAccountId = this._effectiveAccountId || "";
    let resolved = null;

    if (
      effectiveAccountId.length > 0 &&
      effectiveAccountId !== "000000000000000"
    ) {
      resolved = effectiveAccountId;
    }
    return resolved;
  }
    updatePADetails()
    {
      updatePAMembershipDetails({accId:this._effectiveAccountId})
      .then(result=>{
        console.log("result Join Member-->", JSON.stringify(result));
       // location.reload();
      })
      .catch(error=>
        {
          console.log("error Join Now-->", JSON.stringify(error));
        })
    }
}