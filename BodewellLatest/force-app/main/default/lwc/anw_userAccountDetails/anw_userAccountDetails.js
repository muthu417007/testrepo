import { LightningElement,api,wire,track } from 'lwc';
import getASMUserRecord from '@salesforce/apex/GetASMRecord.getAccountAndContactData';
import uid from '@salesforce/user/Id';

export default class Anw_userAccountDetails extends LightningElement {

    userId=uid;
    udata;
    hasuserdata=false;
    accountData;
    contactData;

    connectedCallback(){

        getASMUserRecord({userId: this.userId})
        .then((response)=> {
            this.udata=JSON.parse(response);
            console.log('contact name :-'+this.udata.contactName);
            console.log('contact phone :-'+this.udata.contactPhone);
            console.log('contact email :-'+this.udata.contactEmail);
            console.log('account name :-'+this.udata.accountName);
            //console.log('account dealer status :-'+this.udata.accountDealerStatus);
            this.hasuserdata=true;
        })
        .catch((error)=> {
            console.log('error ');
        });
    }
    
    
}