import { LightningElement, wire, track, api } from "lwc";
import BWC_UI from '@salesforce/resourceUrl/BodewellTheme';
import getContactPointByContactId from '@salesforce/apex/BWC_ShippingAndBillingAddressController.getContactPointByContactId';
import User_Id from "@salesforce/user/Id";
import getConsumerZipcode from "@salesforce/apex/BWC_ShippingAndBillingAddressController.getConsumerZipcode";

import getCheckoutStatus from "@salesforce/apex/BWC_ShippingAndBillingAddressController.getCheckoutStatus";
import updateCheckoutStatus from "@salesforce/apex/BWC_ShippingAndBillingAddressController.updateCheckoutStatus";

import updatecartItem from "@salesforce/apex/BWC_ShippingAndBillingAddressController.updatecartItem";

import getShippingAddress from "@salesforce/apex/BWC_ShippingAndBillingAddressController.bwc_getShippingAddress";
import { getRecord } from "lightning/uiRecordApi";
import UserNameFIELD from "@salesforce/schema/User.Name";
import UserFirstNameFIELD from "@salesforce/schema/User.FirstName";
import UserLastNameFIELD from "@salesforce/schema/User.LastName";
import UserAccountIdFIELD from "@salesforce/schema/User.AccountId";
import UserEmailFIELD from "@salesforce/schema/User.Email";
import UserContactIdField from "@salesforce/schema/User.ContactId";
//import { createContactPointAddress } from 'commerce/checkoutApi';
import addressValidation from "@salesforce/apex/BWC_ShippingAndBillingAddressController.Mya_AddressValidation";
import addAddress from "@salesforce/apex/BWC_ShippingAndBillingAddressController.addAddress";
import makeAddressDefault from "@salesforce/apex/BWC_ShippingAndBillingAddressController.makeAddressDefault";
import { refreshApex } from "@salesforce/apex";
import BWC_CallCheckoutIntrgration from "@salesforce/apex/BWC_ShippingAndBillingAddressController.BWC_CallCheckoutIntrgration";
import updateCartStatus from "@salesforce/apex/BWC_ShippingAndBillingAddressController.updateCartStatus";

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import zipCodeChannel from "@salesforce/messageChannel/zipCodeChange__c";
import { publish, MessageContext } from "lightning/messageService";

// Abhishek change
import { restartCheckout } from "commerce/checkoutApi";
import CHECKOUT_CHANNEL from "@salesforce/messageChannel/BWC_Checkout__c";
import modifyDeliveryGroup from "@salesforce/apex/BWC_ModifyDeliveryGroup.updateCurrentDeliveryGroup";
import hitADC_Api from "@salesforce/apex/BWC_ADC_Controller.hitADC_Api";
// Abhishek change

/**
* @description A component used to complete shipping address step on checkout
*/
export default class Bwc_checkoutShippingAddress extends LightningElement {
  Step_1 = BWC_UI + '/icons/checkout-icons/step-1.svg';
  Step_2 = BWC_UI + '/icons/checkout-icons/step-2.svg';
  Step_3 = BWC_UI + '/icons/checkout-icons/step-3.svg';
  Step_4 = BWC_UI + '/icons/checkout-icons/step-4.svg';
  @wire(MessageContext) messageContext;

  isOpenModal = false;
  isLoading = false;
  shippingContinue = false;
  @track section2OpenEditAddress = false;
  section2Flag = false;
  @track error;
  openEditAddress = false;
  @track userId = User_Id;
  userEmail;
  @track currentUserName;
  @track currentUserFirstName;
  @track currentUserLastName;
  @track shippingAddressList;
  @track selectedAddress;
  @track addressOptions = [];
  @track finalShippingAddress;
  shipAdddressFlag = true;
  @track resultdata;
  _checkoutAddresses;
  @track accountId;
  @track isOneAddress = false;
  oneAddress;
  @track multipleAddress = false;
  @track noAddress = false;
  inputClass = "slds-input";
  shippingDone = false;
  cartId;
  @track contactId;
  isValidZipCode = false;
  @api
  get checkoutAddresses() {
    return this._checkoutAddresses;
  }
  set checkoutAddresses(val) {
    // console.log("val====" + val);
    this._checkoutAddresses = val;
    //  console.log("_checkoutAddresses====" + JSON.stringify(this._checkoutAddresses));
  }

