import { LightningElement, wire } from 'lwc';
import { CartSummaryAdapter } from 'commerce/cartApi';
import { SessionContextAdapter } from 'commerce/contextApi';
import SITE_ID from '@salesforce/site/Id';
import updateGuestCart from '@salesforce/apex/BWC_GuestCartController.updateGuestCart';
import preserveGuestCart from '@salesforce/apex/BWC_GuestCartController.preserveGuestCart';

//Shubhada Changes
import memberChannel from '@salesforce/messageChannel/bwc_membership__c';
import { publish, MessageContext } from 'lightning/messageService';
import COMMUNITY_ID from '@salesforce/community/Id';

/**
 * @description This is a "ghost" component that does not render a UI but will detect if a guest cart exists and
 * will "preserve" the guest after the user logs into the site.
 *
 * If a guest cart exists then the component will update the WebCart with the GUID from
 * the Experience Cloud "guest_uuid_essential_[15-char SiteID]" cookie.  It will update the BWC_GuestUID__c field
 * of the WebCart.  This is done via the Apex method "updateGuestCart".
 *
 * If the user is logged in and the component detects that a guest cart exists then the component will invoke
 * the "preserveGuestCart" Apex method. Inside that method the guest cart is cloned to make a new primary cart for the user
 * and the guest cart will have its status changed to "PendingDelete".
 *
 * If there was a pre-existing cart for the user when they logged in then the pre-existing cart is updated
 * to have its "IsSecondary" field set to true.
 *
 * This component should be placed on the 2 Experience Builder pages
 * - Login Page
 * - Home page (or whichever page the user is redirected to after login)
 */
export default class bwc_guestCartListener extends LightningElement {
    _effectiveAccountId;
    _isLoggedIn;
    _userId;

    @wire(MessageContext)
    messageContext;

    @wire(SessionContextAdapter)
    wireSessionContext({ data }) {
        if (data) {
            console.log(`bwc_guestCartListener::wireSessionContext::data = ${JSON.stringify(data, null, 2)}`);
            this._effectiveAccountId = data.effectiveAccountId || '';
            this._isLoggedIn = data.isLoggedIn;
            this._userId = data.userId;
        }
    }

    _guestUUID = this.getGuestCartCookie();
    _cartId;

    @wire(CartSummaryAdapter)
    wireCartSummary({ data }) {
        if (data) {
            console.log(`bwc_guestCartListener::wireCartSummary::data = ${JSON.stringify(data, null, 2)}`);
            this._cartId = data.cartId;
        }

        // If the user is not logged in but there is a cart then the component will update the cart with the GUID from
        // the Experience Cloud "guest_uuid_essential_[15-char SiteID]" cookie otherwise it will clone the guest cart and
        // make the guest cart the primary cart.
        if (!this._isLoggedIn) {
            if (this._cartId) {
                if (!sessionStorage.getItem('GuestCart::GuestCartUpdated')) {
                    this.updateGuestCart();
                    sessionStorage.setItem('GuestCart::GuestCartUpdated', 'true');
                }
            }
        } else {
            if (sessionStorage.getItem('GuestCart::GuestCartUpdated')) {
                this.preserveGuestCart();
                sessionStorage.removeItem('GuestCart::GuestCartUpdated');
            }
        }
    }

    /**
     * @description Gets the GUID from the Experience Cloud "guest_uuid_essential_[15-char SiteID]" cookie
     * @private
     * @returns {String} the GUID from the Experience Cloud "guest_uuid_essential_[15-char SiteID]" cookie
     */
    getGuestCartCookie() {
        let siteId = SITE_ID.slice(0, SITE_ID.length - 3);
        name = 'guest_uuid_essential_' + siteId;
        return document.cookie.split('; ').find(row => row.startsWith(`${name}=`))?.split('=')[1];
    }

    /**
     * @description Updates the WebCart with the GUID from the Experience Cloud "guest_uuid_essential_[15-char SiteID]" cookie
     * @returns void
     */
    async updateGuestCart() {
        await updateGuestCart({cartId: this._cartId, guestUUID: this._guestUUID})
        .then(() => {
            console.log(`bwc_guestCartListener::wireCartSummary::updateGuestCart called!::cartId = ${this._cartId}::guestUUID = ${this._guestUUID}`);
        })
        .catch(error => {
            console.log(`bwc_guestCartListener::wireCartSummary::updateGuestCart returned error!::error = ${JSON.stringify(error, null, 2)}::cartId = ${this._cartId}::guestUUID = ${this._guestUUID}`);
        });
    }

    /**
     * @description Clones the WebCart with the GUID from the Experience Cloud "guest_uuid_essential_[15-char SiteID]" cookie
     * @returns void
     */
    async preserveGuestCart() {
        await preserveGuestCart({effectiveAccountId: this._effectiveAccountId, ownerId: this._userId, guestUUID: this._guestUUID,communityId:COMMUNITY_ID})
        .then(() => {
            console.log(`bwc_guestCartListener::wireCartSummary::preserveGuestCart called!::cartId = ${this._cartId}::guestUUID = ${this._guestUUID}::effectiveAccountId = ${this._effectiveAccountId}::userId = ${this._userId}::COMMUNITY_ID=${COMMUNITY_ID}`);
         //Shubhada Changes 
         this.sendNotificationToMemberGhost();
        })
        .catch(error => {
            console.log(`bwc_guestCartListener::wireCartSummary::updateGuestCart returned error!::error = ${JSON.stringify(error, null, 2)}::cartId = ${this._cartId}::guestUUID = ${this._guestUUID}::effectiveAccountId = ${this._effectiveAccountId}::userId = ${this._userId}`);
        });
    }

       //Shubhada Changes 
       sendNotificationToMemberGhost()
       {
               console.log(`bwc_guestCartListener:: membership lwc called`);
               let message = { message: 'true' };
               publish(this.messageContext, memberChannel, message);
   
       }
}