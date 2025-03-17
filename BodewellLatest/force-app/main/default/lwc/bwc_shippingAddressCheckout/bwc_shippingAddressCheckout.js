import { LightningElement, wire, track, api } from 'lwc';
import User_Id from '@salesforce/user/Id';
import getShippingAddress from '@salesforce/apex/BWC_ShippingAndBillingAddressController.bwc_getShippingAddress';
import { getRecord } from 'lightning/uiRecordApi';
import UserNameFIELD from '@salesforce/schema/User.Name';
import UserFirstNameFIELD from '@salesforce/schema/User.FirstName';
import UserLastNameFIELD from '@salesforce/schema/User.LastName';
import UserAccountIdFIELD from '@salesforce/schema/User.AccountId';
//import { createContactPointAddress } from 'commerce/checkoutApi';

import { refreshApex } from '@salesforce/apex';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import { ShowToastEvent } from ‘lightning/platformShowToastEvent’;
import ContactPointAddress_OBJECT from '@salesforce/schema/ContactPointAddress';
import ContactPointAddress_NAME_FIELD from '@salesforce/schema/ContactPointAddress.Name';
import Account_OBJECT from '@salesforce/schema/Account';
import ContactPointAddress_ACCOUNT_Id_FIELD from '@salesforce/schema/ContactPointAddress.ParentId';
import ContactPointAddress_State_FIELD from '@salesforce/schema/ContactPointAddress.State';
import ContactPointAddress_City_FIELD from '@salesforce/schema/ContactPointAddress.City';
import ContactPointAddress_PostalCode_FIELD from '@salesforce/schema/ContactPointAddress.PostalCode';
import ContactPointAddress_Street_FIELD from '@salesforce/schema/ContactPointAddress.Street';
import ContactPointAddress_AddressType_FIELD from '@salesforce/schema/ContactPointAddress.AddressType';
import ContactPointAddress_IsDefault_FIELD from '@salesforce/schema/ContactPointAddress.IsDefault';

//import CONTACT_FIRST_NAME_FIELD from ‘@salesforce/schema/Contact.FirstName’;
//import CONTACT_LAST_NAME_FIELD from ‘@salesforce/schema/Contact.LastName’;

export default class Bwc_shippingAddressCheckout extends LightningElement {
    @track error;
    openEditAddress=false;
    @track userId = User_Id;
    @track currentUserName;
    @track currentUserFirstName;
    @track currentUserLastName;
    @track shippingAddressList;
    @track selectedAddress;
    @track addressOptions=[];
    @track finalShippingAddress;
    shipAdddressFlag=true;
    @track resultdata;
    _checkoutAddresses;
   @track accountId;
   @track isOneAddress = false;
    oneAddress;
    @track multipleAddress = false;
    @track noAddress=false;
     inputClass='slds-input';
    @api
    get checkoutAddresses() {
        return this._checkoutAddresses;
    }
    set checkoutAddresses(val) {
        // console.log("val====" + val);
        this._checkoutAddresses = val;
        //  console.log("_checkoutAddresses====" + JSON.stringify(this._checkoutAddresses));
    }

    editAddress()
    {
        this.openEditAddress=true;
    }
connectedCallback()
{
    this.shippingAddress();
}
    addNewAddress()
    {
        this.noAddress=true;
    }
    addNewAddressClose()
    {
        this.noAddress=false;
    }


    @wire(getRecord, { recordId: User_Id, fields: [UserNameFIELD, UserFirstNameFIELD, UserLastNameFIELD,UserAccountIdFIELD] })
    currentUserInfo({ error, data }) {
        if (data) {
            this.currentUserName = data.fields.Name.value;
            this.currentUserFirstName = data.fields.FirstName.value;
            this.currentUserLastName = data.fields.LastName.value;
            this.accountId=data.fields.AccountId.value;
          console.log('data===' + JSON.stringify(data));

        } else if (error) {
            this.error = error;
        }
    }

