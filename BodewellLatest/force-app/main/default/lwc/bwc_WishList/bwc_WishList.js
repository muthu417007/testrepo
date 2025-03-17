import { LightningElement ,wire,api} from 'lwc';
import getWishListItem from '@salesforce/apex/BWC_CustomWishList.getWishlistItems';
import addToCart from "@salesforce/apex/BWC_GetInfo.addToCart";
import communityId from "@salesforce/community/Id";
import getAccount from '@salesforce/apex/BWC_WaterFilterVariationController.getAccount';
import USER_ID from '@salesforce/user/Id';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import removeFromWishList from "@salesforce/apex/BWC_CustomWishList.removeItemFromWishlist";
import { NavigationMixin, } from 'lightning/navigation';
import ToastContainer from "lightning/toastContainer";



export default class Bwc_WishList extends NavigationMixin (LightningElement) {
  wishList;
  wishListItems;
loggedInUserAccountId;
_wishList;

isLoading = true;
isEmpty=false;

   @wire(getAccount,{userId: USER_ID })
    AccountDetails({data})
    {
        if(data){
         this.loggedInUserAccountId =data;
         console.log('loggedInUserAccountId',this.loggedInUserAccountId);
        }
    } 

 
    connectedCallback() {
      this.getWishListItems();
      const toastContainer = ToastContainer.instance();
      toastContainer.maxShown = 5;
      toastContainer.toastPosition = "top-center";
      
    }
    

    getWishListItems(){
      getWishListItem().then(result => {
      this.wishListItems = result;
      console.log('Wish List Items',this.wishListItems);
      if(this.wishListItems.length == 0){
        this.isEmpty = true;
        console.log('wish list length ' ,this.isEmpty);
      }
      this.isLoading = false;
      })

    }
addToCart(event) {
        console.log("Inside event");
        const ProductId = event?.target?.dataset?.productid;
        console.log('key-->',ProductId);
       
      addToCart({
          communityId: communityId,
          productId: ProductId,
         quantity:'1',
          effectiveAccountId: this.loggedInUserAccountId,
         deliverySku:[],
          installationSku:[],
          mcodeSku:[],
          zipCode:''

        })
          .then(result => {
         
           console.log("result-->"+ result.isAddedToCart);
            if (result.isAddedToCart === false) {
              this.dispatchEvent(
                new ShowToastEvent({
                  title: "Error",
                  message: result.errorMessage,
                  variant: "error",
                  mode: "dismissable"
                })
              );
            }
            else {
              this.dispatchEvent(
                new CustomEvent("cartchanged", {
                  bubbles: true,
                  composed: true
                })
              );
    
              this.dispatchEvent(
                new ShowToastEvent({
                  title: "Success",
                  message: "Your cart has been updated.",
                  variant: "success",
                  mode: "dismissable"
                })
              );
            }
          })
        
          .catch(error => {
            console.log("error apex class-->", error);
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Error",
                message: "This product has a maximum purchase limit. Check quantity limits",
                variant: "error",
                mode: "dismissable"
              })
            );
          }) 
        
      }

    

      handleRemove(event){
        console.log("Inside Remove event");
        const wishListItemId = event?.target?.dataset?.id;
     //  const wishListItemId = event.currentTarget.getAttribute('Key');
        console.log('key in remove-->',wishListItemId);
        this.wishList = this.wishListItems.filter(item => item.id=wishListItemId)[0].WishlistId;
        console.log('this.wishList line 211 = ' ,this.wishList);

        removeFromWishList({
          communityId: communityId,
          effectiveAccountId: this.loggedInUserAccountId,
          wishListId:this.wishList,
          wishlistItemId:wishListItemId
          
        }).then(result => {
          console.log("result-->" ,"Item removed from wishlist" );
          //refreshApex(this.wishListItems);
          //location.reload();
          this.getWishListItems();
          console.log('refreshApex called');     
        })

      }

      navigateToProductDetail(event){
        console.log("Inside navigate to product detail page");
        const ProductId = event?.target?.dataset?.productid;
        console.log('key-->',ProductId);
        this[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: {
              objectApiName: 'Product2',
              recordId: ProductId,
              actionName: 'view'
          }
        });

      }

  /* @wire(ProductAdapter)
    ProductAdapter({ error, data }) {
        if (data) {
            console.log('Product Adapter-->', data);
           
        }
    } */

     /* @wire(getWishList)
    WishListItems({data , err}) {
        console.log(' Wish List Items',data);
         if (data) {
         this.wishListItems=data;
         this.isLoading = false;
         if(this.wishListItems.length == 0){
          console.log('wish list length ' ,this.wishListItems.length);
          this.isEmpty =true;
         }
         refreshApex(this.wishListItems);
         console.log('refreshApex called');     
        }
       if (err) {
           console.log(err)
        }
    } */

 
   
   /* getPrice(){
    
      if(this.wishListItems){
        for(let i=0; i < this.wishListItems.length; i++){
          
          this.productIds = this.wishListItems[i].Product2.Id;
          this.productPrices.push(this.productIds);
          this.getAccountData();
          getProductPrice({ 
            communityId: communityId,
            productId: this.productIds,
            effectiveAccountId:this.loggedInUserAccountId
          }).then(result =>{
            console.log('result',result);
            this.unitPrice = result;
            console.log('this.unitPrice', this.unitPrice);
           // console.log('get Product Price',communityId);
            //console.log('productId -->',this.productIds);
           // console.log('effectiveAccountId',effectiveAccountId);
          if(this.unitPrice.unitPrice){
           // console.log("inside for loop",this.unitPrice[i]);
          // this.productPrices = this.unitPrice.unitPrice;
        //  objInstance['unitPrice']=this.unitPrice.unitPrice;
        //  this.productPrices.push(objInstance);
           this.productPrices.push(this.unitPrice.unitPrice);
            console.log('this.productPrices',this.productPrices);
           }
           
            console.log('this.productPrices',this.productPrices);
          })
   }
      }
    } */
    
  
}