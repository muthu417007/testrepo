import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import deactivate from '@salesforce/apex/MYA_DeleteAccountHandler.deactivate';
import getLogoutUrl from '@salesforce/apex/applauncher.IdentityHeaderController.getLogoutUrl';
import basePath from "@salesforce/community/basePath";

import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class DeleteAccount extends NavigationMixin(LightningElement) {

    @api recordId;
    @api success;
    @api errorMessage;
    @track callModel = false;
    @track isLoading = false;
    @track confirmation;
    pageReference;

    handleClick() { 
        this.callModel = true;
    }

    closeModal() {
        this.callModel = false;
    }

    submitDetails() {
        this.isLoading = true;
        deactivate({})
            .then(result => {                
                this.callModel = false;
                this.isLoading = false;
                console.log('result',result.data);
              console.log('result',result.Success);
                if (result.Success) {
                    // Show success messsage
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success!!',
                        message: 'Account Deleted Successfully!!',
                        variant: 'success'
                    }));
                if(basePath.includes('bodewellCommerce'))
                {
                    console.log('inside bodewell commerce');
                    this.bodewellLogout();
                }
                else{
                    this.logout();
                }
                } else {
                    // Show success messsage
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: 'Account Deletion failed.',
                        variant: 'error',
                        mode: 'dismissable'
                    }));
                    console.error('Apex error: ',result);
                }
            })
            .catch(error => {
                this.error = error.message;
                console.error('JS error: ',result);
            });
    }

    async bodewellLogout() {            
        // Login page (or could navigate to some other URL)
        console.log('basePath before : ===>>'+basePath);
      let loginURL = basePath.replace(/\/s$/i, "") + "/login/?language=en_US&startURL=/bodewellCommerce/mya-my-products";
          console.log('loginURL: After ===>>'+loginURL);
        console.log('NavigationMixin.Navigate',NavigationMixin.Navigate);
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: { url: loginURL }
        });
        // Logout
        const logoutUrl = await getLogoutUrl();
        console.log('logoutUrl test',logoutUrl);
        await fetch(logoutUrl);
    }

    async logout() {
        this[NavigationMixin.Navigate]({
            type: 'comm__loginPage',
            attributes: { actionName: 'login'}
        });
        const logoutUrl = await getLogoutUrl();
        console.log('logoutUrl test',logoutUrl);
        await fetch(logoutUrl);
    }

}