  editAddress() {
    this.openEditAddress = true;
  }

  checkDeliveryMethod() {
    modifyDeliveryGroup()
      .then(result => {
        console.log(
          "orderDeliveryMethod present in Cart Delivery Group-->" + result
        );
      })
      .catch(error => {
        console.log("Error occured in cartDelivreryGroup-->" + error);
      });
  }


  connectedCallback() {

    this.shippingAddress();

    this.template.addEventListener(
      "ShipDateAndMethod",
      this.handleShippingContinue.bind(this)
    );
    if (localStorage.getItem("checkoutProducts")) {
      let localStorageProducts = JSON.parse(
        localStorage.getItem("checkoutProducts")
      );
      this.cartId = localStorageProducts.cartId;
      console.log(" checkout shipping this.cartId===" + this.cartId);
      this.getstatusOfsteps();
    }
    if (localStorage.getItem('ShippingSameAsBilling')) {
      let localStorageProducts = localStorage.getItem('ShippingSameAsBilling');
      if (localStorageProducts === 'true') {
        this.isShippingSameAsBilling = true;
      }
      else {
        this.isShippingSameAsBilling = false;
      }
    }
    this.getstatusOfsteps();
  }

  getContactPointByContactID() {
    console.log("contactId -->" + this.contactId);

    getContactPointByContactId({ ContactId: this.contactId })
      .then(result => {
        console.log("getContactPointByContactID result-->" + JSON.stringify(result));
        this.PhoneNumber = result.Phone__c;
      })
      .catch(error => {
        console.log("getContactPointByContactID error-->" + error);
      })
  }

  addNewAddress() {
    this.noAddress = true;
  }
  addNewAddressClose() {
    this.noAddress = false;
  }

  statusData;
  section2OpenEditAddressHeader = true;
  status;
  // @wire(getCheckoutStatus, { cartId: "$cartId" })
  // checkoutStatus(result) {
  //   if (result) {
  //     this.statusData = result;
  //     this.getstatusOfsteps();
  //     if (result.data) {
  //       this.status = result.data;

  //       if (this.status === "Customer") {
  //         this.openEditAddress = true;
  //         this.section2OpenEditAddress = false;
  //         this.section2OpenEditAddressHeader = true;
  //         this.shippingContinue = false;
  //       }
  //       if (this.status === "Shipping") {
  //         this.openEditAddress = false;
  //         this.section2OpenEditAddress = true;
  //         this.section2OpenEditAddressHeader = true;
  //       }
  //       if (this.status === "Billing") {
  //         this.section2OpenEditAddress = false;
  //         this.section2OpenEditAddressHeader = false;
  //         this.shippingContinue = true;

  //       }
  //       if (this.status === "Payment") {
  //         this.section2OpenEditAddress = false;
  //         this.section2OpenEditAddressHeader = false;
  //         this.shippingContinue = true;
  //       }
  //       console.log(" this.status===" + this.status);
  //     } else if (result.error) {
  //       console.log(" this.result.error===" + JSON.stringify(result.error));
  //     }
  //   }
  // }
  getstatusOfsteps() {
    getCheckoutStatus({ cartId: this.cartId })
      .then(result => {

        this.status = result;

        if (this.status === "Customer") {
          this.openEditAddress = true;
          this.section2OpenEditAddress = false;
          this.section2OpenEditAddressHeader = true;
          this.shippingContinue = false;
        }
        if (this.status === "Shipping") {
          this.openEditAddress = false;
          this.section2OpenEditAddress = true;
          this.section2OpenEditAddressHeader = true;
        }
        if (this.status === "Billing") {
          this.section2OpenEditAddress = false;
          this.section2OpenEditAddressHeader = false;
          this.shippingContinue = true;

        }
        if (this.status === "Payment") {
          this.section2OpenEditAddress = false;
          this.section2OpenEditAddressHeader = false;
          this.shippingContinue = true;
        }
        console.log(" this.status===2" + this.status);
      })
      .catch(error => {
        console.log(" this.result.error===" + JSON.stringify(error));
      })
  }


