import { LightningElement, wire, api } from 'lwc';
import getContactName from '@salesforce/apex/Mya_ProductDetails.MYA_GetContactName'
import isGuest from '@salesforce/user/isGuest'; //Srini- Added to check whther logged-in user is guest or not
import USER_ID from '@salesforce/user/Id';

export default class Mya_corePage extends LightningElement {

    @api brand = 'GEA';

    loggedIn = !isGuest;
    userId = USER_ID;
    globalId;
    connected = false;

    connectedCallback() {
        this.connected = true;
        let corePageEvent = new CustomEvent(
            "gtm__corePageEvent", {
            detail: {
                pageTitle: document.title,
                pageURL: window.location.href,
                loggedIn: this.loggedIn,
                pageType: undefined,
                userId: this.userId,
                zipCode: undefined,
                productType: undefined,
                storeType: undefined,
                storeId: undefined,
                storeName: undefined,
                bcPage: false
            }
        }
        );
        document.dispatchEvent(
            corePageEvent, {
            bubbles: true,
            composed: true
        }
        );

        if (this.brand == 'GEA' && this.loggedIn) {
            getContactName({ UserId: USER_ID })
                .then(result => {
                    if (result) {
                        this.globalId = result[0].Contact.Global_Customer_Id__c;
                        if (this.globalId) {
                            let interactionStudioEvent = new CustomEvent(
                                "interactionStudio_event", {
                                detail: {
                                    globalId: this.globalId
                                }
                            }
                            );
                            document.dispatchEvent(
                                interactionStudioEvent, {
                                bubbles: true,
                                composed: true
                            }
                            );
                        }
                    }
                })
                .catch(error => {
                    console.error(error);
                });
        }
    }
}