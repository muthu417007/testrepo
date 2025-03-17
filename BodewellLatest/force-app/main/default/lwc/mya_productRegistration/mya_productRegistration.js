//*********************************************//
//  Name: Akhil M R
//  Copyright: @ 2022 GE Appliances
//*********************************************
//  Req: Type ahead for model input field
//  EPIC: IDMSF-26
//  STORY: IDMSF-68
//*********************************************
//  Purpose: Product registration
//*********************************************
//  History
//---------------------------------------------
//  Version		Author		Date		Details
//  -------		-------		-------		-------
//  1.0			Akhil M R	07/07/2022 	Created
//*********************************************//

import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// LDS
import { createRecord } from "lightning/uiRecordApi";
// Guest flag
import isGuest from '@salesforce/user/isGuest'; //Srini- Added to check whther logged-in user is guest or not
import USER_ID from '@salesforce/user/Id';
// Templates
import Cafe from "./mya_productRegistration_Cafe.html";
import GEA from "./mya_productRegistration_GEA.html";
import Haier from "./mya_productRegistration_Haier.html";
import Bodewell from "./mya_productRegistration_Bodewell.html"; //for rendering bodewell template
// Apex methods
import getAccountInfo from '@salesforce/apex/MYA_ProductRegistrationController.getAccountInfo';
import registerAssets from '@salesforce/apex/MYA_AccountController.registerAssets';
import createAccount from '@salesforce/apex/Mya_AddressHandler.Mya_AddressValidation';
import getModelNumber from '@salesforce/apex/MYA_ModelRelationController.searchModelNumber';
import publishEmailPayloadForSFMC from '@salesforce/apex/MYA_generateEmailPayloadForSFMC.MYA_Utility_publishEmailPayloadForSFMC';
import publishGuestEmailPayloadForSFMC from '@salesforce/apex/MYA_generateEmailPayloadForSFMC.MYA_Utility_publishGuestEmailPayloadForSFMC';
import endecaInfo from '@salesforce/apex/MYA_EndecaApiHandler.MYA_GetEndecaDetails';
import MYA_EndecaResponseDetails from '@salesforce/apex/MYA_EndecaApiHandler.MYA_EndecaResponseDetails';
import errorLog from '@salesforce/apex/MYA_ApplicationErrorLog.ErrorLog';
import getProductRegistrationConfig from '@salesforce/apex/MYA_ProductRegistrationConfig.getProductRegistrationConfig';
import getSMCData from '@salesforce/apex/MYA_ProductRegistrationConfig.getSMCData';
import userConsentVerification from '@salesforce/apex/MYA_ProductRegistrationController.userConsentVerification';
import checkAssets from '@salesforce/apex/MYA_ProductRegistrationController.checkAssets';
import createContact from '@salesforce/apex/MYA_UserDetailsController.createContact';
import { refreshApex } from '@salesforce/apex';
import SerialNumberPattern from '@salesforce/label/c.Mya_SerialNumberPattern';
import CanadaURL from '@salesforce/label/c.Mya_CanadaURL';
import TrmUrl from '@salesforce/label/c.MYA_TermUrl';
import PrvacyUrl from '@salesforce/label/c.MYA_PrvacyUrl';
import EligibleWaterFilterPartsUrl from '@salesforce/label/c.MYA_EligibleWaterFilterPartsUrl';
import EligibleWaterFilterUTMParameters from '@salesforce/label/c.MYA_eligibleWaterFilterUTMParameter';
import PromoCode from '@salesforce/label/c.MYA_promoCode';
import PromoCodeDiscount from '@salesforce/label/c.MYA_promoCodeDiscount';
import NonEligibleStatesForBodewellServicePlan from '@salesforce/label/c.MYA_NonEligibleStatesForBodewellServicePlan';
// Schema
import CONTACT_POINT_OBJECT from "@salesforce/schema/Contact_Point__c";
import CONTACT_POINT_CONTACT_TYPE from "@salesforce/schema/Contact_Point__c.ContactType__c";
import CONTACT_POINT_IS_PRIMARY from "@salesforce/schema/Contact_Point__c.MYAISPrimary__c";
import CONTACT_POINT_PHONE from "@salesforce/schema/Contact_Point__c.Phone__c";
import CONTACT_POINT_MYA_INCLUDE from "@salesforce/schema/Contact_Point__c.MYA_Included__c";
import CONTACT_POINT_CONTACT_REF from "@salesforce/schema/Contact_Point__c.Contact__c";
// Style loader
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
// Resource Url
import PROUDUCT_IMAGE from '@salesforce/resourceUrl/productimage';
import FLAG_CANADA from '@salesforce/resourceUrl/flagcanada';
import PROGRESS_PROD_INFO from '@salesforce/resourceUrl/cafe_progress_bar_prodinfo';
import PROGRESS_CONT_INFO from '@salesforce/resourceUrl/cafe_progress_bar_contactinfo';
import PROGRESS_COMPLETE from '@salesforce/resourceUrl/cafe_progress_bar_complete';
import MYAGEACSS from '@salesforce/resourceUrl/MYAGEACSS';
import MYACAFECSS from '@salesforce/resourceUrl/MYACAFECSS';
import MYAHAIERCSS from '@salesforce/resourceUrl/MYAHAIERCSS';
import RATE_REVIEW from '@salesforce/resourceUrl/rate_review';
import CAFE_REVIEW from '@salesforce/resourceUrl/review_cafe';
export default class Mya_productRegistration extends NavigationMixin(LightningElement) {
    @api brand = 'GEA';
    @api title = "REGISTER YOUR APPLIANCE";
    @api subtitle = "Enter Your Appliance Information";
    @api contactverification = "VERIFY YOUR CONTACT INFORMATION";
    @api modelno = "Model Number";
    @api serialno = "Serial Number";
    @api installationdate = "Installation Date";
    @api firstNameLabel = "First Name";
    @api lastNameLabel = "Last Name";
    @api primaryPhoneLabel = "Primary Phone";
    @api addressOneLabel = "Address 1";
    @api cityLabel = "City";
    @api stateLabel = "State";
    @api zipcodeLabel = "Zipcode";
    @api emailAddressLabel = "Email Address";
    @api confirmEmailAddressLabel = "Confirm Email Address";
    @api continueButtonLabel = "Continue";
    @api addAnotherProductButtonLabel = "ADD ANOTHER PRODUCT";
    @api importantMessage = "Important: Failure to complete and submit this form does not diminish your warranty rights.";
    @api offerMessage = "When you register your appliance, you're automatically entered for a chance to win ";
    @api offerHighlight = "win $2500!";
    @api officialRulesLink = "See Official Rules for details.";
    @api selectAddressLabel = "Select An Address Where The Appliance Will Be Located.";
    @api selectPhoneLabel = "Select A Phone Number Associated With This Appliance";
    @api reviewInfoLabel = "REVIEW YOUR INFORMATION";
    @api ownerInfoLabel = "OWNER INFORMATION";
    @api productLabel = "PRODUCT";
    @api productInfoModelLabel = "MODEL #";
    @api productInfoSerialLabel = "SERIAL #";
    @api productInfoApplianceLabel = "APPLIANCE";
    @api productInfoInstallDateLabel = "INSTALLATION DATE";
    @api submitRegistartionButtonLabel = "SUBMIT REGISTRATION";
    @api editRegistrationLinkLabel = "EDIT REGISTRATION";
    @api viewYourAccountButtonLabel = "VIEW YOUR ACCOUNT";
    @api registerAnotherProductLabel = "REGISTER ANOTHER ACCOUNT";
    @api thankYouLabel = "Thank You For Registering Your Appliance.";
    @api offerClaimLabel = "You have been entered for a chance to win $2500 in our monthly sweepstakes.";
    @api whereIsMyModelNumberLink = "https://www.geappliances.com/ge/find-model-serial-number";
    @api overLimitValidationMessage = 'You have reached the maximum number of products you can register at one time.';
    @api consentValidationMessage = 'You must check the box to continue.';
    @api unknownBrandCode = 'UNK';
    @api unknownProductLineCode = '991';
    @api name;
    @api nickName;
    @api firstName;
    @api lastName;
    @api primaryPhone;
    @api address1;
    @api billingcity;
    @api billingstate;
    @api billingstreet;
    @api postalcode;
    @api accountId;
    @api email;
    @api confirmEmail;
    @api phone;
    @track txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click  search-input';
    @track instDate;
    eligibleWaterFilterPartsUrl = EligibleWaterFilterPartsUrl;
    eligibleWaterFilterUTMParameters = EligibleWaterFilterUTMParameters;
    nonEligibleStatesForBodewellServicePlan = NonEligibleStatesForBodewellServicePlan;
    wireContactResult;
    loggedUser;
    contact;
    wiredphone;
    eligibleAppliance;
    promoCodeDiscount = PromoCodeDiscount;
    productimage = PROUDUCT_IMAGE;
    flagcanada = FLAG_CANADA;
    prodInfo = PROGRESS_PROD_INFO;
    contactInfo = PROGRESS_CONT_INFO;
    complete = PROGRESS_COMPLETE;
    ratereview = RATE_REVIEW;
    ratereviewcafe = CAFE_REVIEW;
    showproductform = true;
    showaddressform = false;
    showproductdetail = false;
    showregisteredproduct = false;
    disableAddress = false;
    disablePhone = false;
    formInvalid = true;
    phoneAlreadyExist = false;
    isAddModalOpen = false;
    isAddAddress = false;
    isAddPhone = false;
    emailMismatch = false;
    consentApproved = false;
    consentValidation = false;
    editRegistartion = false;
    modelnumberValidation = false;
    stateValidation = false;
    isLoading = false;
    storedaddress;
    storedphone;
    displayaddress;
    selectedaddress;
    selectedphone;
    addressOptionList;
    phoneOptionList;
    productContactInfo;
    isReachMaxProduct = false;
    waterFilterImage;
    // serialNumberPattern = '.{5,}$';
    serialNumberPattern = SerialNumberPattern;
    serialNumberValidationMessage = 'Please enter a valid serial number';
    phonePattern = '[0-9]{3}-[0-9]{3}-[0-9]{4}|[0-9]{10}$';
    phonePatternValidationMessage = 'Please Enter a valid 10 Digit Phone Number';
    emailPattern = '[A-Za-z0-9._+-]+@[a-z0-9-]+.[a-z]{2,}$';
    emailPatternValidationMessage = 'Please enter a valid email';
    modelNumberPatternValidationMessage = 'Please enter valid model number';
    serialNumberPatternValidationMessage = 'Please enter valid serial number';
    zipCodePattern = '[0-9]{5}$';
    // cityPattern = '^[A-Za-z ]+$'
    // addressFieldPattern = '[^()/><\][\\\x22,;|]+';
    zipCodePatternValidationMessage = 'Please enter a valid zip code';
    addressFieldPattern = '^[a-zA-Z0-9 ]+$';
    addressPatternValidationMessage = 'Special characters are not allowed.';
    checkboxValueMissingmessage = 'You must check the box to continue.'
    assurantServiceLink = '';
    assurantServiceLinkParams = '';
    assurantServiceLinkEndParameters = '';
    assurantServiceLinkVisible = false;
    productConfigData;
    reviewLinks;
    review_link;
    accountResponse;
    contactLocationResponse;
    geaAssetResponse;
    endecaResponse;
    modelNumFromQR;
    serialNumFromQR;
    modelNumberLookUp;
    previousSearchTerm;
    newAccountId;
    itemsAlreayExistValidation;
    itemsAlreayExistValidationMessage;
    smcConfigs;
    qrLink = '';
    // Wire Result
    wireFilterbyAccountResult;
    wireContactPointsResult;
    // Guest flag
    isGuestUser = isGuest;
    today = new Date().toString();
    date = new Date();
    currentDate = this.date.getDate() < 10 ? '0' + this.date.getDate() : this.date.getDate();
    currentMonth = this.date.getMonth() + 1;
    currentYear = this.date.getFullYear();
    //currentDateString = this.currentYear + '-' + this.currentMonth + '-' + this.currentDate;
    currentDateString = '';
    trmUrl = TrmUrl;
    prvacyUrl = PrvacyUrl;
    
