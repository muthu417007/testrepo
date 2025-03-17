import { LightningElement, api, track, wire } from 'lwc';
import BWC_UI from '@salesforce/resourceUrl/BodewellTheme';

import { refreshApex } from '@salesforce/apex';
import BWC_CallCheckoutIntrgration from '@salesforce/apex/BWC_ShippingAndBillingAddressController.BWC_CallCheckoutIntrgration';
import updateCartStatus from "@salesforce/apex/BWC_ShippingAndBillingAddressController.updateCartStatus";
import updateCheckoutStatus from "@salesforce/apex/BWC_ShippingAndBillingAddressController.updateCheckoutStatus";

//import getTaxAmount from '@salesforce/apex/BWC_CartController.getTaxAmount';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import { ShowToastEvent } from ‘lightning/platformShowToastEvent’;
// import { createRecord } from 'lightning/uiRecordApi';
// import ContactPointAddress_OBJECT from '@salesforce/schema/ContactPointAddress';
// import ContactPointAddress_NAME_FIELD from '@salesforce/schema/ContactPointAddress.Name';
// import Account_OBJECT from '@salesforce/schema/Account';
// import ContactPointAddress_ACCOUNT_Id_FIELD from '@salesforce/schema/ContactPointAddress.ParentId';
// import ContactPointAddress_State_FIELD from '@salesforce/schema/ContactPointAddress.State';
// import ContactPointAddress_City_FIELD from '@salesforce/schema/ContactPointAddress.City';
// import ContactPointAddress_PostalCode_FIELD from '@salesforce/schema/ContactPointAddress.PostalCode';
// import ContactPointAddress_Street_FIELD from '@salesforce/schema/ContactPointAddress.Street';
// import ContactPointAddress_AddressType_FIELD from '@salesforce/schema/ContactPointAddress.AddressType'

import addressValidation from '@salesforce/apex/BWC_ShippingAndBillingAddressController.Mya_AddressValidation';
import addAddress from '@salesforce/apex/BWC_ShippingAndBillingAddressController.addAddress';

import getBillingAddress from '@salesforce/apex/BWC_ShippingAndBillingAddressController.bwc_getBillingAddressB';

import { publish, MessageContext } from 'lightning/messageService';
import CHECKOUT_CHANNEL from '@salesforce/messageChannel/BWC_Checkout__c';

//Abhishek change
import { restartCheckout } from 'commerce/checkoutApi';
import modifyDeliveryGroup from '@salesforce/apex/BWC_ModifyDeliveryGroup.updateCurrentDeliveryGroup';
//Abhishek change


export default class Bwc_billingAddressCheckout extends LightningElement {
    Step_4 = BWC_UI + '/icons/checkout-icons/step-4.svg';

    Step_3 = BWC_UI + '/icons/checkout-icons/step-3.svg';
    isLoading = false;
    @api accountId;
    @api isSameShipping;
    isOneAddress = this.isSameShipping;
    noAddress = !this.isSameShipping;
    @track oneAddress;
    @track taxAmount;
    @track taxFlag=false;
    @wire(MessageContext)
    messageContext;
    cartId;
    ispayment=false;
    //Abhishek Change
    @track isPlaceOrderDisabled = false;
    //Abhishek Change

connectedCallback()
{
    if (localStorage.getItem('checkoutProducts')) {
        let localStorageProducts = JSON.parse(localStorage.getItem('checkoutProducts'));
        this.cartId = localStorageProducts.cartId;
        console.log('this.cartId===' + this.cartId);
    }
  
}

updateStatus(statusVal) {
    updateCheckoutStatus({ cartId: this.cartId, status: statusVal })
      .then(result => {
        console.log("shub status==result" + JSON.stringify(result));
        //this.getstatusOfsteps();
        this.ispayment=true;
      })
      .catch(error => {
        console.log("shub status==error" + JSON.stringify(error));
      });
  }



    //Added by Madhavi
    /*@wire(getTaxAmount, { cartId: '$cartId' })
    wiredTaxAmount({ data, error }) {       
        if (data) {
            this.taxAmount = data;
           // this.taxFlag=true;
            //localStorage.setItem('taxFlag', JSON.stringify(this.taxFlag));
            //localStorage.setItem('taxAmount', JSON.stringify(this.taxAmount));
             console.log("@@taxAmount, taxFlag from wire",JSON.stringify(data), this.taxAmount, this.taxFlag);
            //console.log("@@taxAmount",JSON.stringify(data), this.taxAmount);
        } else if (error) {
            // Handle error
        }
    }

    updateLocalStorage() {
        localStorage.setItem('taxFlag', JSON.stringify(this.taxFlag));
        localStorage.setItem('taxAmount', JSON.stringify(this.taxAmount));
        console.log("@@isSameShipping,this.taxAmount, taxFlag", this.taxAmount,this.taxFlag);                  
     
    } */

