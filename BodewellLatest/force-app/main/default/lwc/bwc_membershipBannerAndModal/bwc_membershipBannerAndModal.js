/**
 * @description Banner and banner modal  on cart page 
 */
import { LightningElement, api, wire, track } from 'lwc';
import MemberBannerHeader from "@salesforce/label/c.BWC_Membership_Banner_Header";
import MemberBannerSubtitle from "@salesforce/label/c.BWC_Membership_Banner_Subtitle";
import MemberBannerOfferTitle from "@salesforce/label/c.BWC_Membership_Banner_Offer_Title";
import MemberBannerOffers from "@salesforce/label/c.BWC_Membership_Banner_Offers";
import addToCart from "@salesforce/apex/BWC_GetInfo.addToCart";
import updatePAMembershipDetails from '@salesforce/apex/BWC_PAController.updatePAMembershipDetails';
import COMMUNITY_ID from '@salesforce/community/Id';
import USER_ID from '@salesforce/user/Id';
import PRODUCTIDMEMBER from "@salesforce/label/c.BWC_Product_Id_For_Member";
import UNITPRICE from "@salesforce/label/c.BWC_Bodewell_Membership_Unit_price";
import { SessionContextAdapter } from 'commerce/contextApi';
import { NavigationMixin } from 'lightning/navigation';
import bwc_membershipPopUp from '@salesforce/messageChannel/bwc_membershipPopUp__c';
import bwc_membershipSavings from '@salesforce/messageChannel/bwc_membershipSavings__c';
import { MessageContext, subscribe, unsubscribe } from 'lightning/messageService';
import { CurrentPageReference } from 'lightning/navigation';
import PDP_URL from '@salesforce/label/c.BWC_PDPPage';


export default class Bwc_membershipBannerAndModal extends NavigationMixin(LightningElement) {

  @track isPDPPage = false;
  @track isAnotherPage=true
  @track openModal=false;
  currencyCode='USD';

  afterJoinNow = false;
  joinNowLabel='SIGN IN TO ADD MEMBERSHIP';
  @track memberSavings=0.0;
  @track subscription1=null;
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


 
    _isLoggedIn;
    _userId;

    @wire(MessageContext)
   messageContext;
   subscription;
   connectedCallback() {
    this.subscription = subscribe(this.messageContext, bwc_membershipPopUp, (message) => {
       if (message && message.bodewellMemberClick) {
          this.handleJoinNow();
       }
    });
    this.handleMemberSavings();

    const pdpPageURL = PDP_URL; 
    const currentURL = `'${window.location.pathname}'`;
   console.log("pdpPage", pdpPageURL,currentURL, this.pageObjectApiName);
            
    if (this.pageObjectApiName=='Product2') {
        this.isPDPPage = true;
        this.isAnotherPage =false;
    }
 }

 disconnectedCallback() {
  unsubscribe(this.subscription);
  unsubscribe(this.subscription1);
}

handleOpenModal() {
  this.openModal = true;
  this.handleJoinNow();
  //console.log("openModal in parent Banner, handleJoinNow");
}

handleMemberSavings(){
  if (this.subscription1) {
      return;
  }
  this.subscription1 = subscribe(
      this.messageContext,
      bwc_membershipSavings,
      (savings) => {
         // console.log("@@@memberSavings In banner" + JSON.stringify(savings.savings));
          this.memberSavings=savings.savings;
      });
}
    @wire(SessionContextAdapter)
    wireSessionContext({ data }) {
        if (data) {
            console.log(`bwc_guestCartListener::wireSessionContext::data = ${JSON.stringify(data, null, 2)}`);
         this._effectiveAccountId = data.effectiveAccountId || '';
            this._isLoggedIn = data.isLoggedIn;
            this._userId = data.userId;
            if(this._isLoggedIn==true)
            {
              this.joinNowLabel='JOIN NOW';
            }
            else{
              this.joinNowLabel='SIGN IN TO ADD MEMBERSHIP';
            }
        }
    }

