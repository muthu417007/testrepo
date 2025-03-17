import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { RefreshEvent } from 'lightning/refresh';
import basePath from "@salesforce/community/basePath";
import { SessionContextAdapter } from 'commerce/contextApi';
// Guest flag
import IsGuest from '@salesforce/user/isGuest';
// User ID
import USER_ID from '@salesforce/user/Id';
// Apex methods
import getUserDetails from '@salesforce/apex/MYA_UserDetailsController.getUserDetails';
import getContactDetails from '@salesforce/apex/MYA_UserDetailsController.getContactDetails';
// Message Channel
import { subscribe, MessageContext, createMessageContext } from "lightning/messageService";
import userInformations from '@salesforce/messageChannel/User_Informations__c';

export default class Bwc_userProfileMenu extends NavigationMixin(LightningElement) {
    
    @track _handler;
    isLoggedIn = false;
    userId = USER_ID;
    userName;
    menuEnabled = false;
    isGuest = IsGuest;
    subscription; 
    context;

    @wire(MessageContext)
    messageContext;

    get logoutLink() {
        const sitePrefix = basePath.replace(/\/s$/i, ""); // site prefix is the site base path without the trailing "/s"
        return sitePrefix + "/secur/logout.jsp";
    }
    
    // _sessionContext;
    // @wire(SessionContextAdapter)
    // wireSessionContext({ data, error }) {
    //     if (data) {
    //         this._sessionContext = data;
    //         this.userName = data.userName;
    //         if(!this.isLoggedIn) {
    //             this.isLoggedIn = data.isLoggedIn;
    //         }
    //         console.log(`wireSessionContext:: = ${JSON.stringify(this._sessionContext)}`);
    //     } else if (error) {
    //         console.log(`wireSessionContext::error = ${JSON.stringify(error, null, 2)}`);
    //     }
    // }
 
  /*  @wire(getUserDetails, { UserId: USER_ID })
    userDetails(result) {
        this.wireResult = result;
        if (result.data) {
            this.currentUser = result.data[0];
            this.userName = this.currentUser.FirstName;
            if(!this.isLoggedIn) {
                this.isLoggedIn = true;
            }
        } else if (result.error) {
            this.error = error;
            console.error('getRecord -> else if error response :', error);
        }
    } */

    connectedCallback() {
        if(!this.isGuest) {
            this.getLoggedInUserDetails();
        }
        window.addEventListener('click', (e) => {        
            if (this.menuEnabled) {
                let dropdown = this.template.querySelector('.dropdown-content');
                dropdown.classList.add('show');
                this.menuEnabled = false;
            } else {                
                let dropdown = this.template.querySelector('.dropdown-content');
                dropdown.classList.remove('show');
            }
        });                
        this.handleSubscribe();
    }

    handleSubscribe() {
        if (this.subscription) {
            return;
        }
        this.context = createMessageContext();

        this.subscription = subscribe(this.context, userInformations, (message) => {
            const userInfo = message.message;
            console.log('userInfo =',userInfo);
            this.userName = userInfo;
        });
    }

    getLoggedInUserDetails() {
        getUserDetails( { UserId: USER_ID })
            .then(result => {
                this.currentUser = result[0];
                this.getUserContactDetails(this.currentUser.ContactId);
            })
            .catch(error => {
                this.error = error;
                console.error('getUserDetails -> error response :', error);
            });
    }

    getUserContactDetails(conId) {
        getContactDetails({ ContactId: conId })
            .then(result => {
                this.contact = result[0];
                this.userName = this.contact.FirstName;
                if(!this.isLoggedIn) {
                    this.isLoggedIn = true;
                }
            })
            .catch(error => {
                this.error = error;
                console.error('getContactDetails -> error response :', error);
            });
    }

    /*handleGoToLogin() {
        const sitePrefix = basePath.replace(/\/s$/i, ""); // site prefix is the site base path without the trailing "/s"
        
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                name: 'Login'
            }
        });
    }*/

    handleGoToMYA() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'MYA_My_Products__c'
            }
        });
    }

      handleGoToOrders() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'MYA_My_Orders__c'
            }
        });
    }

      handleGoToAddressBook() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'MYA_Account_Details__c'
            }
        });
    }

      handleGoTosubscriptions() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'MYA_My_subscriptions__c'
            }
        });
    }
      handleGoToRepairServices() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'MYA_Repair_Services__c'
            }
        });
    }

    handleGoToWishlist() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'MYA_My_WishLists__c'
            }
        });
    }

    handleDropdownClick() {
        this.menuEnabled = true;
    }

    handleGoToLogin() {
    let loginURL = basePath.replace(/\/s$/i, "") + "/login/?language=en_US&startURL=/bodewellCommerce/mya-my-products";
    console.log('loginURL: ===>> '+loginURL);
    this[NavigationMixin.Navigate](
        {
          type: "standard__webPage",
          attributes: {
            url: loginURL,
          },
        },
        true, // Replaces the current page in your browser history with the URL
      );
    }
}