    checkDeliveryMethod(){
        modifyDeliveryGroup()
        .then(result=>{
            console.log('orderDeliveryMethod present in Cart Delivery Group-->'+result);
        })
        .catch(error=>{
            console.log('Error occured in cartDelivreryGroup-->'+error);
        })
    }

    cpaAddress;
    @wire(getBillingAddress, { accountId: '$accountId' })
    shippingAddress(result) {
        if (result) {
            this.result = result;
            console.log(' this.result==' + JSON.stringify(this.result));
            console.log(' this.isSameShipping==' + this.isSameShipping);
            if (result.data && (result.data) !={} && (result.data) !=undefined &&(result.data) !=null) {
                console.log('inside result==' + JSON.stringify(this.result));
                this.cpaAddress=result.data;
                this.oneAddress = result.data.Name + ' ' + result.data.BWC_Formatted_Address__c;
                this.noAddress = !this.isSameShipping;
                this.isOneAddress = this.isSameShipping;
                if (this.isSameShipping) {  
                    this.setBillingAddress();   
                    this.updateStatus('Payment');              
                    // this.taxFlag=true;         
                    
                    // const payLoad = {enablePlaceOrder: true, taxAmt: this.taxAmount, taxFlag:this.taxFlag};
                    // const payLoad = {enablePlaceOrder: true};
                    // publish(this.messageContext, CHECKOUT_CHANNEL, payLoad);
                    // console.log('bwc_billingAddressCheckout::shippingAddress()::enabling "Place Order" button via message channel::payload = ' + JSON.stringify(payLoad));
                    
            }


        }
    }
}
setBillingAddress()
{
  
    let modifiedResult = {
        ...this.cpaAddress,
        AddressType: "Billing"
      };
    addAddress({ accountId: this.accountId, cpa: modifiedResult })
    .then(result => {
        console.log('Billins saved to cartItem==result' + JSON.stringify(result));
        
       
    })
    .catch(error => {
        console.log('shub==error' + JSON.stringify(error));
    })
}

    @api
    getShippingAddress(address, flag) {


        console.log('oneAddress==' + this.oneAddress);
        if (flag) {
            this.oneAddress = address;
            this.noAddress = false;
            this.isOneAddress = true;
        }
        else {
            this.oneAddress = {};
            this.noAddress = true;
            this.isOneAddress = false;
        }

    }

    editbillingAddress() {
        this.noAddress = true;
        this.isOneAddress = false;

    }

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



    handleFirstNameChange(event) {

        this.FirstName = event.target.value;
        console.log('this.FirstName', this.FirstName);
        if (this.FirstName) {


            event.target.classList.remove('red-border');
            this.showFirstNameError = '';
        }
        else {
            event.target.classList.add('red-border');

            this.showFirstNameError = 'Please enter first name.';
        }

    }
    handleLastNameChange(event) {

        this.LastName = event.target.value;
        console.log('this.LastName', this.LastName);
        if (this.LastName) {


            event.target.classList.remove('red-border');
            this.showLastNameError = '';
        }
        else {
            event.target.classList.add('red-border');

            this.showLastNameError = 'Please enter last name.';
        }

    }
    handleAddressChange(event) {

        this.address = event.target.value;
        console.log('this.address', this.address);
        if (this.address) {


            event.target.classList.remove('red-border');
            this.showAddressError = '';
        }
        else {
            event.target.classList.add('red-border');

            this.showAddressError = 'Please enter address.';
        }

    }
    handleAddressLine2Change(event) {

        this.AddressLine2 = event.target.value;
        console.log('this.Address Line 2', this.AddressLine2);

    }
    handleCityChange(event) {

        this.city = event.target.value;
        console.log('this.Address Line 2', this.city);
        if (this.city) {


            event.target.classList.remove('red-border');
            this.showCityError = '';
        }
        else {
            event.target.classList.add('red-border');

            this.showCityError = 'Please enter city.';
        }

    }
    PhoneNumber;
    handlePhoneChange(event) {
        this.PhoneNumber = event.target.value;
        console.log("this.PhoneNumber  2", this.PhoneNumber);
      }
    handleStateChange(event) {

        this.state = event.target.value;
        console.log('this.Address Line 2', this.state);
        if (this.state) {


            event.target.classList.remove('red-border');
            this.showStateError = '';
        }
        else {
            event.target.classList.add('red-border');

            this.showStateError = 'Please enter state.';
        }

    }
    handleZipChange(event) {

        this.zip = event.target.value;
        console.log('this.Address Line 2', this.zip);
        if (this.zip) {


            event.target.classList.remove('red-border');
            this.showZipError = '';
        }
        else {
            event.target.classList.add('red-border');

            this.showZipError = 'Please enter zip.';
        }
    }

