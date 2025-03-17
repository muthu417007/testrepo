import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
// Templates
import Cafe from "./mya_AddAppliance_Cafe.html";
import GEA from "./mya_AddAppliance_GEA.html";
import Haier from "./mya_AddAppliance_Haier.html";
import Bodewell from "./mya_AddAppliance_Bodewell.html";
// User ID
import USER_ID from '@salesforce/user/Id';
import isguest from '@salesforce/user/isGuest';
// Apex methods
import endecaInfo from '@salesforce/apex/MYA_EndecaApiHandler.MYA_EndecaResponseDetails';
import createAccount from '@salesforce/apex/Mya_AddressHandler.Mya_AddressValidation';
import createAfxAccount from '@salesforce/apex/Mya_AddressHandler.Mya_AfxAddressValidation';
import searchAssetsFromAFX from '@salesforce/apex/MYA_AfxAPIController.searchAssetsFromAFX';
import getAccountInfo from '@salesforce/apex/MYA_ProductRegistrationController.getAccountInfo';
import registerAssets from '@salesforce/apex/MYA_AccountController.registerAssets';
import saveAfxAssets from '@salesforce/apex/MYA_AccountController.saveAssets';
import publishEmailPayloadForSFMC from '@salesforce/apex/MYA_generateEmailPayloadForSFMC.MYA_Utility_publishEmailPayloadForSFMC';


export default class Mya_AddAppliance extends NavigationMixin(LightningElement) {

    isGuestUser = isguest;
    @api brand = 'GEA';
    @api cafePrivacyPolicyLink = 'https://www.geappliances.com/privacy/privacy_policy.htm';
    @api geaPrivacyPolicyLink = 'https://www.geappliances.com/privacy/privacy_policy.htm';
    @api HaierPrivacyPolicyLink = 'https://www.geappliances.com/privacy/privacy_policy.htm';
    isModalOpen = false;
    selectedAddress;
    address1;
    city;
    selectedState;
    zipCode;
    nickName;
    phoneNumber;
    emailAddress;
    searchResult;
    wireFilterbyAccountResult;
    addressOptions;
    wireResult;
    currentUser;
    currentUserName;
    currentUserEmailId;
    currentUserFirst;
    currentUserLastName;
    currentUserContactId;
    contactPoints;
    primaryPhone;
    error;    
    newAddress = false;
    disableAddress = false;
    searchProducts = true;
    noProducts = false;
    stateValidation = false;
    isSearching = false;
    addressId;
    addressSelected;
    zipCodePattern = '[0-9]{5}$';
    zipCodePatternValidationMessage = 'Please enter a valid zip code';
    addressFieldPattern = '^[a-zA-Z0-9 ]+$';
    addressPatternValidationMessage = 'Special characters are not allowded.';
    connected = false;

    // UI render based on brand and user status
    render() {
        if (this.brand == "GEA") {
            return GEA;
        } else if (this.brand == "Haier") {
            return Haier;
        } else if (this.brand == "Cafe") {
            return Cafe;
        } else if (this.brand == "Bodewell") {
            console.log('mya add appliance Bodewell render');
            return Bodewell;
        }
    }

    connectedCallback() {
        if(this.connected) {           
            refreshApex(this.wireFilterbyAccountResult); 
        }
        this.connected = true;
    }

    @wire(getAccountInfo, { UserId: USER_ID })
    accountInfo(result) {
        this.wireFilterbyAccountResult = result;
        if (result.data) {
            try {
                let response = result.data;
                if (response.Success) {
                    //Contact info
                    this.loggedUser = response.ContactDetails;
                    this.currentUserContactId = this.loggedUser.Id;
                    // Address info
                    let addressData = response.AddressList.filter(item => item.BillingStreet);
                    this.storedaddress = addressData;
                    let options = [];
                    options = [{ label: 'Search with other address', value: '' }];
                    if (addressData.length > 0) {
                        for (var key in addressData) {
                            if (key != '') {
                                options.push({ label: addressData[key].BillingStreet, value: addressData[key].Id });
                            }
                        }
                    }
                    this.addressOptions = options;
                    // Phone info
                    let contactPointsData = response.ContactPoints;
                    if (contactPointsData.length > 0) {
                        const primary = contactPointsData.filter(el => el.MYAISPrimary__c)[0];
                        if (primary) {
                            this.primaryPhone = primary.Phone__c;
                        }
                    }
                }

            } catch (error) {
                console.error('check error here', error);
            }
        } else if (result.error) {
            console.error('check error here', result.error);
        }
    }