    @wire(getShippingAddress, { userId: User_Id })
    shippingAddress(result) {
        console.log('userId===' + this.userId);
        if(result)
        {
            this.resultdata=result;
            if (result.data) {
                console.log('Shipping data===' + JSON.stringify(result.data));
                this.shippingAddressList = result.data;
                this.getAddressOptions();
            }
            else if (result.error) {
                this.error = result.error;
                console.log('error==' + JSON.parse(result.error));
    
            }
        }
      
    }
    getAddressOptions() {

    
        this.addressOptions=[];
        // Populate the addresses array with options based on your data

        // For example, you can have multiple addresses from different records.

        // Here, we're just using the current account's shipping address.
    
            if (this.shippingAddressList.length === 1) {
                this.shipAdddressFlag=true;
                this.isOneAddress = true;
                for (let i = 0; i < this.shippingAddressList.length; i++) {
                this.oneAddress = {
                    label: this.shippingAddressList[i].Name + ', ' + this.shippingAddressList[i].Street + ', ' + this.shippingAddressList[i].City + ', ' + this.shippingAddressList[i].State + ' ' + this.shippingAddressList[i].PostalCode

                    , value: this.shippingAddressList[i].Id
                }
                this.finalShippingAddress= this.oneAddress.label;
            }
            this.selectedAddress= this.oneAddress.label;
            }
           else if (this.shippingAddressList.length > 1) {
                this.multipleAddress = true;
                this.shipAdddressFlag=true;
                for (let i = 0; i < this.shippingAddressList.length; i++) {

                    if (this.shippingAddressList[i].IsDefault) {
                        this.selectedAddress = {
                            label: this.shippingAddressList[i].Name + ', ' + this.shippingAddressList[i].Street + ', ' + this.shippingAddressList[i].City + ', ' + this.shippingAddressList[i].State + ' ' + this.shippingAddressList[i].PostalCode

                            , value: this.shippingAddressList[i].Id
                        }
                        this.finalShippingAddress= this.selectedAddress.label;
                    }
                    // else {
                        this.addressOptions.push({

                            label: this.shippingAddressList[i].Name + ', ' + this.shippingAddressList[i].Street + ', ' + this.shippingAddressList[i].City + ', ' + this.shippingAddressList[i].State + ' ' + this.shippingAddressList[i].PostalCode

                            , value: this.shippingAddressList[i].Id

                        });
                   // }

                }
            }
            else{
                console.log('in else No address');
                this.openEditAddress=true;
                this.noAddress=true;
                this.shipAdddressFlag=false;
            }
        


       // console.log('this.selectedaddress==' + JSON.stringify(this.selectedAddress));
        console.log('this.addresses==' + JSON.stringify(this.addressOptions));
       

    }

    // async handleContinue()
    // {
    //    // let address={"IsDefault":true,"ParentId":"0018B00000OsSWNQA3","State":"NY","Street":"Test 123","PostalCode":"54321","Country":"US","City":"NY","AddressType":"Shipping","Name":"Peter Parker 2"}
    //     let address={"Address":{"State":"NY","Street":"Test 123","PostalCode":"54321","Country":"US","City":"NY"}}

    //     await createContactPointAddress(address).then(async (addressResult) => {
    //         console.log("address" + JSON.stringify(addressResult));
    //         await new Promise((resolve) => setTimeout(resolve, 2000));
    //         console.log("address" + JSON.stringify(addressResult));
          
    
    //     }).catch(error => {
    
    //         console.error("Error:", JSON.stringify(error));
           
    //     })
    // }
  
   FirstName;
   LastName;
   address;
   AddressLine2;
   city;
   zip;
   showFirstNameError;
   showLastNameError;
   showCityError;
   showZipError;
   showStateError;
   showAddressError;



