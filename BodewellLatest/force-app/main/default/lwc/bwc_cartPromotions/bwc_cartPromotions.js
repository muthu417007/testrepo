import { LightningElement, wire, track } from 'lwc';
import { publish, subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import bwc_CouponApplied from '@salesforce/messageChannel/bwc_CouponApplied__c';
import bwc_CouponError from '@salesforce/messageChannel/bwc_CouponError__c';
import { deleteCouponFromCart } from 'commerce/cartApi';

export default class Bwc_cartPromotions extends LightningElement {
    couponCode = '';
    errorMessage ='';
    successMessage='';
    @track couponId = '';
    subscription1;
    subscription2;
   
    @wire(MessageContext)
    messageContext;

    connectedCallback(){
        
        this.subscribeToSuccess();
        this.subscribeToError();
    }

    handleCouponCodeChange(event) {
        this.couponCode = event.target.value;
    }

    handleRemoval(){
        console.log("Clicked Remove Coupon");
    }

    publishCoupon(){
            let couponCode = {message: this.couponCode};
            publish(this.messageContext, bwc_CouponApplied, couponCode);
            console.log("messageFromPromotionComp" +JSON.stringify(couponCode.message));
        }


    subscribeToSuccess(){
        if (this.subscription1) {
            return;
        }
        this.subscription1 = 
        subscribe(this.messageContext, bwc_CouponError,(successMsg)=>
        {
            console.log("Success Message from Promotion Sub "+ JSON.stringify(successMsg.smsg));
             this.handleCouponSuccess(successMsg);
             this.couponId=successMsg.cartCouponId;
            //unsubscribe(this.subscription2);
        });
    }    

    handleCouponSuccess(successMsg)
    {
        this.successMessage=successMsg.smsg;
        console.log("successMsg from handleSucess"+this.successMessage);
        this.errorMessage = successMsg.emsg;
        console.log("errorMsg"+this.errorMessage);
       
    }

    subscribeToError(){
        if (this.subscription2) {
            return;
        }
        this.subscription2 = 
        subscribe(this.messageContext, bwc_CouponError,(errMsg)=>
        {
            console.log("Err Message from Promotion Sub "+ JSON.stringify(errMsg.emsg));
             this.handleCouponError(errMsg);
             this.couponId=errMsg.cartCouponId;
             //unsubscribe(this.subscription1);
        });
    }  
    handleCouponError(errMsg) 
    {
        this.errorMessage = errMsg.emsg;
        console.log("errMsg"+this.errorMessage);
        this.successMessage = errMsg.smsg;
        console.log("sucessMsg from handleError"+this.successMessage);
           
    }

    async deleteCoupon(){
        console.log("click on delete promotion comp");
        await deleteCouponFromCart(this.couponId);
    }

    disconnectedCallback() {
        unsubscribe(this.subscription1);
        unsubscribe(this.subscription2);
    }



          
}