    userAddress;
    newAddress;
    existingAddress;
    updatedAddress;
    userAddress
    isValid;
    isOpenModal = false;
    showAddressValidError = 'This does not appear to be a valid address. Please provide valid information.';
    saveAddress() {
        this.isOpenModal = false;
        let capAddress;
        const radioInputElement = this.template.querySelector('input[type="radio"][data-name="addressCheck"]:checked').value;
        console.log('shub radioInputElement==' + radioInputElement);
        if (radioInputElement === this.updatedAddress) {
            capAddress = this.newAddress;
        }
        else if (radioInputElement === this.userAddress) {
            capAddress = this.existingAddress;
        }
        addAddress({ accountId: this.accountId, cpa: capAddress })
            .then(result => {
                console.log('shub==result' + JSON.stringify(result));
                this.oneAddress = result.Name + ' ' + result.BWC_Formatted_Address__c;
                this.noAddress = false;
                this.isOneAddress = true;
                this.updateStatus('Payment');  
                refreshApex(this.resultdata);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success!',
                        message: 'Address saved successfully',
                        variant: 'success',
                    }),
                );

               // this.callIntegration();
            })
            .catch(error => {
                console.log('shub==error' + JSON.stringify(error));
            })
    }
    updateAddress() {
        this.isOpenModal = false;
    }

    handleContinue() {
        if (this.FirstName && this.LastName && this.address && this.city && this.state && this.zip) {

            this.isLoading = true;
            addressValidation({
                firstName: this.FirstName,
                lastName: this.LastName,
                Address: this.address,
                City: this.city,
                State: this.state,
                Code: this.zip,
                addressType: 'Billing',
                addressLine2:this.AddressLine2,
                textMe:false,
                referralCode:'',
                PhoneNumber:this.PhoneNumber

            })
                .then(result => {
                    this.newAddress = result.newAddress;
                    this.existingAddress = result.existingAddress;
                    this.updatedAddress = this.newAddress.BWC_Formatted_Address__c;
                    this.userAddress = this.existingAddress.BWC_Formatted_Address__c;
                    this.isLoading = false;
                    this.isOpenModal = true;
                    if (this.newAddress.BWC_IsVerified__c === true) {
                        this.isValid = false;
                    }
                    else {
                        this.isValid = true;
                    }
                    //Abhishek change
                    this.callIntegration();
                    this.checkDeliveryMethod();
                    // setTimeout(() => {
                    //     console.log('wait 2 sec');
                        
                    // }, 10000);
                    
                    //Abhishek change
                    // Add console.log to print out result as JSON string
                    console.log('bwc_billingAddressCheckout::handleContinue::addressValidation::result=' + JSON.stringify(result));
                    if(this.isPlaceOrderDisabled){
                        const payLoad = {enablePlaceOrder: false};
                        publish(this.messageContext, CHECKOUT_CHANNEL, payLoad); 
                    console.log('bwc_billingAddressCheckout::shippingAddress()::enabling "Place Order" button via message channel::payload = ' + JSON.stringify(payLoad));
                    }
                    else{
                    const payLoad = {enablePlaceOrder: true};
                    publish(this.messageContext, CHECKOUT_CHANNEL, payLoad);
                    console.log('bwc_billingAddressCheckout::shippingAddress()::enabling "Place Order" button via message channel::payload = ' + JSON.stringify(payLoad));
                    }
                })
                .catch(error=>
                    {
                        this.isLoading = false;
                    })



            //          let fields = {};
            //          fields[ ContactPointAddress_NAME_FIELD.fieldApiName ] = this.FirstName+' '+this.LastName;
            //         fields[ContactPointAddress_State_FIELD.fieldApiName]=this.state;
            //         fields[ContactPointAddress_City_FIELD.fieldApiName]=this.city;
            //         fields[ContactPointAddress_PostalCode_FIELD.fieldApiName]=this.zip;
            //         fields[ContactPointAddress_Street_FIELD.fieldApiName]=this.address;
            //         fields[ContactPointAddress_ACCOUNT_Id_FIELD.fieldApiName]=this.accountId;
            //         fields[ContactPointAddress_AddressType_FIELD.fieldApiName]='billing';
            //          const recordAccountInput = { apiName: ContactPointAddress_OBJECT.objectApiName, fields };
            //          createRecord( recordAccountInput )
            //          .then( cpa => {
            //            console.log('cpa=='+JSON.stringify(cpa));
            //            //                    label: this.shippingAddressList[i].Name + ', ' + this.shippingAddressList[i].Street + ', ' + this.shippingAddressList[i].City + ', ' + this.shippingAddressList[i].State + ' ' + this.shippingAddressList[i].PostalCode

            //         this.oneAddress=cpa.fields.Name.value+", "+cpa.fields.Street.value+", "+cpa.fields.City.value+", "+cpa.fields.State.value+", "+cpa.fields.PostalCode.value;
            //        console.log('this.oneAddress'+this.oneAddress);
            //         this.noAddress =false;
            //         this.isOneAddress=true;
            //         // refreshApex(this.resultdata);
            //            this.dispatchEvent(
            //              new ShowToastEvent( {
            //                  title: 'Success!',
            //                  message: 'Address saved successfully',
            //                  variant: 'success',
            //              } ),
            //          );
            //          })
            //          .catch(error=>
            //              {
            //  console.log('error='+error);
            //              })
        }

        else {
            this.isLoading = true;
            let allInputs = this.template.querySelectorAll('input');
            for (let i = 0; i < allInputs.length; i++) {
                if (allInputs[i].dataset.name === 'First Name') {
                    if (this.FirstName) {


                        allInputs[i].classList.remove('red-border');
                        this.showFirstNameError = '';
                    }
                    else {
                        allInputs[i].classList.add('red-border');

                        this.showFirstNameError = 'Please enter first name.';
                    }
                }
                if (allInputs[i].dataset.name === 'Last Name') {
                    if (this.LastName) {


                        allInputs[i].classList.remove('red-border');
                        this.showLastNameError = '';
                    }
                    else {
                        allInputs[i].classList.add('red-border');

                        this.showLastNameError = 'Please enter last name.';
                    }
                }

                if (allInputs[i].dataset.name === 'Address') {
                    if (this.address) {


                        allInputs[i].classList.remove('red-border');
                        this.showAddressError = '';
                    }
                    else {
                        allInputs[i].classList.add('red-border');

                        this.showAddressError = 'Please enter address.';
                    }
                }
                if (allInputs[i].dataset.name === 'City') {
                    if (this.city) {


                        allInputs[i].classList.remove('red-border');
                        this.showCityError = '';
                    }
                    else {
                        allInputs[i].classList.add('red-border');

                        this.showCityError = 'Please enter city.';
                    }

                }
                if (allInputs[i].dataset.name === 'State') {
                    if (this.state) {


                        allInputs[i].classList.remove('red-border');
                        this.showStateError = '';
                    }
                    else {
                        allInputs[i].classList.add('red-border');

                        this.showStateError = 'Please enter state.';
                    }
                }
                if (allInputs[i].dataset.name === 'Zip') {
                    if (this.zip) {


                        allInputs[i].classList.remove('red-border');
                        this.showZipError = '';
                    }
                    else {
                        allInputs[i].classList.add('red-border');

                        this.showZipError = 'Please enter zip.';
                    }
                }



            }
            this.isLoading = false;
        }

      
        //Added by Madhavi
        // console.log("taxAmount" ,this.taxAmount);
        if (this.taxAmount) {
            const fetchedTaxAmount = this.taxAmount;
            this.taxFlag=true;     
            //refreshApex(this.wiredTaxAmount); 
            //this.taxAmount = this.taxAmount;      
            localStorage.setItem('taxFlag', JSON.stringify(this.taxFlag));
            localStorage.setItem('taxAmount', JSON.stringify(this.taxAmount));
            console.log("fetchedTaxAmount ContinueClick Billing,this.taxAmount, taxFlag",fetchedTaxAmount,this.taxAmount, this.taxFlag);
        } else
        this.taxFlag=false;
    }

    checkCartStatus(){
        updateCartStatus({ cartId: this.cartId })
        .then(result => {
          console.log('Cart updated success',result);
        })
        .catch(error => {
          console.log('Cart updation error',error);
        })
       }

    callIntegration()
    {
        this.checkCartStatus();
        BWC_CallCheckoutIntrgration({cartId:this.cartId})
        .then(result=>
            {
                console.log(' customer Integration Call result==>' + result);
                restartCheckout();
            })
            .catch(error=>
                {
                    this.isPlaceOrderDisabled = true;
                this.dispatchEvent(
                                    new ShowToastEvent( {
                                        title: 'Error!',
                                        message: 'This item is not available, please try another one',
                                        variant: 'error',
                                    } ),
                                );
                    console.log('shubh error==>' + JSON.stringify(error));
                })

    }

}