  /**
      * @type {?Boolean}
      * Flag to open and close modal
      */
  joinNow = false;
  loading =false;
  /**
   * @type {?String}
   * Custom labels 
   */
  memberBannerHeader = MemberBannerHeader;
  memberBannerSubtitle = MemberBannerSubtitle;
  memberBannerOfferTitle = MemberBannerOfferTitle;
  memberBannerOffers = MemberBannerOffers.split("~");
  productId = PRODUCTIDMEMBER;
  //method to open banner modal

  handleJoinNow(event) {
    this.joinNow = true;
  }
  /**
    * @description Handles the 'addproducttocart' event.
    * Adds the product to the cart and then on success opens the add to cart modal.
    * @param {CustomEvent<{ productId: string; quantity: number }>} event The event object
    * @private
    */
  handleJoinNowMembership(event) {
    this.joinNow = false;
    console.log('join now IN');

    //wc_CreateCartItemMethod(String productId,String quantity,Decimal unitPrice)

    console.log('join now IN COMMUNITY_ID' + COMMUNITY_ID);
    console.log('join now IN product' + this.productId);
    console.log('join now IN account Id Resolve' + this.resolvedEffectiveAccountId);
    console.log('join now IN account Id ' + this._accountId);
    console.log("Inside event");
    addToCart({
      communityId: COMMUNITY_ID,
      productId: this.productId,
      quantity: '1',
      effectiveAccountId: this.resolvedEffectiveAccountId,
      deliverySku: [],
      installationSku: [],
      zipCode: ''
    })
      .then(result => {
        console.log("result-->", result);
        if(this._isLoggedIn==true)
            {
              
              this.afterJoinNow = true;
              this.loading = true;             
              this.updatePADetails();
              
            }
            else{
              this.afterJoinNow = false;
              // redirect to sign in page
              this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'Login',
                }
            });
            }
       
        // location.reload();

      })
      .catch(e => {
        console.log("error apex class-->", e);

      });


  }


  updatePADetails()
  {
    updatePAMembershipDetails({accId:this._effectiveAccountId})
    .then(result=>{
      console.log("result Join Member-->", JSON.stringify(result));
      location.reload();
      this.loading=false;
    })
    .catch(error=>
      {
        this.loading=false;
        console.log("error Join Now-->", JSON.stringify(error));
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

  /**
     * @description Navigates to the cart page when the primary button is clicked
     * from the modal after adding an item to the cart
     * @private
     */
  navigateToCart() {
    // eslint-disable-next-line no-unused-expressions
    this.navContext && navigate(this.navContext, {
      type: 'comm__namedPage',
      attributes: {
        name: 'Current_Cart',
      },
    });
  }
  //method to close banner modal
  cancelAndClose() {
    this.joinNow = false;
  }


  _cartId;
  @api
  get cartId() {
    return this._cartId;
  }
  set cartId(val) {
    this._cartId = val;
    console.log('_cartId====banner==' + JSON.stringify(val));
  }

  _accountId;
  @api
  get accountId() {
    return this._accountId;
  }
  set accountId(val) {
    this._accountId = val;
    console.log('_accountId banner==' + val);
  }

  _webstoreid;
  @api
  get webstoreid() {
    return this._webstoreid;
  }
  set webstoreid(val) {
    this._webstoreid = val;
    console.log('webstoreid==' + val);
  }

  cancelAndCloseSuccess() {
    this.afterJoinNow = false;
  }

@track pageAttributes;
@track pageObjectApiName;
@track bannerFlag=false;

  @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
       if (currentPageReference) {
         
          // this.recordId = currentPageReference.attributes.recordId || null;
          this.pageAttributes = currentPageReference.attributes.name;
          this.pageObjectApiName = currentPageReference.attributes.objectApiName;
          // let states = currentPageReference.state;
          // let type = currentPageReference.type;
          console.log('currentPageReference', JSON.stringify(currentPageReference),this.pageObjectApiName,this.pageAttributes);
          if(this.pageAttributes=='Current_Cart'){
                this.bannerFlag=true;
          }
          else
              this.bannerFlag=false;
            console.log("bannerFlag", this.bannerFlag);
       }
    }
}