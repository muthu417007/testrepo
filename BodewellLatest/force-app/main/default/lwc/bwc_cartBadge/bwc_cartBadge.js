import { LightningElement, wire, api } from 'lwc';
import { CartSummaryAdapter } from 'commerce/cartApi';
import { NavigationMixin } from 'lightning/navigation';
import { COUNT_ITEM_PRODUCT_CART, ITEM_PRODUCT_CART_VALUE_THRESHOLD } from './bwc_cartBadgeConstants';
//Shubhada Changes
//import { navigate, NavigationContext } from 'lightning/navigation';

export default class Bwc_cartBadge extends NavigationMixin(LightningElement) {
    @api cartItems;

    _displayCartCountBadge;
       get displayCartCountBadge() {
        return this._displayCartCountBadge;
    }

    set displayCartCountBadge(value) {
        this._displayCartCountBadge = value;
    }
    
    @wire(CartSummaryAdapter)
    getCartProductList({data, error}) {
        if(data){
            console.log("cartBadge Data", JSON.stringify(data));
            //this.displayCartCountBadge = this.cartItems == COUNT_ITEM_PRODUCT_CART ? Number(data.totalProductCount).toFixed(0) : Number(data.uniqueProductCount).toFixed(0);
            this.displayCartCountBadge =  Number(data.totalProductCount).toFixed(0);

        }
        console.log(" this.displayCartCountBadge", this.displayCartCountBadge);
        if(this.displayCartCountBadge == 0) {
            this.displayCartCountBadge = false;
          
        }
        if(this.displayCartCountBadge > 999) {
            this.displayCartCountBadge = ITEM_PRODUCT_CART_VALUE_THRESHOLD;
        }
    }
    
    handleCartIconClick() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Current_Cart'
            }
        });
        // setTimeout(() => {
        //     window.location.reload();
        // }, 2000);
    }
/**
     * Navigates to the cart page on button click.
     */

//     event.preventDefault();
//     navigate(this._navigationContext, {
//         type: 'comm__namedPage',
//         attributes: {
//             name: 'Current_Cart',
//         },
//     });

// location.reload();
//     }

//     handleCartIconClick() {
//     navigate(this._navigationContext, {
//         type: 'standard__webPage',
//             attributes: {
//                 url: '/cart'
//             }
//     });
// }
}