    // list for manage multiple products
    @track productList = [{
        key: 1,
        modelNumber: '',
        serialNumber: '',
        installDate: this.currentDateString,
        isRemovable: false,
        isQRProductModelNumber: false,
        isQRProductSerialNumber: false,
        isValidModelNumber: false,
        bvurl: '',
        imageUrl: '',
        description: '',
        brand: '',
        marketingModelNumber: '',
        isAlreadyExist: false
    }];

    get isAddressRequired() {
        if (this.disableAddress) {
            return false;
        }
        return true;
    };

    get isPhoneRequired() {
        if (this.disablePhone) {
            return false;
        }
        return true;
    };

    get getMaximumCountReachMessage() {
        if (this.isReachMaxProduct) {
            return this.overLimitValidationMessage;
        }
        return '';
    }
    // for Canadian url navigation
    canadaURL = CanadaURL;
    appliancesHandler() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.canadaURL
            }
        })
    }


    // CSS loader function
    renderedCallback() {
        if (this.brand == "GEA") {
            // Promise.all([
            //     loadStyle(this, MYAGEACSS + '/MYAGEACSS/mya_productRegistration_GEA.css')
            // ]);
        } else if (this.brand == "Haier") {
            // Promise.all([
            //     loadStyle(this, MYAHAIERCSS + '/MYAHAIERCSS/mya_productRegistration_Haier.css')
            // ]);
        } else if (this.brand == "Café") {
            // Promise.all([
            //     loadStyle(this, MYACAFECSS + '/MYACAFECSS/mya_productRegistration_Cafe.css')
            // ]);
        }
        if (this.showaddressform && this.editRegistartion) {
            this.setEditValues();
        }
    }
    // UI render based on brand and user status
    render() {
        if (this.brand == "GEA") {
            return GEA;
        } else if (this.brand == "Haier") {
            return Haier;
        } else if (this.brand == "Cafe") {
           return Cafe;
        }  else if (this.brand == "Bodewell") {  //for bodewell template
            console.log("Bodewell template rendered");
            return Bodewell; //bodewell html
         } // end of bodewell 
    }
    connectedCallBack() {
        this.fetchDataSourceCode();

    }
    fetchDataSourceCode() {
        getProductRegistrationConfig({ isGuestUser: this.isGuestUser })
            .then(result => {
                if (result.data && result.data.Success) {
                    // this.reviewLinks = result.data.ReviewLinks.filter(link => link.Brand == this.brand)[0];
                    this.reviewLinks = result.data.ReviewLinks;
                    this.assurantServiceLink = result.data.AssurantSiteConfig.Endpoint;
                    this.assurantServiceLinkEndParameters = result.data.AssurantSiteConfig.End_Parameters;
                    this.productConfigData = result.data;
                    if (this.brand == "GEA") {
                        this.assurantServiceLinkParams = '?type=GEA&';
                    } else if (this.brand == "Haier") {
                        this.assurantServiceLinkParams = '?type=Haier&';
                    } else if (this.brand == "Cafe") {
                        this.assurantServiceLinkParams = '?type=Cafe&';
                    }
                    this.assurantServiceLink = this.assurantServiceLink + this.assurantServiceLinkParams;
                } else if (result.error) {
                    this.error = result.error;
                }

            })
            .catch(error => {
                console.error('data source code :', error);
            });
    }
    //QR code redirection
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {

        if (currentPageReference) {
            this.modelNumFromQR = currentPageReference.state.model;
            this.serialNumFromQR = currentPageReference.state.serial;
            if (this.modelNumFromQR || this.serialNumFromQR) {
                let product = [{
                    key: 1,
                    modelNumber: this.modelNumFromQR ? this.modelNumFromQR : '',
                    marketingModelNumber: this.modelNumFromQR ? this.modelNumFromQR : '',
                    serialNumber: this.serialNumFromQR ? this.serialNumFromQR : '',
                    installDate: this.currentDateString,
                    isRemovable: false,
                    isQRProductModelNumber: this.modelNumFromQR ? true : false,
                    isQRProductSerialNumber: this.serialNumFromQR ? true : false
                }];

                this.productList = product;
                console.log('product list line 332',this.productList);
                if (localStorage.getItem('qrLink')) {
                    this.qrLink = JSON.parse(localStorage.getItem('qrLink'));
                }

                getModelNumber({ Value: this.productList[0].modelNumber })
                    .then(result => {
                        if (result.length > 0) {
                            let clickedItem = this.productList.find((item) => item.key == this.productList[0].key);
                            clickedItem.marketingModelNumber = result[0].MR_PKMOD__c;
                            console.log('get model number',clickedItem.marketingModelNumber);
                        }
                    })
                    .catch(error => {
                        console.error('Error on GetModelNumber: ', error);
                    });
            } else {
                if (localStorage.getItem('qrLink')) {
                    localStorage.removeItem('qrLink');
                }
            }
        } else {
            if (localStorage.getItem('qrLink')) {
                localStorage.removeItem('qrLink');
            }
        }
    }
    // Get existing address info
    @wire(getAccountInfo, { UserId: USER_ID })
    address(result) {
        console.log('this.wireFilterbyAccountResult',result);
        this.wireFilterbyAccountResult = result;
        console.log('this.wireFilterbyAccountResult',this.wireFilterbyAccountResult);
        if (result.data) {
            try {
                let response = result.data;
                if (response.Success) {
                    //Contact info
                    this.loggedUser = response.ContactDetails;

                    // Address info
                    let addressData = response.AddressList.filter(item => item.BillingStreet);
                    this.storedaddress = addressData;
                    let options = [];
                    if (this.brand != "Cafe") {
                        options = [{ label: 'Enter New Address Below', value: '' }];
                    }
                    if (addressData.length > 0) {
                        for (var key in addressData) {
                            if (key != '') {
                                options.push({ label: addressData[key].BillingStreet, value: addressData[key].Id });
                            }
                        }
                    }
                    this.addressOptionList = options;
                    // Phone info
                    let contactPointsData = response.ContactPoints;
                    this.storedphone = contactPointsData;
                    let phoneoptions = [];
                    if (this.brand != "Cafe") {
                        phoneoptions = [{ label: 'Enter New Phone Below', value: '' }];
                    }
                    if (contactPointsData.length > 0) {
                        for (var key in contactPointsData) {
                            if (key != '') {
                                let match = contactPointsData[key].Phone__c ? contactPointsData[key].Phone__c.match(/^(\d{3})(\d{3})(\d{4})$/) : null ;
                                if (match) {
                                    phoneoptions.push({ label: match[1] + '-' + match[2] + '-' + match[3], value: contactPointsData[key].Id });
                                }
                            }
                        }
                    }
                    this.phoneOptionList = phoneoptions;
                }

            } catch (error) {
                console.error('check error here', error);
            }
        } else if (result.error) {
            console.error('check error here', result.error);
        }
    }

    //Get ProductRegistration Config
    @wire(getProductRegistrationConfig, { isGuestUser: '$isGuestUser' })
    wiredProductRegistrationConfig(result) {
        if (result.data && result.data.Success) {
            // this.reviewLinks = result.data.ReviewLinks.filter(link => link.Brand == this.brand)[0];
            this.reviewLinks = result.data.ReviewLinks;
            console.log('this.reviewLinks test ', this.reviewLinks);
            this.assurantServiceLink = result.data.AssurantSiteConfig.Endpoint;
            this.assurantServiceLinkEndParameters = result.data.AssurantSiteConfig.End_Parameters;
            this.productConfigData = result.data;
            if (this.brand == "GEA") {
                this.assurantServiceLinkParams = '?type=GEA&';
            } else if (this.brand == "Haier") {
                this.assurantServiceLinkParams = '?type=Haier&';
            } else if (this.brand == "Cafe") {
                this.assurantServiceLinkParams = '?type=Cafe&';
            } 
            this.assurantServiceLink = this.assurantServiceLink + this.assurantServiceLinkParams;
        } else if (result.error) {
            this.error = result.error;
        }
    }

    // Custom validation method for validate class fields
    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                isValid = false;
            }
            inputField.reportValidity();
        });
        let isStateValid = this.isStateInputValid();
        isValid = isValid ? isStateValid : isValid;
        return isValid;
    }
    showapromoform = false;
    isPromoEligibleState = true;
    closemodal() {
        this.showapromoform = false;
    }
    filterModelNo;
    filterPromoCode = PromoCode;
    fetchPartsImage() {
        MYA_EndecaResponseDetails({ SKU: this.filterModelNo }) //call endeca function to get product details
            .then((res) => {
                if (res) {
                    this.waterFilterImage = res.ProductInfo.DefaultImageUrl;
                }
            }).catch((error) => {
                console.error('Product Details: ', error);
            });
    }

    handleWaterFilterRedirect() {
        this.showapromoform = false;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: EligibleWaterFilterPartsUrl
                    + '?FREQUENCY=0&UPDATEID=4&CATEGORY=&PRICE=0.0&SMTORITEMID=&QUANTITY=1&dealCode='
                    + this.filterPromoCode
                    + '&promocode=&ISKIT=&KITITEMIDS=&ITEM='
                    + this.filterModelNo
                    + this.eligibleWaterFilterUTMParameters
            }
        })
    }

    isSelectedInputValid(field) {
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if (inputField.name == field) {
                inputField.reportValidity();
            }
        });
    }

    dateValidation = false;
    dateValidationMessage = '';
    isInstallDateValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.date-validate');
        inputFields.forEach(inputField => {
            let inputDate = new Date(inputField.value); //dd-mm-YYYY
            let today = new Date();
            if (!inputField.value || inputField == '') {
                this.dateValidation = true;
                this.dateValidationMessage = 'Please select a valid date.';
                inputField.parentElement.classList.add("slds-has-error");
                isValid = false;
            }
            else if (inputDate >= today) {
                this.dateValidation = true;
                this.dateValidationMessage = 'Please select a valid date.';
                inputField.parentElement.classList.add("slds-has-error");
                isValid = false;
            } else {
                this.dateValidation = false;
                inputField.parentElement.classList.remove("slds-has-error");
            }
        });
        return isValid;
    }


    isStateInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validateState');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                // if (inputField.name == 'state') {
                this.stateValidation = true;
                inputField.parentElement.classList.add("slds-has-error");
                // } else {
                //inputField.reportValidity();
                // }
                isValid = false;
            } else {
                // if (inputField.name == 'state') {
                this.stateValidation = false;
                inputField.parentElement.classList.remove("slds-has-error");
                // }
            }
        });
        return isValid;
    }
    // Product list value change
    handleProductListChange(e) {

        if (e.target.name === "modelno") {
            let clickedSec = e.currentTarget.dataset.id;
            let clickedItem = this.productList.find((item) => item.key == parseInt(clickedSec));
            clickedItem.modelNumber = e.target.value;
            clickedItem.modelNumber = clickedItem.modelNumber.toUpperCase();
            console.log('clickedItem.modelNumber line 552',clickedItem.modelNumber);
            clickedItem.marketingModelNumber = e.target.value;
            let modelNumber = e.target.value;
            modelNumber = modelNumber.toUpperCase();
            if (modelNumber.length > 4) {
                if (this.previousSearchTerm && modelNumber.startsWith(this.previousSearchTerm)) {
                    clickedItem.searchRecords = this.modelNumberLookUp.filter(el => (el.MN__c.indexOf(modelNumber)) > -1);
                    if (clickedItem.searchRecords.length > 0) {
                        clickedItem.showTypeAhead = true;
                        clickedItem.isValidManufacturingModel = true;
                    } else {
                        clickedItem.showTypeAhead = false;
                        clickedItem.isValidManufacturingModel = false;
                    }
                    this.txtclassname = clickedItem.searchRecords.length > 0 ? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open  search-input' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click  search-input';
                } else {
                    this.previousSearchTerm = modelNumber;
                    getModelNumber({ Value: modelNumber })
                        .then(result => {
                            this.modelNumberLookUp = result;
                            clickedItem.searchRecords = result;
                            if (clickedItem.searchRecords.length > 0) {
                                clickedItem.showTypeAhead = true;
                                clickedItem.isValidManufacturingModel = true;
                            } else {
                                clickedItem.showTypeAhead = false;
                                clickedItem.isValidManufacturingModel = false;
                            }
                            this.txtclassname = clickedItem.searchRecords.length > 0 ? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open  search-input' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click  search-input';
                        })
                        .catch(error => {
                            console.error('Error on GetModelNumber: ', error);
                        });
                }
            } else {
                clickedItem.searchRecords = [];
                clickedItem.showTypeAhead = false;
                this.previousSearchTerm = null;
                this.modelNumberLookUp = [];
            }
        } else if (e.target.name === "serialno") {
            let clickedSec = e.currentTarget.dataset.id;
            let clickedItem = this.productList.find((item) => item.key == parseInt(clickedSec));
            clickedItem.serialNumber = e.target.value;
            clickedItem.serialNumber = clickedItem.serialNumber.toUpperCase();

        } else if (e.target.name === "installationdate") {
            let clickedSec = e.currentTarget.dataset.id;
            let clickedItem = this.productList.find((item) => item.key == parseInt(clickedSec));
            clickedItem.installDate = e.target.value;
            this.isInstallDateValid();
        }
        this.isSelectedInputValid(e.target.name);
    }
    // Remove product from list
    handleRemoveAnotherProduct(event) {
        this.productList = this.productList.filter((item) => item.key !== parseInt(event.target.dataset.id));
        if (this.productList.length < 9) {
            this.isReachMaxProduct = false;
        }
    }
    // Add new product into list
    handleAddAnotherProduct() {
        if (this.productList.length >= 9) {
            this.isReachMaxProduct = true;
        }
        if (this.productList.length < 9) {
            let newKey = (this.productList.length > 0) ? (this.productList[this.productList.length - 1].key + 1) : 1;
            let product = {
                key: newKey,
                modelNumber: '',
                serialNumber: '',
                installDate: this.currentDateString,
                isRemovable: true,
                isQRProductModelNumber: false,
                isQRProductSerialNumber: false,
                isValidModelNumber: false,
                marketingModelNumber: '',
                isAlreadyExist: false
            };
            this.productList.push(product);
        }
    }

    checkMobileDevice() {
        let check = false;
        (function (a) { if (/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino|android|ipad|playbook|silk/i.test(a) || /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0, 4))) check = true; })(navigator.userAgent || navigator.vendor || window.opera);
        return check;
    }


    // Contine button click after entered all product data
    handleContinue() {
        try {
            var invalid = false;
            var isMobile = false;
            if (!this.isInputValid()) {
                invalid = true;
            }
            if (this.checkMobileDevice()) {
                isMobile = true;
            }
            if (!this.isInstallDateValid()) {
                invalid = true;
            }
            if (invalid == false) {
                if (this.isGuestUser) {
                    this.showproductform = false;
                    this.showaddressform = true;
                    // this.showapromoform = true;
                    window.scrollTo(0, parseInt(scrollY || '0') * -1);
                    this.getEndecaInfo(this.productList);
                    this.productRegistrationEventHandler(this.productList, 1);
                } else {
                    this.productList.forEach(elmt => {
                        elmt.isAlreadyExist = false;
                    });
                    this.showproductform = false;
                    this.showaddressform = true;
                    // this.showapromoform = true;
                    window.scrollTo(0, parseInt(scrollY || '0') * -1);
                    this.getEndecaInfo(this.productList);
                    this.productRegistrationEventHandler(this.productList, 1);
                }
            }
        } catch (e) {
            console.error("An error occurred: ", e); //This will not be executed
        }
    }
    // Check asset already exist in account
    assetCheck(accountId) {
        this.itemsAlreayExistValidation = false;
        let inputs = [];
        if (this.productList.length > 0) {
            this.productList.forEach((item) => {
                inputs.push({ ModelNumber: item.modelNumber, SerialNumber: item.serialNumber });
            });
        }
        checkAssets({ AssetInputs: inputs, AccountId: accountId })
            .then(result => {
                if (result.Success && result.ItemsAlreayExist) {
                    result.Assets.forEach((item) => {
                        if (item.AlreadyExist) {
                            let clickedItem = this.productList.find((prod) => prod.modelNumber == item.ModelNumber && prod.serialNumber == item.SerialNumber);
                            if (clickedItem) {
                                clickedItem.isAlreadyExist = true;
                            }
                        } else {
                            let clickedItem = this.productList.find((prod) => prod.modelNumber == item.ModelNumber && prod.serialNumber == item.SerialNumber);
                            if (clickedItem) {
                                clickedItem.isAlreadyExist = false;
                            }
                        }
                    });
                    this.itemsAlreayExistValidation = true;
                    this.isLoading = false;
                } else if (result.Success) {
                    this.isLoading = false;
                } else {
                    console.error('checkAssets: ', result);
                    this.isLoading = false;
                }
                this.showproductdetail = true;
                this.showaddressform = false;
                window.scrollTo(0, parseInt(scrollY || '0') * -1);
                this.productRegistrationEventHandler(this.productList, 2);
            })
            .catch(error => {
                this.error = error;
                console.error('checkAssets: ', error);
                this.isLoading = false;
            });
    }

    // Address dropdown value change
    handleAddressValueChange(event) {
        if (event.target.value != '') {
            this.selectedaddress = this.storedaddress.filter(item => item.Id == event.target.value)[0];
            this.disableAddress = true;
            // Revalidate address fields
            Promise.resolve().then(() => {
                let inputFields = this.template.querySelectorAll('.validate');
                inputFields.forEach(inputField => {
                    inputField.reportValidity();
                });
            });
        } else {
            this.selectedaddress = null;
            this.disableAddress = false;
        }
    }
    // Phone dropdown value change
    handlePhoneValueChange(event) {
        if (event.target.value != '') {
            this.phoneAlreadyExist = false;
            this.selectedphone = this.storedphone.filter(item => item.Id == event.target.value)[0];
            this.disablePhone = true;
            // Revalidate phone number field
            Promise.resolve().then(() => {
                let inputFields = this.template.querySelectorAll('.phone-validate');
                inputFields.forEach(inputField => {
                    inputField.reportValidity();
                });
            });
        } else {
            this.selectedphone = null;
            this.disablePhone = false;
        }
    }

    // Contact info input value change
    handleContactInputChange(e) {
        if (e.target.name === "name") {
            this.name = e.target.value;
            this.isSelectedInputValid(e.target.name);
        } else if (e.target.name === "nickName") {
            this.nickName = e.target.value;
        } else if (e.target.name === "firstName") {
            this.firstName = e.target.value;
            this.isSelectedInputValid(e.target.name);
        } else if (e.target.name === "lastName") {
            this.lastName = e.target.value;
            this.isSelectedInputValid(e.target.name);
        } else if (e.target.name === "primaryPhone") {
            this.primaryPhone = e.target.value;
            this.isNewPhoneValid();
        } else if (e.target.name === "address1") {
            this.billingStreet = e.target.value;
            this.isSelectedInputValid(e.target.name);
        } else if (e.target.name === "city") {
            this.billingcity = e.target.value;
            this.isSelectedInputValid(e.target.name);
        } else if (e.target.name === "state") {
            this.billingstate = e.target.value;
            this.isStateInputValid();
        } else if (e.target.name === "zipcode") {
            this.billingPostalCode = e.target.value;
            this.isSelectedInputValid(e.target.name);
        } else if (e.target.name === "phone") {
            
            this.billingPhone = e.target.value;
            if (this.isNewPhoneValid()) {
                let phone = ('' + this.billingPhone).replace(/\D/g, '');
                let duplicate = this.storedphone.filter(el => el.Phone__c == phone);
                console.log("duplicate",duplicate);
                if (duplicate.length == 0) {
                    this.phoneAlreadyExist = false;
                } else {
                    this.phoneAlreadyExist = true;
                }
            }
        } else if (e.target.name === "email") {
            this.email = e.target.value;
            this.emailMismatch = false;
            if (this.email != this.confirmEmail) {
                this.emailMismatch = true;
            }
            this.isSelectedInputValid(e.target.name);
        } else if (e.target.name === "confirmEmail") {
            this.confirmEmail = e.target.value;
            this.emailMismatch = false;
            if (this.email != this.confirmEmail) {
                this.emailMismatch = true;
            }
            this.isSelectedInputValid(e.target.name);
        }
    }
    // Validation for phone input
    isNewPhoneValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.phone-validate');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }
    // Open modal for add new address or phone
    openAddModalOpen(event) {
        this.isAddModalOpen = true;
        if (event.target.dataset.id == '1') {
            this.isAddAddress = true;
        } else {
            this.isAddPhone = true;
        }
    }
    // Close modal
    closeAddModalOpen(event) {
        this.isAddModalOpen = false;
        this.isAddAddress = false;
        this.isAddPhone = false;
    }
    // Save new address
    handleSaveAddress(event) {
        if (this.isInputValid()) {
            let inputDetails = {
                'Address': this.billingStreet,
                'City': this.billingcity,
                'State': this.billingstate,
                'Code': this.billingPostalCode,
                'Primary': false,
                'NickName': this.name
            }
            createAccount(inputDetails)
                .then(result => {
                    if (result) {
                        this.closeAddModalOpen();
                        return refreshApex(this.wireFilterbyAccountResult);
                    } else {
                        console.error('Error response on account creation: ', result);
                        this.closeAddModalOpen();
                    }
                })
                .catch(error => {
                    this.error = error;
                    console.error('Error occured on account creation: ', error);
                    this.closeAddModalOpen();
                });
        }
    }
    // Save new phone
    handleAddPhoneSave(event) {
        if (this.isNewPhoneValid()) {
            let phone = ('' + this.billingPhone).replace(/\D/g, '');
            let duplicate = this.storedphone.filter(el => el.Phone__c == phone);
            if (duplicate.length == 0) {
                this.phoneAlreadyExist = false;
                let input = {
                    contactId: this.loggedUser.Id,
                    phone: phone,
                    isPrimary: false
                };
                createContact(input)
                    .then(result => {
                        this.isLoading = false;
                        this.closeAddModalOpen();
                        return refreshApex(this.wireFilterbyAccountResult);
                    }).catch(error => {
                        console.error('create contact error :', error);
                    });
            } else {
                this.phoneAlreadyExist = true;
                this.isLoading = false;
            }
        }
    }
    // Edit registration link click
    handleEditRegistration() {
        this.editRegistartion = true;
        this.showproductdetail = false;
        this.showproductform = true;
    }
    //
    setEditValues() {
        if (this.disableAddress && !this.isGuestUser && this.selectedaddress) {
            const addressSelect = this.template.querySelector('.address-select');
            if (addressSelect) {
                addressSelect.value = this.selectedaddress.Id;
            }
        }
        if (!this.disableAddress && !this.isGuestUser) {
            const addressNickname = this.template.querySelector('.address-nickname');
            if (addressNickname) {
                addressNickname.value = this.name;
            }
        }
        if (!this.disableAddress && this.isGuestUser) {
            const firstNameInput = this.template.querySelector('.firstname-input');
            if (firstNameInput) {
                firstNameInput.value = this.firstName;
            }
        }
        if (!this.disableAddress && this.isGuestUser) {
            const lastNameInput = this.template.querySelector('.lastname-input');
            if (lastNameInput) {
                lastNameInput.value = this.lastName;
            }
        }
        if (!this.disableAddress && this.isGuestUser) {
            const primaryPhoneInput = this.template.querySelector('.primaryphone-input');
            if (primaryPhoneInput) {
                primaryPhoneInput.value = this.primaryPhone;
            }
        }
        if (!this.disableAddress) {
            const addressInput = this.template.querySelector('.addres-input');
            if (addressInput) {
                addressInput.value = this.billingStreet;
            }
        }
        if (!this.disableAddress) {
            const cityInput = this.template.querySelector('.city-input');
            if (cityInput) {
                cityInput.value = this.billingcity;
            }
        }
        if (!this.disableAddress) {
            const stateInput = this.template.querySelector('.state-input');
            if (stateInput) {
                stateInput.value = this.billingstate;
            }
        }
        if (!this.disableAddress) {
            const zipInput = this.template.querySelector('.zip-input');
            if (zipInput) {
                zipInput.value = this.billingPostalCode;
            }
        }
        if (!this.disableAddress && this.isGuestUser) {
            const emailInput = this.template.querySelector('.email-input');
            if (emailInput) {
                emailInput.value = this.email;
            }
        }
        if (!this.disableAddress && this.isGuestUser) {
            const confirmEmailInput = this.template.querySelector('.confirm-email-input');
            if (confirmEmailInput) {
                confirmEmailInput.value = this.confirmEmail;
            }
        }
        if (this.disablePhone && !this.isGuestUser && this.selectedphone) {
            const phoneSelect = this.template.querySelector('.phone-select');
            if (phoneSelect) {
                phoneSelect.value = this.selectedphone.Id;
            }
        }
        if (!this.disablePhone && !this.isGuestUser && this.productContactInfo) {
            const inputContact = this.template.querySelector('.contact-phone');
            if (inputContact) {
                inputContact.value = this.billingPhone;
            }
        }
        if (this.consentApproved) {
            const consentCheck = this.template.querySelector('.consent-check');
            if (consentCheck) {
                consentCheck.checked = this.consentApproved;
            }
           
        }
    }
    // Contact info submit event
    handleSuccess() {
        if (!this.consentApproved ) {
            this.consentValidation = true;
            this.template.querySelector('.consent-check').classList.add('slds-has-error');
            return;
        }
        if (this.emailMismatch) {
            return;
        }
        
        let isSuccess = true;
        this.phoneAlreadyExist = false;
        if (this.isGuestUser) {
            if (this.isInputValid()) {
                this.productContactInfo = {
                    name: this.firstName + ' ' + this.lastName,
                    firstName: this.firstName,
                    lastName: this.lastName,
                    accountId: null,
                    street: this.billingStreet,
                    city: this.billingcity,
                    state: this.billingstate,
                    zipCode: this.billingPostalCode,
                    email: this.email,
                    phoneId: null,
                    phone: ''
                }
            } else {
                isSuccess = false;
            }

            if (isSuccess && this.isNewPhoneValid()) {
                let phone = ('' + this.primaryPhone).replace(/\D/g, '');
                this.productContactInfo.phone = phone;
            } else {
                isSuccess = false;
            }
        } else {
            if (this.disableAddress) {
                if (!this.selectedaddress) {
                    return;
                }
                this.productContactInfo = {
                    name: this.loggedUser.Name,
                    firstName: this.loggedUser.FirstName,
                    lastName: this.loggedUser.LastName,
                    accountId: this.selectedaddress.Id,
                    street: this.selectedaddress.BillingStreet,
                    city: this.selectedaddress.BillingCity,
                    state: this.selectedaddress.BillingState,
                    zipCode: this.selectedaddress.BillingPostalCode,
                    phoneId: null,
                    phone: '',
                    email: this.loggedUser.Email
                }
            } else {
                if (isSuccess && this.isInputValid()) {
                    this.productContactInfo = {
                        name: this.loggedUser.Name,
                        firstName: this.loggedUser.FirstName,
                        lastName: this.loggedUser.LastName,
                        accountId: null,
                        street: this.billingStreet,
                        city: this.billingcity,
                        state: this.billingstate,
                        zipCode: this.billingPostalCode,
                        phoneId: null,
                        phone: '',
                        email: this.loggedUser.Email
                    }
                } else {
                    isSuccess = false;
                }
            }
            if (isSuccess && this.disablePhone) {
                if (!this.selectedphone) {
                    return;
                }
                this.productContactInfo.phone = this.selectedphone.Phone__c;
                this.productContactInfo.phoneId = this.selectedphone.Id;
            } else {
                if (isSuccess && this.isNewPhoneValid()) {
                    let phone = ('' + this.billingPhone).replace(/\D/g, '');
                    let duplicate = this.storedphone.filter(el => el.Phone__c == phone);
                    if (duplicate.length == 0) {
                        this.productContactInfo.phone = phone;
                    } else {
                        this.phoneAlreadyExist = true;
                        isSuccess = false;
                    }
                } else {
                    isSuccess = false;
                }
            }
        }
        if (isSuccess) {
            if (this.isGuestUser) {
                let keys = [];
                if (this.productList.length > 0) {
                    this.productList.forEach((item) => {
                        keys.push(item.modelNumber);
                    });
                }
                if (keys.length > 0) {
                    getSMCData({ modelNumbers: keys })
                        .then(result => {
                            if (result.Success) {
                                this.smcConfigs = result.SMCConfigList;
                            }
                            this.showproductdetail = true;
                            this.showaddressform = false;
                            window.scrollTo(0, parseInt(scrollY || '0') * -1);
                            this.productRegistrationEventHandler(this.productList, 2);
                        })
                        .catch(error => {
                            this.error = error;
                            console.error('getSMCData: ', this.error);
                        });
                }

            } else {
                this.isLoading = true;
                if (this.disableAddress) {
                    this.assetCheck(this.selectedaddress.Id);
                } else {
                    let inputDetails = {
                        'Address': this.productContactInfo.street,
                        'City': this.productContactInfo.city,
                        'State': this.productContactInfo.state,
                        'Code': this.productContactInfo.zipCode,
                        'Primary': false,
                        'NickName': this.name
                    }
                    createAccount(inputDetails)
                        .then(result => {
                            if (result.Id) {
                                this.newAccountId = result.Id;
                                this.productContactInfo.street = result.BillingStreet;
                                this.productContactInfo.city = result.BillingCity;
                                this.productContactInfo.state = result.BillingState;
                                this.productContactInfo.zipCode = result.BillingPostalCode;
                                this.assetCheck(this.newAccountId);
                            } else {
                                this.errorToast('Address creation failed. Pease check your address.');
                                this.isLoading = false;
                            }
                        })
                        .catch(error => {
                            this.error = error;
                            console.error('createAccount: ', error);
                            this.errorToast('Address creation failed.');
                            this.isLoading = false;
                        });
                }
            }
        }
    }
    // Product registartion submit event. This event save product data into DB.
    handleSubmit() {
        if (this.isGuestUser) {
            this.guestProductRegistration();
        } else if (this.itemsAlreayExistValidation && this.productList.length > 1) {
            this.itemsAlreayExistValidationMessage = 'Products already registered.';
            return;
        } else if (this.itemsAlreayExistValidation && this.productList.length == 1) {
            this.itemsAlreayExistValidationMessage = 'Product already registered.';
            return;
        } else {
            this.loggedUserProductRegistration();
        }
    }
    // guest user product registration
    guestProductRegistration() {
        this.isLoading = true;
        let nonEligibleStates = this.nonEligibleStatesForBodewellServicePlan.split(';');
        if (nonEligibleStates.indexOf(this.productContactInfo.state) !== -1) {
            this.isPromoEligibleState = false;
        }
        
        let count = 1;
        //let payload = this.setGuestEmailPayload(this.productList, this.productContactInfo);
        this.productList.forEach((item) => {
            let modelNumberKey = item.modelNumber;
            let productConfigs = this.smcConfigs.filter(con => con.Model == modelNumberKey)[0];
            let isFound = false;
            item.brandCode = this.unknownBrandCode;
            item.productLineCode = this.unknownProductLineCode;
            do {
                let config = productConfigs.SMCDataList.filter(data => data.Model_No__c == modelNumberKey);
                if (config.length > 0) {
                    item.brandCode = config[0].Brand_Code__c;
                    item.productLineCode = config[0].Product_Line_Code__c;
                    isFound = true;
                } else {
                    modelNumberKey = modelNumberKey.substring(0, modelNumberKey.length - 1);
                }
            } while (!isFound && modelNumberKey.length > 2);
            var webconsumerinfofields = {
                'Model_number__c': item.modelNumber,
                'Serial_Number__c': item.serialNumber,
                'Install_date__c': item.installDate,
                'Name': this.productContactInfo.firstName,
                'Last_Name__c': this.productContactInfo.lastName,
                'Email_Address__c': this.productContactInfo.email,
                'Phone_Number__c': this.productContactInfo.phone,
                'Billing_Street__c': this.productContactInfo.street,
                'Billing_City__c': this.productContactInfo.city,
                'Billing_State__c': this.productContactInfo.state,
                'Billing_Zip_Prefix__c': this.productContactInfo.zipCode,
                'Data_Source_Code__c': item.dataSourceCode,
                'Product_line_Code__c': item.productLineCode ? item.productLineCode : '',
                'Brand_Code__c': item.brandCode ? item.brandCode : '',
                'Mobile_QR_Link__c': this.qrLink.url,
                'Is_Error__c': !item.isValidModelNumber
            };
            var webconsumerinfoRecordInput = { 'apiName': 'WebConsumerInfo__c', fields: webconsumerinfofields };
            createRecord(webconsumerinfoRecordInput)
                .then(record => {
                    if (count == this.productList.length) {
                        this.setAssurantLink(this.productList);// CCOE-1084
                        let payload = this.setGuestEmailPayload(this.productList, this.productContactInfo); // CCOE-1084
                        this.guestEmailPayloadPublish(payload);
                        this.productRegistrationEventHandler(this.productList, 3);
                        this.showregisteredproduct = true;
                        this.showproductdetail = false;
                        window.scrollTo(0, parseInt(scrollY || '0') * -1);
                        this.productRegistrationEventHandler(this.productList, 4);
                        this.isLoading = false;
                        console.log('Guest Product Registration Success');
                    } else {
                        count++;
                    }
                })
                .catch(error => {
                    if (this.isGuestUser && error.body.statusCode == 404) {

                        if (count == this.productList.length) {
                            this.setAssurantLink(this.productList);// CCOE-1084
                            let payload = this.setGuestEmailPayload(this.productList, this.productContactInfo); // CCOE-1084
                            this.guestEmailPayloadPublish(payload);
                            this.productRegistrationEventHandler(this.productList, 3);
                            this.showregisteredproduct = true;
                            this.showproductdetail = false;
                            window.scrollTo(0, parseInt(scrollY || '0') * -1);
                            this.productRegistrationEventHandler(this.productList, 4);
                            this.isLoading = false;
                            console.log('Guest Product Registration Success with statuc code 404.');
                        } else {
                            count++;
                        }
                    } else {
                        this.errorToast('Product registration failed.');
                        this.isLoading = false;
                        console.error('Error on webconsumer info insert: ', error);
                    }
                });
        });
    }
    // logged user product registration
    loggedUserProductRegistration() {
        this.isLoading = true;
        let nonEligibleStates = this.nonEligibleStatesForBodewellServicePlan.split(';');
        if (nonEligibleStates.indexOf(this.productContactInfo.state) !== -1) {
            this.isPromoEligibleState = false;
        }
        let assetList = [];
        if (this.disableAddress) {
            let count = 1;
            let selectedAddress = {
                Address1: this.productContactInfo.street,
                City: this.productContactInfo.city,
                State: this.productContactInfo.state,
                PostalCode: this.productContactInfo.zipCode,
                Firstname: this.productContactInfo.firstName,
                Lastname: this.productContactInfo.lastName,
                Email: this.productContactInfo.email,
                Phone: this.productContactInfo.phone,
            }
            this.productList.forEach((item) => {
                let installDate = new Date(item.installDate);

                console.log('item.installDate :', +item.installDate);
                let tzDifference = installDate.getTimezoneOffset();
                console.log('time zone difference:', +tzDifference);
                let instdate = new Date(installDate.getTime() + tzDifference * 60 * 1000);
                let productItem = {
                    ModelNumber: item.modelNumber,
                    SerialNumber: item.serialNumber,
                    InstallationDate: instdate.getMonth() + 1 + '/' + instdate.getDate() + '/' + instdate.getFullYear()
                }
                console.log('product list:', +productItem);
                registerAssets({
                    assetInput: productItem,
                    addressInput: selectedAddress,
                    dataSourceCode: item.dataSourceCode,
                    accountId: this.selectedaddress.Id,
                    contactId: this.loggedUser.Id,
                    isEndecaModelNumber: item.isValidModelNumber,
                    qrLink: this.qrLink.url
                }).then(result => {
                    if (result.Success) {
                        assetList.push(result.Asset.Id);
                        if (count == this.productList.length) {
                            this.saveNewPhone();
                            this.setAssurantLink(this.productList); //CCOE - 1084
                            this.emailPayloadPublish(assetList);
                            this.productRegistrationEventHandler(this.productList, 3);
                            this.showregisteredproduct = true;
                            this.showproductdetail = false;
                            window.scrollTo(0, parseInt(scrollY || '0') * -1);
                            this.productRegistrationEventHandler(this.productList, 4);
                            this.isLoading = false;
                        } else {
                            count++;
                        }
                    } else {
                        console.error('GEA Asset insert failed: ', result);
                        this.logError({
                            'errorMessage': 'GEA Asset insert failed',
                            'sourceClass': 'Mya_productRegistration',
                            'sourceFunction': 'MYA_AccountController.saveAssets',
                            'modelNumber': item.modelNumber,
                            'serialNumber': item.serialNumber,
                            'installDate': item.installDate,
                            'name': this.loggedUser.Name,
                            'lastName': this.productContactInfo.lastName,
                            'email': this.productContactInfo.email,
                            'phone': this.productContactInfo.phone,
                            'street': this.productContactInfo.street,
                            'city': this.productContactInfo.city,
                            'state': this.productContactInfo.state,
                            'dataSourceCode': item.dataSourceCode
                        });
                        this.errorToast('Product registration failed.');
                        this.isLoading = false;
                    }
                })
                    .catch(error => {
                        this.error = error;
                        console.error('GEA Asset insert failed: ', error);
                        this.logError({
                            'errorMessage': 'GEA Asset insert failed',
                            'sourceClass': 'Mya_productRegistration',
                            'sourceFunction': 'MYA_AccountController.saveAssets',
                            'modelNumber': item.modelNumber,
                            'serialNumber': item.serialNumber,
                            'installDate': item.installDate,
                            'name': this.loggedUser.Name,
                            'lastName': this.productContactInfo.lastName,
                            'email': this.productContactInfo.email,
                            'phone': this.productContactInfo.phone,
                            'street': this.productContactInfo.street,
                            'city': this.productContactInfo.city,
                            'state': this.productContactInfo.state,
                            'dataSourceCode': item.dataSourceCode
                        });
                        this.errorToast('Product registration failed.');
                        this.isLoading = false;
                    });
            });
        } else {
            userConsentVerification()
                .then(result => {
                    if (result.Success) {
                        console.log('Consent verified');
                        let count = 1;
                        let selectedAddress = {
                            Address1: this.productContactInfo.street,
                            City: this.productContactInfo.city,
                            State: this.productContactInfo.state,
                            PostalCode: this.productContactInfo.zipCode,
                            Firstname: this.productContactInfo.firstName,
                            Lastname: this.productContactInfo.lastName,
                            Email: this.productContactInfo.email,
                            Phone: this.productContactInfo.phone,
                        }
                        this.productList.forEach((item) => {
                            let installDate = new Date(item.installDate);
                            let productItem = {
                                ModelNumber: item.modelNumber,
                                SerialNumber: item.serialNumber,
                                InstallationDate: installDate.getMonth() + 1 + '/' + installDate.getDate() + '/' + installDate.getFullYear()
                            }
                            registerAssets({
                                assetInput: productItem,
                                addressInput: selectedAddress,
                                dataSourceCode: item.dataSourceCode,
                                accountId: this.newAccountId,
                                contactId: this.loggedUser.Id,
                                isEndecaModelNumber: item.isValidModelNumber,
                                qrLink: this.qrLink.url
                            }).then(result => {
                                if (result.Success) {
                                    assetList.push(result.Asset.Id);
                                    if (count == this.productList.length) {
                                        this.saveNewPhone();
                                        this.setAssurantLink(this.productList); // CCOE-1084
                                        this.emailPayloadPublish(assetList);
                                        this.productRegistrationEventHandler(this.productList, 3);
                                        this.showregisteredproduct = true;
                                        this.showproductdetail = false;
                                        window.scrollTo(0, parseInt(scrollY || '0') * -1);
                                        this.productRegistrationEventHandler(this.productList, 4);
                                        this.isLoading = false;
                                    } else {
                                        count++;
                                    }
                                } else {
                                    console.error('GEA Asset insert failed: ', result);
                                    this.logError({
                                        'errorMessage': 'GEA Asset insert failed',
                                        'sourceClass': 'Mya_productRegistration',
                                        'sourceFunction': 'MYA_AccountController.saveAssets',
                                        'modelNumber': item.modelNumber,
                                        'serialNumber': item.serialNumber,
                                        'installDate': item.installDate,
                                        'name': this.loggedUser.Name,
                                        'lastName': this.productContactInfo.lastName,
                                        'email': this.productContactInfo.email,
                                        'phone': this.productContactInfo.phone,
                                        'street': this.productContactInfo.street,
                                        'city': this.productContactInfo.city,
                                        'state': this.productContactInfo.state,
                                        'dataSourceCode': item.dataSourceCode
                                    });
                                    this.errorToast('Product registration failed.');
                                    this.isLoading = false;
                                }
                            })
                                .catch(error => {
                                    this.error = error;
                                    console.error('GEA Asset insert failed: ', error);
                                    this.logError({
                                        'errorMessage': 'GEA Asset insert failed',
                                        'sourceClass': 'Mya_productRegistration',
                                        'sourceFunction': 'MYA_AccountController.saveAssets',
                                        'modelNumber': item.modelNumber,
                                        'serialNumber': item.serialNumber,
                                        'installDate': item.installDate,
                                        'name': this.loggedUser.Name,
                                        'lastName': this.productContactInfo.lastName,
                                        'email': this.productContactInfo.email,
                                        'phone': this.productContactInfo.phone,
                                        'street': this.productContactInfo.street,
                                        'city': this.productContactInfo.city,
                                        'state': this.productContactInfo.state,
                                        'dataSourceCode': item.dataSourceCode
                                    });
                                    this.errorToast('Product registration failed.');
                                    this.isLoading = false;
                                });
                        });
                    } else {
                        console.error('Consent verification failed', result);
                        this.logError({
                            'errorMessage': 'Consent verification failed',
                            'sourceClass': 'Mya_productRegistration',
                            'sourceFunction': 'MYA_AccountController.createAccount',
                            'modelNumber': item.modelNumber,
                            'serialNumber': item.serialNumber,
                            'installDate': item.installDate,
                            'name': this.loggedUser.Name,
                            'lastName': this.productContactInfo.lastName,
                            'email': this.productContactInfo.email,
                            'phone': this.productContactInfo.phone,
                            'street': this.productContactInfo.street,
                            'city': this.productContactInfo.city,
                            'state': this.productContactInfo.state,
                            'dataSourceCode': item.dataSourceCode
                        });
                        this.errorToast('Consent verification failed');
                        this.isLoading = false;
                    }
                })
                .catch(error => {
                    this.error = error;
                    console.error('Consent verification failed', error);
                    this.logError({
                        'errorMessage': 'Consent verification failed',
                        'sourceClass': 'Mya_productRegistration',
                        'sourceFunction': 'MYA_AccountController.createAccount',
                        'modelNumber': item.modelNumber,
                        'serialNumber': item.serialNumber,
                        'installDate': item.installDate,
                        'name': this.loggedUser.Name,
                        'lastName': this.productContactInfo.lastName,
                        'email': this.productContactInfo.email,
                        'phone': this.productContactInfo.phone,
                        'street': this.productContactInfo.street,
                        'city': this.productContactInfo.city,
                        'state': this.productContactInfo.state,
                        'dataSourceCode': item.dataSourceCode
                    });
                    this.errorToast('Consent verification failed');
                    this.isLoading = false;
                });
        }
    }
    // Save New Phone
    saveNewPhone() {
        if (!this.disablePhone) {
            const phonefields = {
                'Phone__c': this.productContactInfo.phone,
                'Contact__c': this.loggedUser.Id,
                'MYA_Included__c': true,
                'MYAISPrimary__c': false
            };
            const phoneInput = { apiName: CONTACT_POINT_OBJECT.objectApiName, fields: phonefields };
            createRecord(phoneInput)
                .then((res) => {
                    console.log('Added new phone number');
                })
                .catch((error) => {
                    console.error('Create contact point record failed: ', error);
                });
        }
    }
    // Generate Email Payload for SFMC
    emailPayloadPublish(assetList) {
        publishEmailPayloadForSFMC({ AssetIDS: assetList, assurantURL: this.assurantServiceLink + 'EM' }) // CCOE-1084
            .then((result) => {
                console.log("Email payload published.");
                console.log(result);
            })
            .catch((error) => {
                this.error = error;
                console.error("Error occured while publishing Email payload: ", error);
            });
    }
    // Register new product
    handleRegisterAnotherProduct() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: (window.location.origin).concat(window.location.pathname)
            }
        });
    }
    // Redirection into My account
    viewMyAccount() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'MYA_My_Products__c'
            }
        });
    }
    // Handle Consent
    handleConsentOnChange(event) {
        this.consentApproved = !this.consentApproved;
        this.consentValidation = false;
        if (!this.consentApproved) {
            this.template.querySelector('.consent-check').classList.remove('slds-has-error');
        }
        this.isChecked = event.target.checked;
    }
    // 
    getDataSourceCode(data) {
        if (this.brand == "Haier") {
            return data.HA__c;
        } else if (this.brand == "Cafe") {
            return data.Cafe__c;
        }  else if (this.brand == "Bodewell") {
            return data.Bodewell__c;
        }
        else {
            return data.GEA__c;
        }
    }

    getReviewLinks(brand, reviewLinks, modelNumber) {
        let reviewLink;
        if (brand == 'Cafe') {
            reviewLink = reviewLinks.filter(link => link.Brand__c == 'Cafe')[0];
        }
        else if (brand == 'Haier') {
            reviewLink = reviewLinks.filter(link => link.Brand__c == 'Haier')[0];
        }
        else if (brand == 'Hotpoint') {
            reviewLink = reviewLinks.filter(link => link.Brand__c == 'Hotpoint')[0];
        }
        else if (brand == 'Monogram') {
            reviewLink = reviewLinks.filter(link => link.Brand__c == 'Monogram')[0];
        } 
        else {
            reviewLink = reviewLinks.filter(link => link.Brand__c == 'GEA')[0];
        }
        return reviewLink.Review_Link__c + modelNumber + reviewLink.CampaignId_Parameter__c;
    }

    //Set product info
    setProductInfo(endecaRes) {
        if (this.productList.length > 0) {
            this.productList.forEach((item) => {
                if (item.isQRProductModelNumber || item.isQRProductSerialNumber) {
                    item.dataSourceCode = this.getDataSourceCode(this.productConfigData.QrDataSourceCode);
                } else {
                    item.dataSourceCode = this.getDataSourceCode(this.productConfigData.DataSourceCode);
                }
                console.log('DataSourceCode: ', item.dataSourceCode);
                item.bvurl = this.getReviewLinks(this.brand, this.reviewLinks, item.marketingModelNumber);
                let product = endecaRes.filter(el => el.ModelNumber == item.marketingModelNumber)[0];
                if (product) {
                    item.imageUrl = product.DefaultImageUrl;
                    item.description = product.ProductDescription;
                    item.brand = product.Brand;
                    item.commercialCategory = product.CommercialCategories;
                    item.isValidModelNumber = true;
                    if (product.ProductCommercialCategory) {
                        item.productCommercialCategory = (product.ProductCommercialCategory.length > 0) ?
                            product.ProductCommercialCategory[product.ProductCommercialCategory.length - 1] : '';
                    }
                    if (product.appFilterProductType) {
                        item.appFilterProductType = (product.AppFilterProductType.length > 0) ?
                            product.AppFilterProductType[product.AppFilterProductType.length - 1] : '';
                    }
                    if (product.ExteriorStyle) {
                        item.exteriorStyle = (product.ExteriorStyle.length > 0) ?
                            product.ExteriorStyle[product.ExteriorStyle.length - 1] : '';
                    }
                    item.bvurl = this.getReviewLinks(product.Brand, this.reviewLinks, product.ModelNumber);
                }
            });
        }
    }

    //Get endeca details
    getEndecaInfo(productList) {

        let keys = [];
        if (productList.length > 0) {
            productList.forEach((item) => {
                keys.push(item.marketingModelNumber);
            });
        }
        if (keys.length > 0) {
            endecaInfo({ Keys: keys })
                .then(result => {
                    //productEndecaResponse = result;
                    console.log('Product Details: ', result);
                    this.setProductInfo(result.ProductsInfo);
                    result.ProductsInfo.forEach((item) => {
                        if (item.EcoPrimary && !this.filterModelNo && (item.ProductCategory.includes('Refrigerators') || item.ProductCategory.includes('Icemakers'))) {
                            this.filterModelNo = item.EcoPrimary;
                            this.eligibleAppliance = item.ProductCategory.replace('s', '');
                            this.fetchPartsImage();
                            this.showapromoform = true;
                        }
                    });

                })
                .catch(error => {
                    this.error = error;
                    console.error('Error on endeca response: ', error);
                });
        }
    }

    productRegistrationEventHandler(productList, event) {
        let eventName;
        if (event == 1) {
            eventName = 'gtm__productRegistrationStart';
        }
        if (event == 2) {
            eventName = 'gtm__productRegistrationContact';
        }
        if (event == 3) {
            eventName = 'gtm__productRegistrationReview';
        }
        if (event == 4) {
            eventName = 'gtm__productRegistrationComplete';
        }
        if (productList.length > 0) {
            productList.forEach((item) => {
                let productRegistrationEvent = new CustomEvent(
                    eventName, {
                    detail: {
                        modelNumber: item.modelNumber,
                        serialNumber: item.serialNumber
                    }
                }
                );
                document.dispatchEvent(
                    productRegistrationEvent, {
                    bubbles: true,
                    composed: true
                }
                );
            });
        }
    }

    logError(inputs) {
        errorLog(inputs)
            .then(result => {
                if (result) {
                    console.log('Error  logged');
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'Registartion failed.',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                }
            })
            .catch(error => {
                this.error = error;
                console.error('Error  logging failed: ', error);
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

    setAssurantLink(productList) {
        try {
            let productParams = '';
            let count = 1;
            productParams = productParams + 'zipcode=' + this.productContactInfo.zipCode + '&';
            if (productList.length > 0) {
                productList.forEach((item) => {
                    let productData = encodeURIComponent(item.productCommercialCategory);
                    if (item.appFilterProductType && item.appFilterProductType != '') {
                        productData = productData + '_' + encodeURIComponent(item.appFilterProductType);
                    }
                    if (item.exteriorStyle && item.exteriorStyle != '') {
                        productData = productData + '_' + encodeURIComponent(item.exteriorStyle);
                    }
                    productParams = productParams + 'brand' + count + '=' + encodeURIComponent(item.brand) + '&';
                    productParams = productParams + 'product' + count + '=' + productData + '&';
                    productParams = productParams + 'model' + count + '=' + item.modelNumber + '&';
                    productParams = productParams + 'serial' + count + '=' + item.serialNumber + '&';
                    productParams = productParams + 'installdate' + count + '=' + item.installDate + '&';
                    count++;
                });
                productParams = productParams + this.assurantServiceLinkEndParameters;
            }
            this.assurantServiceLink = this.assurantServiceLink + productParams;
            this.assurantServiceLinkVisible = true;
        } catch (error) {
            this.assurantServiceLinkVisible = false;
        }
    }

    setSelectedRecord(e) {
        this.txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        let clickedSec = e.currentTarget.dataset.id;
        let clickedItem = this.productList.find((item) => item.key == parseInt(clickedSec));
        clickedItem.modelNumber = e.currentTarget.dataset.name;
        let selectedItem = clickedItem.searchRecords.find((item) => item.MN__c == e.currentTarget.dataset.name);
        if (selectedItem) {
     
             clickedItem.marketingModelNumber = selectedItem.MR_PKMOD__c;
        }
        clickedItem.showTypeAhead = false;
    }

    handleModelnumberBlur(e) {
        let clickedSec = e.currentTarget.dataset.id;
        let clickedItem = this.productList.find((item) => item.key == parseInt(clickedSec));
        clickedItem.showTypeAhead = false;
    }

    guestEmailPayloadPublish(payload) {
        console.log("Start preparing email payload for guest.");
        let inputData = {
            payload
        }
        publishGuestEmailPayloadForSFMC({ input: inputData })
            .then((result) => {
                console.log("Email payload published.");
                console.log(result);
            })
            .catch((error) => {
                this.error = error;
                console.error("Email payload not published: ", error);
            });
    }

    setGuestEmailPayload(productInput, contactInput) {
        let productData = [];
        productInput.forEach(item => {
            let installDate = new Date(item.installDate);
            let product = {
                ApplianceInstallDate: installDate.getFullYear() + '/' + (installDate.getMonth() + 1) + '/' + installDate.getDate(),
                ManufacturingModel: (item.isValidModelNumber && item.isValidManufacturingModel) ? item.modelNumber : '',
                ModelValidityFlag: item.isValidModelNumber ? 'TRUE' : 'FALSE',
                MarketingModel: item.isValidModelNumber ? item.marketingModelNumber : '',
                ApplianceSerial: item.serialNumber,
                SourceCode: item.dataSourceCode,
                InputModel: item.modelNumber
            };
            productData.push(product);
        });

        let transaction_data = {
            ConsumerFirstName: contactInput.firstName,
            ConsumerLastName: contactInput.lastName,
            ConsumerAddress1: contactInput.street,
            ConsumerAddress2: '',
            ConsumerPhone: contactInput.phone,
            City: contactInput.city,
            State: contactInput.state,
            ZipCode: contactInput.zipCode,
            AssurantURL: this.assurantServiceLink + 'EM', //CCOE-1084
            product: productData
        };

        let payLoad_c = {
            transaction_data: transaction_data,
            send_single_options: { "suppression_info": "false" },
            send_single_contact: { "email": contactInput.email }
        }

        let data = {
            Payload__c: JSON.stringify(payLoad_c),
            Email__c: contactInput.email,
            SessionID__c: contactInput.email + new Date().valueOf()
        }

        return data;
    }

    // Get state list
    get states() {
        return [
            { label: 'AL', value: 'AL' },
            { label: 'AK', value: 'AK' },
            { label: 'AZ', value: 'AZ' },
            { label: 'AR', value: 'AR' },
            { label: 'CA', value: 'CA' },
            { label: 'CO', value: 'CO' },
            { label: 'CT', value: 'CT' },
            { label: 'DE', value: 'DE' },
            { label: 'DC', value: 'DC' },
            { label: 'FL', value: 'FL' },
            { label: 'GA', value: 'GA' },
            { label: 'HI', value: 'HI' },
            { label: 'ID', value: 'ID' },
            { label: 'IL', value: 'IL' },
            { label: 'IN', value: 'IN' },
            { label: 'IA', value: 'IA' },
            { label: 'KS', value: 'KS' },
            { label: 'KY', value: 'KY' },
            { label: 'LA', value: 'LA' },
            { label: 'ME', value: 'ME' },
            { label: 'MD', value: 'MD' },
            { label: 'MA', value: 'MA' },
            { label: 'MI', value: 'MI' },
            { label: 'MN', value: 'MN' },
            { label: 'MS', value: 'MS' },
            { label: 'MO', value: 'MO' },
            { label: 'MT', value: 'MT' },
            { label: 'NE', value: 'NE' },
            { label: 'NV', value: 'NV' },
            { label: 'NH', value: 'NH' },
            { label: 'NJ', value: 'NJ' },
            { label: 'NM', value: 'NM' },
            { label: 'NY', value: 'NY' },
            { label: 'NC', value: 'NC' },
            { label: 'ND', value: 'ND' },
            { label: 'OH', value: 'OH' },
            { label: 'OK', value: 'OK' },
            { label: 'OR', value: 'OR' },
            { label: 'PA', value: 'PA' },
            { label: 'PR', value: 'PR' },
            { label: 'RI', value: 'RI' },
            { label: 'SC', value: 'SC' },
            { label: 'SD', value: 'SD' },
            { label: 'TN', value: 'TN' },
            { label: 'TX', value: 'TX' },
            { label: 'UT', value: 'UT' },
            { label: 'VT', value: 'VT' },
            { label: 'VA', value: 'VA' },
            { label: 'WA', value: 'WA' },
            { label: 'WV', value: 'WV' },
            { label: 'WI', value: 'WI' },
            { label: 'WY', value: 'WY' }
        ];
    }
}