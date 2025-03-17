import { LightningElement, track, api, wire } from 'lwc';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import uid from '@salesforce/user/Id';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import LASTNAME from '@salesforce/schema/User.LastName';
import FIRSTNAME from '@salesforce/schema/User.FirstName';
import PROFILE from '@salesforce/schema/User.Profile.Name';
import getASMUserRecord from '@salesforce/apex/GetASMRecord.getAccountAndContactData';
export default class Anw_userFlowInvocation extends LightningElement {
    userId=uid;
    udata;
    @track adminprofile=false;
    hasuserdata=false;
    accountData;
    contactData;
    firstName;
    lastName;
    @track dealerregpageurl='/s/dealer-registration'; 
    @track adduserurl='/s/manage-user-profile-anw';  
    @track resetpasswordurl='/s/login/ForgotPassword?language=en_US'; 
    @track distributor=false;
    flowApiName = "Create_Air_and_Water_User";
    isFlowLaunched=false;
    @api recordId;
    error;
    handleAddUser(){
        this.isFlowLaunched=true;
    }
    @wire(getRecord, { recordId: '$userId', fields: [PROFILE,LASTNAME,FIRSTNAME] })
    wiredUser({error,data}) {
        if(error){
            this.error=error;
        }
        else if(data){
            this.firstName=data.fields.FirstName.value;
            this.lastName=data.fields.LastName.value;
            console.log('BUtton displayed profile name '+data.fields.LastName.value+data.fields.Profile.value.fields.Name.value);
            if(data.fields.Profile.value.fields.Name.value=='Air and Water Distributor' || data.fields.Profile.value.fields.Name.value=='Air and Water Distributor Admin')
                this.distributor=true;
            if(data.fields.Profile.value.fields.Name.value=='Air and Water Dealer Admin' || data.fields.Profile.value.fields.Name.value=='Air and Water Distributor Admin' ||  data.fields.Profile.value.fields.Name.value=='Air and Water Plumber Admin')
                this.adminprofile=true;
        }
    }
    connectedCallback(){

        getASMUserRecord({userId: this.userId})
        .then((response)=> {
            this.udata=JSON.parse(response);
            console.log('contact name :-'+this.udata.contactName);
            console.log('contact phone :-'+this.udata.contactPhone);
            console.log('contact email :-'+this.udata.contactEmail);
            console.log('account name :-'+this.udata.accountName);
            console.log('account dealer status :-'+this.udata.accountDealerStatus);
            this.hasuserdata=true;
        })
        .catch((error)=> {
            console.log('error ');
        });
    }
    /*@wire(getASMUserRecord, { userId: '$userId' })
    wiredUserDetails({error,data}) {
        if(error){
            this.error=error;
            console.log('error while getting account andcontact');
        }
        else if(data){
            this.udata=JSON.parse(data);
            console.log('data is '+this.udata.contactEmail+this.udata.contactName);
            this.hasuserdata=true;
        }
    }*/
    

    
    
    get inputVariables() {
        return [
            {
                name: 'User',
                type: 'SObject',
                value: this.userRecord.data
                
            }
        ];
    }
    handleFlowStatusChange(event) {
		console.log("flow status", event.detail.status);
        this.isFlowLaunched=false;
		if (event.detail.status === "FINISHED") {
			this.dispatchEvent(
				new ShowToastEvent({
					title: "Success",
					message: "Flow Finished Successfully",
					variant: "success",
				})
			);
		}
	}

}