    // Custom validation method for validate class fields
    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        let isStateValid = this.isStateInputValid();
        isValid = isValid ? isStateValid : isValid;
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

    handleAddressDropdownChange(event) {
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

    handleAddress1Change(event) {
        this.address1 = event.detail.value;
    }

    handleCityChange(event) {
        this.city = event.detail.value;
    }

    handleStateChange(event) {
        this.selectedState = event.target.value;
        this.isStateInputValid();
    }

    handleZipCodeChange(event) {
        this.zipCode = event.detail.value;
    }

    handleNickNameChange(event) {
        this.nickName = event.detail.value;
    }

    searchProduct(event) {
        this.searchProducts = true;
        this.noProducts = false;
        this.isModalOpen = true;
        const body = document.body;
        body.style.height = '100vh';
        body.style.overflowY = 'hidden';
    }

    closeModal() {
        this.isModalOpen = false;
        this.isSearching = false;
        const body = document.body;
        body.style.height = '';
        body.style.overflowY = '';
        window.scrollTo(0, parseInt(scrollY || '0') * -1);
    }

    searchProductSubmit(event) {
        this.isSearching = true;
        let searchData = {};
        if (this.selectedaddress) {
            this.addressSelected = {
                Address1: this.selectedaddress.BillingStreet,
                City: this.selectedaddress.BillingCity,
                State: this.selectedaddress.BillingState,
                PostalCode: this.selectedaddress.BillingPostalCode,
                Firstname: this.loggedUser.FirstName,
                Lastname: this.loggedUser.LastName,
                Email: this.loggedUser.Email,
                Phone: this.primaryPhone,
            }
            searchData = {
                AddressLine1: this.selectedaddress.BillingStreet,
                Locality: this.selectedaddress.BillingCity,
                Region: this.selectedaddress.BillingState,
                PostalCode: this.selectedaddress.BillingPostalCode,
                PhoneNumber: this.primaryPhone,
                EmailAddress: this.loggedUser.Email,
                LastName: this.loggedUser.LastName
            }
            this.newAddress = false;
            this.searchAfxProducts(searchData);
        } else {
            if (this.isInputValid()) {
                this.addressSelected = {
                    Address1: this.address1,
                    City: this.city,
                    State: this.selectedState,
                    PostalCode: this.zipCod,
                    Firstname: this.loggedUser.FirstName,
                    Lastname: this.loggedUser.LastName,
                    Email: this.loggedUser.Email,
                    Phone: this.primaryPhone,
                }
                searchData = {
                    AddressLine1: this.address1,
                    Locality: this.city,
                    Region: this.selectedState,
                    PostalCode: this.zipCode,
                    PhoneNumber: this.primaryPhone,
                    EmailAddress: this.loggedUser.Email,
                    LastName: this.loggedUser.LastName
                }
                this.newAddress = true;
                this.searchAfxProducts(searchData);
            } else {                
                this.isSearching = false;
            }
        }
    }   

    searchAfxProducts(input) {
        searchAssetsFromAFX(input)
            .then(result => {
                this.searchResult = JSON.parse(result);
                console.log('Product search results: ', this.searchResult);
                this.saveAfxLocation(this.searchResult.Assets,input);
            })
            .catch(error => {
                this.error = error;
                console.error('Search product results: ', error);
                this.isSearching = false;
                this.closeModal();
            });
    }

    saveAfxLocation(assetList, address) {        
        if(this.newAddress) {
            this.saveSearchAddress(assetList,address);
        } else {
            this.saveAfxProducts(assetList, this.selectedaddress.Id);
        }        
    }

    saveSearchAddress(assetList, input) {
        if(assetList.length > 0) {
            let afxInputDetails = {
                'Address': input.AddressLine1,
                'City': input.Locality,
                'State': input.Region,
                'Code': input.PostalCode,
                'Primary': false,
                'NickName': this.nickName,
                'AFXLocationId': assetList[0].AFXLocationID
            }
            createAfxAccount(afxInputDetails)
                .then(result => {
                    if (result && result.Success && result.AlreadyExist) {
                        this.saveAfxProducts(assetList, result.Account.Id);
                    } else if (result && result.Success && !result.AlreadyExist) {
                        this.createNewAccount(assetList, input);
                    } else {
                        console.error('Response on account creation: ', result);
                        this.closeModal();
                    }
                })
                .catch(error => {
                    this.error = error;
                    console.error('Response on account creation: ', error);
                    this.closeModal();
                });
        }  else {
            this.createNewAccount(assetList, input);
        }      
    }

    createNewAccount(assetList, input) {
        let inputDetails = {
            'Address': input.AddressLine1,
            'City': input.Locality,
            'State': input.Region,
            'Code': input.PostalCode,
            'Primary': false,
            'NickName': this.AccName
        }
        createAccount(inputDetails)
            .then(result => {
                if (result) {
                    if(assetList.length > 0) {
                        this.saveAfxProducts(assetList, result.Id); 
                    } else {                        
                        this.searchProducts = false;
                        this.noProducts = true;
                    }
                } else {
                    console.error('Error response on account creation: ', result);
                    this.isDelModal = false;
                    this.isSearching = false;
                }
            })
            .catch(error => {
                this.error = error;
                console.error('Error occured on account creation: ', error);
                this.isDelModal = false;
            });
    }

    saveAfxProducts(assetList, addressId) {        
        let validAssetList = assetList.filter(el => !el.IsAccessory);
        if(validAssetList.length > 0) {
            let assets = [];
            let assetCount = 1;
            validAssetList.forEach((item) => {
                    let OwnershipStartedOn = item.OwnershipStartedOn;
                    let result = OwnershipStartedOn.substring(6, OwnershipStartedOn.length - 2);
                    let data = result.split("-");
                    let part_1 = Number(data[0]); // 004
                    let part_2 = Number(data[1]);
                    let installDate = new Date(part_1 - part_2);
    
                    let productItem = {
                        AFXAssetId: item.AFXAssetID,
                        ModelNumber: item.OriginalEngineeringModelNumber ? item.OriginalEngineeringModelNumber : item.CleansedModelNumber,
                        SerialNumber: item.SerialNumber,
                        InstallationDate: installDate.getMonth() + 1 + '/' + installDate.getDate() + '/' + installDate.getFullYear()
                    }
    
                    registerAssets({
                        assetInput: productItem,
                        addressInput: this.addressSelected,
                        dataSourceCode: item.DataSourceCode == 'CUST-NVR' ? 'NV' : item.DataSourceCode,
                        accountId: addressId,
                        contactId: this.currentUserContactId,
                        isEndecaModelNumber: true,
                        qrLink: null
                    }).then(result => {
                        if (result.Success) {
                            assets.push(result.Asset.Id);
                            if (assetCount == validAssetList.length) {
                                this.emailPayloadPublish(assets);
                                location.reload();
                            } else {
                                assetCount++;
                            }
                        } else {
                            console.error('GEA Asset insert failed: ', result);
                            this.errorToast('Product registration failed.');
                            location.reload();
                        }
                    }).catch(error => {
                        this.error = error;
                        console.error('GEA Asset insert failed: ', error);
                        this.errorToast('Product registration failed.');
                        location.reload();
                    });
            });
        } else {
            this.searchProducts = false;
            this.noProducts = true;
        }
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

    errorToast(message) {
        const event = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    // Generate Email Payload for SFMC
    emailPayloadPublish(assetList) {
        publishEmailPayloadForSFMC({ AssetIDS: assetList })
            .then((result) => {
                console.log("Email payload published.");
            })
            .catch((error) => {
                this.error = error;
                console.error("Error occured while publishing Email payload: ", error);
            });
    }

    navigateToProductRegistration() {
        this[NavigationMixin.GenerateUrl]({
            type: 'comm__namedPage',
            attributes: {
                name: 'MYA_Product_Registration__c'
            }
        }).then(url => { window.open(url) });
    }

    // getEndecaInfo(sku) {
    //     endecaInfo({ SKU: sku })
    //         .then(result => {
    //             console.log('Product Details: ', result);
    //             this.response = result;
    //         })
    //         .catch(error => {
    //             this.error = error;
    //             console.error('Product details: ', error);
    //         });
    // } 

    get stateOptions() {
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