import { LightningElement,wire } from 'lwc';
import memberChannel from '@salesforce/messageChannel/bwc_membership__c';
import { subscribe, MessageContext } from 'lightning/messageService';
import { CartSummaryAdapter } from 'commerce/cartApi';
import { SessionContextAdapter } from 'commerce/contextApi';
import changeMembershipAfterPreservation from '@salesforce/apex/BWC_PAController.changeMembershipAfterPreservation';

export default class Bwc_membershipAfterGuestPreservation extends LightningElement {
    subscription = null;
    _cartId;
    _effectiveAccountId;
    _userId;
    _isLoggedIn;
    @wire(MessageContext)
    messageContext;
    connectedCallback()
    {
        this.handleSubscribe();
    }
    @wire(SessionContextAdapter)
    wireSessionContext({ data }) {
        if (data) {
            console.log(`Bwc_membershipAfterGuestPreservation::wireSessionContext::data = ${JSON.stringify(data, null, 2)}`);
            this._effectiveAccountId = data.effectiveAccountId || '';
            this._isLoggedIn = data.isLoggedIn;
            this._userId = data.userId;
        }
    }
    @wire(CartSummaryAdapter)
    wireCartSummary({ data }) {
        if (data) {
            console.log(`Bwc_membershipAfterGuestPreservation::wireCartSummary::data = ${JSON.stringify(data, null, 2)}`);
            this._cartId = data.cartId;
        }
    }
    messageData;
  handleSubscribe() {
    if (this.subscription) {
      return;
    }
    this.subscription = subscribe(this.messageContext, memberChannel, (message) => {
      console.log('date------' + message.message);
      this.messageData=message.message;
if(this.messageData==='true')
{
    console.log('date------changeMembership') ;
  
    this.changeMembership();

}

    });
  }

  async changeMembership()
  {
    console.log('date------changeMembership Actual') ;
    await new Promise((resolve) => setTimeout(resolve, 5000));
   await  changeMembershipAfterPreservation({effectiveAccountId:this._effectiveAccountId,cartId:this._cartId,userId:this._userId})
    .then(result=>
        {
            console.log('Bwc_membershipAfterGuestPreservation::changeMembershipAfterPreservation::data = '+JSON.stringify(result));
  location.reload();
        })
        .catch(error=>
            {
                console.log('Bwc_membershipAfterGuestPreservation::changeMembershipAfterPreservation::data ='+ JSON.stringify(error));

            })
  }

}