  @wire(getRecord, {
    recordId: User_Id,
    fields: [
      UserNameFIELD,
      UserFirstNameFIELD,
      UserLastNameFIELD,
      UserAccountIdFIELD,
      UserEmailFIELD,
      UserContactIdField
    ]
  })
  currentUserInfo({ error, data }) {
    if (data) {
      this.currentUserName = data.fields.Name.value;
      this.currentUserFirstName = data.fields.FirstName.value;
      this.currentUserLastName = data.fields.LastName.value;
      this.accountId = data.fields.AccountId.value;
      this.userEmail = data.fields.Email.value;
      this.contactId = data.fields.ContactId.value;
      console.log("data===" + JSON.stringify(data));
      this.getContactPointByContactID();
    } else if (error) {
      this.error = error;
    }
  }

  @wire(getShippingAddress, { userId: User_Id })
  shippingAddress(result) {
    console.log("userId===" + this.userId);
    if (result) {
      this.resultdata = result;
      if (result.data) {
        console.log("Shipping data===" + JSON.stringify(result.data));
        this.shippingAddressList = result.data;
        this.getAddressOptions();
      } else if (result.error) {
        this.error = result.error;
        console.log("error==" + JSON.parse(result.error));
      }
    }
  }
  getAddressOptions() {
    this.addressOptions = [];
    // Populate the addresses array with options based on your data

    // For example, you can have multiple addresses from different records.

    // Here, we're just using the current account's shipping address.

    if (this.shippingAddressList.length === 1) {
      this.shipAdddressFlag = true;
      this.isOneAddress = true;
      for (let i = 0; i < this.shippingAddressList.length; i++) {
        this.selectedAddressId = this.shippingAddressList[i].Id;
        console.log("this.selectedAddressId=== all" + this.selectedAddressId);
        this.FirstName = this.shippingAddressList[i].AddressFirstName;
        this.LastName = this.shippingAddressList[i].AddressLastName;
        this.oneAddress = {
          label:
            this.shippingAddressList[i].Name +
            ", " +
            this.shippingAddressList[i].BWC_Formatted_Address__c
          ,

          value: this.shippingAddressList[i].Id
        };
        this.finalShippingAddress = this.oneAddress.label;
      }
      this.selectedAddress = this.oneAddress.label;
    } else if (this.shippingAddressList.length > 1) {
      this.multipleAddress = true;
      this.shipAdddressFlag = true;

      this.FirstName = this.shippingAddressList[0].AddressFirstName;
      this.LastName = this.shippingAddressList[0].AddressLastName;
      for (let i = 0; i < this.shippingAddressList.length; i++) {
        if (this.shippingAddressList[i].IsDefault) {
          this.selectedAddress = {
            label:
              this.shippingAddressList[i].Name +
              ", " +
              this.shippingAddressList[i].Street +
              ", " +
              this.shippingAddressList[i].City +
              ", " +
              this.shippingAddressList[i].State +
              " " +
              this.shippingAddressList[i].PostalCode,

            value: this.shippingAddressList[i].Id
          };
          this.finalShippingAddress = this.selectedAddress.label;
        }
        // else {
        this.addressOptions.push({
          label:
            this.shippingAddressList[i].Name +
            ", " +
            this.shippingAddressList[i].Street +
            ", " +
            this.shippingAddressList[i].City +
            ", " +
            this.shippingAddressList[i].State +
            " " +
            this.shippingAddressList[i].PostalCode,

          value: this.shippingAddressList[i].Id
        });
        // }
      }
    } else {
      console.log("in else No address");
      this.openEditAddress = true;
      this.noAddress = true;
      this.shipAdddressFlag = false;
    }

    // console.log('this.selectedaddress==' + JSON.stringify(this.selectedAddress));
    console.log("this.addresses==" + JSON.stringify(this.addressOptions));
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

  FirstName = '';
  PhoneNumber = '';
  textMe = false;
  referralCode;
  LastName = '';
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
    console.log("this.FirstName", this.FirstName);
    if (this.FirstName) {
      event.target.classList.remove("red-border");
      this.showFirstNameError = "";
    } else {
      event.target.classList.add("red-border");

      this.showFirstNameError = "Please enter first name.";
    }
  }
  handleLastNameChange(event) {
    this.LastName = event.target.value;
    console.log("this.LastName", this.LastName);
    if (this.LastName) {
      event.target.classList.remove("red-border");
      this.showLastNameError = "";
    } else {
      event.target.classList.add("red-border");

      this.showLastNameError = "Please enter last name.";
    }
  }
  handleAddressChange(event) {
    this.address = event.target.value;
    console.log("this.address", this.address);
    if (this.address) {
      event.target.classList.remove("red-border");
      this.showAddressError = "";
    } else {
      event.target.classList.add("red-border");

      this.showAddressError = "Please enter address.";
    }
  }
  handleAddressLine2Change(event) {
    this.AddressLine2 = event.target.value;
    console.log("this.Address Line 2", this.AddressLine2);
  }
  handleTextMeChange(event) {
    if (event.target.checked == true) {
      this.textMe = event.target.checked;
    } else {
      this.textMe = false;
    }
    console.log("this.text  2", this.textMe);
  }
  handleReferralChange(event) {
    this.referralCode = event.target.value;
    console.log("this.referralCode Line 2", this.referralCode);
  }
  showPhoneError = '';
  handlePhoneChange(event) {
    this.PhoneNumber = event.target.value;
    console.log("this.PhoneNumber  2", this.PhoneNumber);
    if (this.PhoneNumber) {
      event.target.classList.remove("red-border");
      this.showPhoneError = "";
    } else {
      event.target.classList.add("red-border");

      this.showPhoneError = "Please enter phone number.";
    }
  }
  handleCityChange(event) {
    this.city = event.target.value;
    console.log("this.Address Line 2", this.city);
    if (this.city) {
      event.target.classList.remove("red-border");
      this.showCityError = "";
    } else {
      event.target.classList.add("red-border");

      this.showCityError = "Please enter city.";
    }
  }
  handleStateChange(event) {
    this.state = event.target.value;
    console.log("this.Address Line 2", this.state);
    if (this.state) {
      event.target.classList.remove("red-border");
      this.showStateError = "";
    } else {
      event.target.classList.add("red-border");

      this.showStateError = "Please enter state.";
    }
  }
  handleZipChange(event) {
    this.zip = event.target.value;
    console.log("this.Address Line 2", this.zip);
    if (this.zip) {
      event.target.classList.remove("red-border");
      this.showZipError = "";
    } else {
      event.target.classList.add("red-border");

      this.showZipError = "Please enter zip.";
    }
  }
  userAddress;
  newAddress;
  existingAddress;
  isValid;
  selectedAddressId;
  showAddressValidError = "This does not appear to be a valid address. Please provide valid information.";
  saveAddress() {
    console.log("this.zip--<<"+this.zip);
    this.validateADC_ZipCode(this.zip);
    this.isOpenModal = false;
    let capAddress;
    const radioInputElement = this.template.querySelector(
      'input[type="radio"][data-name="addressCheck"]:checked'
    ).value;
    console.log("shub radioInputElement==" + radioInputElement);
    if (radioInputElement === this.updatedAddress) {
      capAddress = this.newAddress;
    } else if (radioInputElement === this.userAddress) {
      capAddress = this.existingAddress;
    }
    addAddress({ accountId: this.accountId, cpa: capAddress })
      .then(result => {
        console.log("shub==result" + JSON.stringify(result));
        this.selectedAddress =
          result.Name + " " + result.BWC_Formatted_Address__c;
        this.openEditAddress = false;
        this.section2Flag = true;
        refreshApex(this.resultdata);
        this.updateStatus("Shipping");
        this.section2OpenEditAddress = true;
        this.section2OpenEditAddressHeader = true;
        this.setZipCodeOnCheckout();

        //   location.reload();
        //this.fullAddress={'Zipcode':this.zip,'City':this.city,'State':this.state,'Country':}
        //localStorage.setItem('zipcode', JSON.stringify(this.fullAddress));
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success!",
            message: "Address saved successfully",
            variant: "success"
          })
        );
        this.callIntegration();
        // this.calculatingTax();
      })
      .catch(error => {
        console.log("shub==error" + JSON.stringify(error));
      });
  }
  updateAddress() {
    this.isOpenModal = false;
  }
  checkCartStatus() {
    updateCartStatus({ cartId: this.cartId })
      .then(result => {
        console.log('Cart updated success', result);
      })
      .catch(error => {
        console.log('Cart updation error', error);
      })
  }
  @track isPlaceOrderDisabled = false;
  callIntegration() {
    this.checkCartStatus();
    BWC_CallCheckoutIntrgration({ cartId: this.cartId })
      .then(result => {
        console.log(" customer Integration Call result==>" + JSON.stringify(result));
        console.log(" customer Integration Call resultnext==>", result);

      })
      .catch(error => {
        this.isPlaceOrderDisabled = true;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error!",
            message: "This item is not available, please try another one",
            variant: "error"
          })
        );
        console.log("shubh error==>" + JSON.stringify(error));
      });
  }
  handleContinue() {


    let billingInput = this.template.querySelectorAll(`[data-name="Billing Checkbox"]`);
    for (let i = 0; i < billingInput.length; i++) {
      console.log('billingInput[i].value' + billingInput[i].checked);
      if (billingInput[i].checked == true) {
        this.isShippingSameAsBilling = true;
        localStorage.setItem("ShippingSameAsBilling", "true");
      } else {
        this.isShippingSameAsBilling = false;
        localStorage.setItem("ShippingSameAsBilling", "false");
      }

    }


    console.log(
      "inside handleContinue this.isShippingSameAsBilling-->",
      this.isShippingSameAsBilling
    );
    if (this.noAddress) {
      if (
        this.FirstName &&
        this.LastName &&
        this.address &&
        this.city &&
        this.state &&
        this.zip &&
        this.PhoneNumber
      ) {
        this.isLoading = true;
        //String firstName,String lastName,String Address,String City,String State,String Code

        addressValidation({
          firstName: this.FirstName,
          lastName: this.LastName,
          Address: this.address,
          City: this.city,
          State: this.state,
          Code: this.zip,
          addressType: "Shipping",
          addressLine2: this.AddressLine2,
          textMe: this.textMe,
          referralCode: this.referralCode,
          PhoneNumber: this.PhoneNumber
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
            } else {
              this.isValid = true;
            }
          })
          .catch(error => {
            this.isLoading = false;
            console.log("shubh error==>" + JSON.stringify(error));
          });


      } else {
        let allInputs = this.template.querySelectorAll("input");
        for (let i = 0; i < allInputs.length; i++) {
          if (allInputs[i].dataset.name === "First Name") {
            if (this.FirstName) {
              allInputs[i].classList.remove("red-border");
              this.showFirstNameError = "";
            } else {
              allInputs[i].classList.add("red-border");

              this.showFirstNameError = "Please enter first name.";
            }
          }
          if (allInputs[i].dataset.name === "Last Name") {
            if (this.LastName) {
              allInputs[i].classList.remove("red-border");
              this.showLastNameError = "";
            } else {
              allInputs[i].classList.add("red-border");

              this.showLastNameError = "Please enter last name.";
            }
          }

          if (allInputs[i].dataset.name === "Address") {
            if (this.address) {
              allInputs[i].classList.remove("red-border");
              this.showAddressError = "";
            } else {
              allInputs[i].classList.add("red-border");

              this.showAddressError = "Please enter address.";
            }
          }
          if (allInputs[i].dataset.name === "City") {
            if (this.city) {
              allInputs[i].classList.remove("red-border");
              this.showCityError = "";
            } else {
              allInputs[i].classList.add("red-border");

              this.showCityError = "Please enter city.";
            }
          }
          if (allInputs[i].dataset.name === "State") {
            if (this.state) {
              allInputs[i].classList.remove("red-border");
              this.showStateError = "";
            } else {
              allInputs[i].classList.add("red-border");

              this.showStateError = "Please enter state.";
            }
          }

          if (allInputs[i].dataset.name === "Phone") {
            if (this.PhoneNumber) {
              allInputs[i].classList.remove("red-border");
              this.showPhoneError = "";
            } else {
              allInputs[i].classList.add("red-border");

              this.showPhoneError = "Please enter phone number.";
            }
          }
          if (allInputs[i].dataset.name === "Zip") {
            if (this.zip) {
              allInputs[i].classList.remove("red-border");
              this.showZipError = "";
            } else {
              allInputs[i].classList.add("red-border");

              this.showZipError = "Please enter zip.";
            }
          }
        }
      }
    } else {
      if (!this.PhoneNumber) {
        let allInputs = this.template.querySelectorAll("input");
        for (let i = 0; i < allInputs.length; i++) {
          if (allInputs[i].dataset.name === "Phone") {
            if (this.PhoneNumber) {
              allInputs[i].classList.remove("red-border");
              this.showPhoneError = "";
            } else {
              allInputs[i].classList.add("red-border");

              this.showPhoneError = "Please enter phone number.";
            }
          }
        }
      }
      else {
        this.isLoading = true;
        let allInputs = this.template.querySelectorAll("select");
        console.log('zip-->' + this.zip);
        console.log(" this.allInputs==" + JSON.stringify(allInputs));
        for (let i = 0; i < allInputs.length; i++) {
          if (allInputs[i].dataset.name === "address") {
            let selectedAddress = allInputs[i].value;
            console.log(" this.selectedAddress==" + selectedAddress);
            for (let key in this.addressOptions) {
              if (this.addressOptions[key].label === selectedAddress) {
                this.selectedAddressId = this.addressOptions[key].value;
              }
            }

            console.log("this.selectedAddressId=== all" + this.selectedAddressId);
          }
        }
        console.log("this.selectedAddressId=== all" + this.selectedAddressId);
        console.log("this.PhoneNumber=== all" + this.PhoneNumber);

        makeAddressDefault({ addressId: this.selectedAddressId, phoneNumber: this.PhoneNumber })
          .then(result => {
            this.isLoading = false;
            //  location.reload();
            this.openEditAddress = false;
            this.section2OpenEditAddress = true;
            this.section2OpenEditAddressHeader = true;
            this.updateStatus('Shipping');

            //this.fullAddress={'Zipcode':this.zip,'City':this.city,'State':this.state,'Country':}
            //localStorage.setItem('zipcode', JSON.stringify(this.fullAddress));
            console.log("shub==result" + JSON.stringify(result));
            this.setZipCodeOnCheckout();
            this.callIntegration();
          })
          .catch(error => {
            this.isLoading = false;
            this.openEditAddress = false;
            this.section2OpenEditAddress = true;
            this.section2OpenEditAddressHeader = true;
            console.log("shub==error" + JSON.stringify(error));
          });
        // this.calculatingTax();
      }

      //  this.section2Flag=true;

    }

  }

  // calculatingTax(){
  //   if (this.isShippingSameAsBilling === true) {
  //       console.log(
  //         "Inside if this.isShippingSameAsBilling-->" +
  //           this.isShippingSameAsBilling
  //       );
  //       this.callIntegration();
  //       this.checkDeliveryMethod();
  //       restartCheckout();
  //       if (this.isPlaceOrderDisabled) {
  //         const payLoad = { enablePlaceOrder: false };
  //         publish(this.messageContext, CHECKOUT_CHANNEL, payLoad);
  //         console.log(
  //           'bwc_billingAddressCheckout::shippingAddress()::enabling "Place Order" button via message channel::payload = ' +
  //             JSON.stringify(payLoad)
  //         );
  //       } else {
  //         const payLoad = { enablePlaceOrder: true };
  //         publish(this.messageContext, CHECKOUT_CHANNEL, payLoad);
  //         console.log(
  //           'bwc_billingAddressCheckout::shippingAddress()::enabling "Place Order" button via message channel::payload = ' +
  //             JSON.stringify(payLoad)
  //         );
  //       }
  //     }
  // }

  handelSelectedAddress(event) {
    console.log(event.target.value);
    this.selectedAddress = event.target.value;
    this.finalShippingAddress = event.target.value;
    this.selectedAddressId = event.target.key;
    console.log("this.selectedAddressId=== all" + this.selectedAddressId);
  }
  @track isShippingSameAsBilling = false;
  sendAddressToBilling(event) {
    console.log("event.target.checked==" + event.target.checked);
    if (event.target.checked == true) {
      this.isShippingSameAsBilling = true;
      localStorage.setItem("ShippingSameAsBilling", "true");
    } else {
      this.isShippingSameAsBilling = false;
      localStorage.setItem("ShippingSameAsBilling", "false");
    }
  }

  handleShippingContinue(event) {
    console.log("event handel");
    const shipDetails = event.detail;
    console.log("shipDetails ==" + JSON.stringify(shipDetails));

    this.updateShipDetails(shipDetails);
    console.log("eisShippingSameAsBilling==" + this.isShippingSameAsBilling);
    this.shippingContinue = true;
    this.accountId = this.accountId + ' ';
    this.section2OpenEditAddress = false;
    this.section2OpenEditAddressHeader = false;
    this.updateStatus("Billing");
    if (this.isShippingSameAsBilling) {
      this.updateStatus("Billing");
    } else {
      this.updateStatus("Payment");
    }
  }
  updateShipDetails(shipDetails) {
    //let payload={ExpectedDeliveryDate:this.expectedDeliveryDate,hdCartItems:this._hdList,ExpectedpickupDeliveryDate:this.expectedpickupDeliveryDate,pickupcartItems:this._pickupList,shipType:this.selectedPartsShip,shipcartItems:this._partsList }
    let hdItems = [];
    let sdItems = [];
    let pickItems = [];
    let partsItems = [];
    let prodShipItems = [];
    for (let key in shipDetails.hdCartItems) {
      hdItems.push(shipDetails.hdCartItems[key].id);
    }
    for (let key in shipDetails.sdsList) {
      sdItems.push(shipDetails.sdsList[key].id);
    }
    for (let key in shipDetails.pickupcartItems) {
      pickItems.push(shipDetails.pickupcartItems[key].id);
    }
    for (let key in shipDetails.shipcartItems) {
      partsItems.push(shipDetails.shipcartItems[key].id);
    }
    for (let key in shipDetails.prodShippingList) {
      prodShipItems.push(shipDetails.prodShippingList[key].id);
    }

    var tempDe = new Date(shipDetails.ExpectedDeliveryDate);
    var month = tempDe.getMonth() + 1;
    let delDate = tempDe.getFullYear() + "-" + month + "-" + tempDe.getDate();

    var temppi = new Date(shipDetails.ExpectedpickupDeliveryDate);
    var month1 = temppi.getMonth() + 1;
    let picDate = temppi.getFullYear() + "-" + month1 + "-" + temppi.getDate();
    console.log("delDate==" + delDate);
    console.log("picDate==" + picDate);
    console.log(
      "JSON.stringify(shipDetails.pickupLocation)==" +
      JSON.stringify(shipDetails.pickupLocation)
    );
    let location = JSON.stringify(shipDetails.pickupLocation);
    console.log("JSON.stringify(shipDetails.location)==" + location);

    updatecartItem({
      expectedDeliveryDate: delDate,
      hdCartItems: hdItems,
      expectedpickupDeliveryDate: picDate,
      pickupcartItems: pickItems,
      shipType: shipDetails.shipType,
      shipcartItems: partsItems,
      shipFee: shipDetails.shipFee,
      prodShippingList: prodShipItems,
      pickupLocation: location,
      sdsList: sdItems
    })
      .then(result => {
        console.log("shubh result====" + JSON.stringify(result));
      })
      .catch(error => {
        console.log("shubh error====" + JSON.stringify(error));
      });
  }

  updateStatus(statusVal) {
    updateCheckoutStatus({ cartId: this.cartId, status: statusVal })
      .then(result => {
        console.log("shub status==result" + JSON.stringify(result));
        this.getstatusOfsteps();
      })
      .catch(error => {
        console.log("shub status==error" + JSON.stringify(error));
      });
  }

  editShippingAddress() {
    this.section2OpenEditAddress = true;
    this.shippingContinue = false;
  }



  setZipCodeOnCheckout() {
    console.log("test");
    getConsumerZipcode({ accountId: this.accountId })
      .then(data => {
        console.log("Consumer update checkout zip and state " + JSON.stringify(data));
        this.zipCode = data.PostalCode;
        this.state = data.State;
        console.log(
          "Consumer update checkout zipcode and state are " +
          this.zipCode +
          " " +
          this.state
        );
        let fullAddress = {
          Zipcode: data.PostalCode,
          City: data.City,
          State: data.State,
          Country: data.Country
        };
        localStorage.setItem("zipcode", JSON.stringify(fullAddress));
        this.sendCodeToParentUpdatedZip(fullAddress);

        //abhishek changes
        this.validateADC_ZipCode(this.zipCode);
        //abhishek changes

      })
      .catch(error => {
        console.log("Consumer error occured " + error);
      });
  }

  async validateADC_ZipCode(zipCodeInstance) {

    console.log('this.zip-->' + zipCodeInstance);
    await hitADC_Api({ postalCodeInstance: zipCodeInstance })
      .then(result => {
        console.log('adcResult-->', result);
        let checkAdcOrg = JSON.parse(result);
        console.log('checkAdcOrg-->', checkAdcOrg[0].adcOrg);
        //if (!checkAdcOrg[0].adcOrg) {
          if (!checkAdcOrg[0].adcOrg){
          this.isValidZipCode = true;
          return;
        }
        //temp changes
      })
      .catch(error => {
        console.error("error-->", error);
      });
  } 

  sendCodeToParentUpdatedZip(fullAddress) {
    //console.log('message dispatched New');
    let message = { message: fullAddress };
    publish(this.messageContext, zipCodeChannel, message);
  }

  //Abhishek changes on 04/03/24
  callIntegration() {
    this.checkCartStatus();
    BWC_CallCheckoutIntrgration({ cartId: this.cartId })
      .then(result => {
        this.isPlaceOrderDisabled = false;
        this.placeOrderButtonDisbaled(this.isPlaceOrderDisabled);
        //temp changes
        console.log('before restartCheckout');
        //temp changes

        restartCheckout();

        //temp changes
        console.log('before restartCheckout');
        //temp changes
      })
      .catch(error => {
        this.isPlaceOrderDisabled = true;
        this.placeOrderButtonDisbaled(this.isPlaceOrderDisabled);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error!",
            message: "This item is not available, please try another one",
            variant: "error"
          })
        );
      });
    //temp changes
    restartCheckout();
    //temp changes
  }
  checkCartStatus() {
    updateCartStatus({ cartId: this.cartId })
      .then(result => {
        console.log('Cart updated success', result);
      })
      .catch(error => {
        console.log('Cart updation error', error);
      })
  }
  placeOrderButtonDisbaled(isPlaceOrderDisabled) {
    if (isPlaceOrderDisabled) {
      const payLoad = { enablePlaceOrder: false };
      publish(this.messageContext, CHECKOUT_CHANNEL, payLoad);
    } else {
      const payLoad = { enablePlaceOrder: true };
      publish(this.messageContext, CHECKOUT_CHANNEL, payLoad);
    }
  }
}

//    //set sessionStorage and localStorage values
//    sessionStorage.setItem('zipcode', JSON.stringify(this.fullAddress))
// //    localStorage.setItem('zipcode', JSON.stringify(this.fullAddress));
// this.map.set('Zipcode', addressComponents[key].long_name);

// if (addressComponents[key].types.includes('locality')) {
//     this.map.set('City', addressComponents[key].long_name);

// if (addressComponents[key].types.includes('administrative_area_level_1')) {
//     this.map.set('State', addressComponents[key].long_name);

// }
// if (addressComponents[key].types.includes('country')) {
//     this.map.set('Country', addressComponents[key].long_name);

// }