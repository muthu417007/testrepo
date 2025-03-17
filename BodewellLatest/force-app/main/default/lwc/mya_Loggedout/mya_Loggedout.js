import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// Guest flag
import IsGuest from '@salesforce/user/isGuest'; //Srini- Added to check whther logged-in user is guest or not
import USER_ID from '@salesforce/user/Id';
import GEA from "./mya_Loggedout_GEA.html";
import Cafe from "./mya_Loggedout_Cafe.html";
import Haier from "./mya_Loggedout_Haier.html";
import getSiteConfiguration from '@salesforce/apex/PS_GEAIdPCustomerConfigHelper.getSiteConfiguration';
import getEnvironmentConfiguration from '@salesforce/apex/PS_GEAIdPEnvironmentConfigHelper.getEnvironmentConfiguration';
import getUserDetails from '@salesforce/apex/MYA_UserDetailsController.getUserDetails';


export default class Mya_Loggedout extends NavigationMixin(LightningElement) {

    @api brand = "GEA";
    pageReference;
    href;
    isLoading = true;
    // Guest flag
    isGuest = IsGuest;

    render() {
        if (this.brand == "GEA") {
            return GEA;
        } else if (this.brand == "Haier") {
            return Haier;
        } else if (this.brand == "Cafe") {
            return Cafe;
        }
    }

    async connectedCallback() {
        if (!this.isGuest) {
            this.logOutCurrentUser();
        }
        else {
            this.setLoginLink();
        }
    }

    logOutCurrentUser() {
        getUserDetails({ UserId: USER_ID })
            .then(result => {
                console.log('result[0]',result[0]);
                let sessionId = result[0].Customer_IdP_Session_Id__c;
                console.log('sessionId',sessionId);
                if(sessionId) {
                    fetch('/GEA/services/apexrest/customer-idm/user/v1/session/' + sessionId, {
                        method: 'DELETE'
                    })
                    .then((result) => {
                        if(result){
                            if(result.ok) {
                                console.log('User logged out.');                                 
                                location.reload();
                            } else {
                                console.log('Response status:', result.status); 
                                console.log('Response statusText:', result.statusText); 
                                this.errorToast('Logout request failed.');
                            }
                        } else {
                            this.errorToast('Logout request failed.');
                        }
                    })
                    .catch((error) => {
                        console.error('Error:', error);
                        location.reload();
                    });
                } else {
                    this.errorToast('Session not found.');
                }
            })
            .catch(error => {
                this.error = error;
                console.error('getContactDetails -> error response :', error);
                this.isLoading = false;
            });
    }

    setLoginLink() {
        this.pageReference = {
            type: 'standard__webPage',
            attributes: {
                url: basePath + '/login'
            }
        };

        this[NavigationMixin.GenerateUrl](this.pageReference)
            .then(url => {
                this.href = url;
                this.isLoading = false;
            });
    }

    errorToast(message) {
        const event = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}