    handleFirstNameChange( event ) {

        this.FirstName = event.target.value;
        console.log( 'this.FirstName', this.FirstName );
        if(this.FirstName)
        {
           
           
            event.target.classList.remove('red-border');
            this.showFirstNameError='';
        }
        else{
            event.target.classList.add('red-border');
          
            this.showFirstNameError='Please enter first name.';
        }

    }
    handleLastNameChange( event ) {

        this.LastName = event.target.value;
        console.log( 'this.LastName', this.LastName );
        if(this.LastName )
        {
           
           
            event.target.classList.remove('red-border');
            this.showLastNameError='';
        }
        else{
            event.target.classList.add('red-border');
          
            this.showLastNameError='Please enter last name.';
        }

    }
    handleAddressChange( event ) {

        this.address = event.target.value;
        console.log( 'this.address', this.address );
        if(this.address )
        {
           
           
            event.target.classList.remove('red-border');
            this.showAddressError='';
        }
        else{
            event.target.classList.add('red-border');
          
            this.showAddressError='Please enter address.';
        }

    }
    handleAddressLine2Change( event ) {

        this.AddressLine2 = event.target.value;
        console.log( 'this.Address Line 2', this.AddressLine2 );

    }
    handleCityChange( event ) {
        
        this.city = event.target.value;
        console.log( 'this.Address Line 2', this.city );
        if(this.city )
        {
           
           
            event.target.classList.remove('red-border');
            this.showCityError='';
        }
        else{
            event.target.classList.add('red-border');
          
            this.showCityError='Please enter city.';
        }

    }
    handleStateChange( event ) {

        this.state = event.target.value;
        console.log( 'this.Address Line 2', this.state );
        if(this.state )
        {
           
           
            event.target.classList.remove('red-border');
            this.showStateError='';
        }
        else{
            event.target.classList.add('red-border');
          
            this.showStateError='Please enter state.';
        }

    }
    handleZipChange( event ) {

        this.zip = event.target.value;
        console.log( 'this.Address Line 2', this.zip );
        if(this.zip )
        {
           
           
            event.target.classList.remove('red-border');
            this.showZipError='';
        }
        else{
            event.target.classList.add('red-border');
          
            this.showZipError='Please enter zip.';
        }
    }
    
    
    handleContinue() {
        if(this.noAddress)
        {
            if(this.FirstName && this.LastName && this.address && this.city && this.state && this.zip)
            {
            
            
                    let fields = {};
                    fields[ ContactPointAddress_NAME_FIELD.fieldApiName ] = this.FirstName+' '+this.LastName;
                   fields[ContactPointAddress_State_FIELD.fieldApiName]=this.state;
                   fields[ContactPointAddress_City_FIELD.fieldApiName]=this.city;
                   fields[ContactPointAddress_PostalCode_FIELD.fieldApiName]=this.zip;
                   fields[ContactPointAddress_Street_FIELD.fieldApiName]=this.address;
                   fields[ContactPointAddress_ACCOUNT_Id_FIELD.fieldApiName]=this.accountId;
                   fields[ContactPointAddress_AddressType_FIELD.fieldApiName]='Shipping';
                   fields[ContactPointAddress_IsDefault_FIELD.fieldApiName]=true;
                    const recordAccountInput = { apiName: ContactPointAddress_OBJECT.objectApiName, fields };
                    createRecord( recordAccountInput )
                    .then( cpa => {
                      console.log('cpa=='+cpa);
                      this.selectedAddress=cpa.fields.Name.value+", "+cpa.fields.Street.value+", "+cpa.fields.City.value+", "+cpa.fields.State.value+", "+cpa.fields.PostalCode.value;
            this.openEditAddress=false;
                      refreshApex(this.resultdata);
                      this.dispatchEvent(
                        new ShowToastEvent( {
                            title: 'Success!',
                            message: 'Address saved successfully',
                            variant: 'success',
                        } ),
                    );
                    })
                    .catch(error=>
                        {
            console.log('error='+error);
                        })
                    }
            
                    else{
            let allInputs=this.template.querySelectorAll('input');
            for(let i=0;i<allInputs.length;i++)
            {
               if(allInputs[i].dataset.name==='First Name')
               {
                if(this.FirstName )
                {
                   
                   
                    allInputs[i].classList.remove('red-border');
                    this.showFirstNameError='';
                }
                else{
                    allInputs[i].classList.add('red-border');
                  
                    this.showFirstNameError='Please enter first name.';
                }
               }
               if(allInputs[i].dataset.name==='Last Name')
               {
                if(this.LastName )
                {
                   
                   
                    allInputs[i].classList.remove('red-border');
                    this.showLastNameError='';
                }
                else{
                    allInputs[i].classList.add('red-border');
                  
                    this.showLastNameError='Please enter last name.';
                }
               }
            
               if(allInputs[i].dataset.name==='Address')
               {
                if(this.address )
                {
                   
                   
                    allInputs[i].classList.remove('red-border');
                    this.showAddressError='';
                }
                else{
                    allInputs[i].classList.add('red-border');
                  
                    this.showAddressError='Please enter address.';
                }
               }
               if(allInputs[i].dataset.name==='City')
               {
                if(this.city )
                {
                   
                   
                    allInputs[i].classList.remove('red-border');
                    this.showCityError='';
                }
                else{
                    allInputs[i].classList.add('red-border');
                  
                    this.showCityError='Please enter city.';
                }
            
               }
               if(allInputs[i].dataset.name==='State')
               {
                if(this.state )
                {
                   
                   
                    allInputs[i].classList.remove('red-border');
                    this.showStateError='';
                }
                else{
                    allInputs[i].classList.add('red-border');
                  
                    this.showStateError='Please enter state.';
                }
               }
               if(allInputs[i].dataset.name==='Zip')
               {
                if(this.zip )
                {
                   
                   
                    allInputs[i].classList.remove('red-border');
                    this.showZipError='';
                }
                else{
                    allInputs[i].classList.add('red-border');
                  
                    this.showZipError='Please enter zip.';
                }
               }
            
            
            
            }
                    }
        }
        else{
            this.openEditAddress=false;
        }

    }

    handelSelectedAddress(event)
    {
console.log(event.target.value);
this.selectedAddress=event.target.value;
this.finalShippingAddress=event.target.value;

    }
    sendAddressToBilling(event){
        let allInputs=this.template.querySelectorAll('select');
for(let i=0;i<allInputs.length;i++)
{
   if(allInputs[i].dataset.name==='address')
   {
    this.selectedAddress=allInputs[i].value;
   }

}
        if(event.target.checked==true)
        {
            this.template.querySelector('c-bwc_billing-address-checkout').getShippingAddress(this.selectedAddress,true);

        }
        else{
            this.template.querySelector('c-bwc_billing-address-checkout').getShippingAddress({},false);

        }
    }
}