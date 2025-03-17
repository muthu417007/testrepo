import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'; 
export default class Mya_ChangePasswordSuccess extends LightningElement {
    @api brand;
    url;
    connectedCallback(){
        //debugger;
        this.url=window.location.origin+'/'+this.brand+'/s/mya-account-details'
        const otherWindow = window.open(this.url,"_self");
        //otherWindow.opener = "_self";
        //otherWindow.location = window.location.origin+this.brand+'/s/MYA_Account_Details__c';

    }

    
}