import { LightningElement, wire, api, track } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import mya_GEAaddressDetails from './mya_GEAaddressDetails.html';
import mya_CafeaddressDetails from './mya_CafeaddressDetails.html';
import mya_HaieraddressDetails from './mya_HaieraddressDetails.html';
import Bodewell from './mya_BodewelladdressDetails.html';

                     
                                          

// User ID
import USER_ID from '@salesforce/user/Id';

//refresh data
import { refreshApex } from '@salesforce/apex';

//new
import Mya_AddressValidation from '@salesforce/apex/Mya_AddressHandler.Mya_AddressValidation';
import Mya_GetAddressDetails from '@salesforce/apex/Mya_AddressHandler.Mya_GetAddressDetails';
import Mya_UpAssetAddress from '@salesforce/apex/Mya_AddressHandler.Mya_UpAssetAddress';
import Mya_UpdateContLoc from '@salesforce/apex/Mya_AddressHandler.Mya_UpdateContLoc'
import Mya_DelAddress from '@salesforce/apex/Mya_AddressHandler.Mya_DelAddress';
//import Mya_PrivacyUrl from '@salesforce/apex/Mya_AddressHandler.Mya_PrivacyUrl';
import Mya_AssetList from '@salesforce/apex/Mya_AddressHandler.Mya_AssetList';
import getAccountInfo from '@salesforce/apex/MYA_ProductRegistrationController.getAccountInfo';
import createAccount from '@salesforce/apex/Mya_AddressHandler.Mya_AddressValidation';
import searchAssetsFromAFX from '@salesforce/apex/MYA_AfxAPIController.searchAssetsFromAFX';
import saveAfxAssets from '@salesforce/apex/MYA_AccountController.saveAssets';
import registerAssets from '@salesforce/apex/MYA_AccountController.registerAssets';
import publishEmailPayloadForSFMC from '@salesforce/apex/MYA_generateEmailPayloadForSFMC.MYA_Utility_publishEmailPayloadForSFMC';
import createAfxAccount from '@salesforce/apex/Mya_AddressHandler.Mya_AfxAddressValidation';

//metadata
import getmyaConfigs from '@salesforce/apex/Mya_ProductDetails.getmyaConfigs';
//css
import MYAGEACSS from '@salesforce/resourceUrl/MYAGEACSS';
import MYACAFECSS from '@salesforce/resourceUrl/MYACAFECSS';
import MYAHAIERCSS from '@salesforce/resourceUrl/MYAHAIERCSS';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class mya_addressDetails extends LightningElement {

    @api brandValue = 'GEA';
    @api address;
    @api city;
    @api state;
    @api postalCode;
    @api add_Nickname;
    @api AccountId;
    AccName; //to store nickname
    AccAddress;
    AccCityName;
    AccState;
    AccZipCode;
    AccId;
    Contact; //to store contact id
    RecordType = '0124P0000015hYOQAY';
    isModalOpen = false;
    isModalOpen1 = false;
    UpdatedName;
    UpdatedAddress;
    UpdatedCity;
    UpdatedState;
    UpdatedCode;
    selectedAccId;
    UpdatedPrimaryAddress = false;
    primaryaddCheck;
    selectedContact;
    selectedCon;
    junResId;
    accounts;
    isDelModal = false;
    selectedField;
    conId;
    wiredAddressResult;
    AddressList;
    @track AddressList1;
    wireFilterbyAccountResult;
    loggedUser;
    currentUserContactId;
    storedaddress;
    primaryPhone;
    //checkbox for primary address
    primaryAddress = false;
    checkvalue;
    checkvalue1;
    //to get address object details
    wiredcontactResult;
    ContactList;
    //to get acc& jun obj details
    wiredAccJunResult;
    accJunList;
    accJunList1;
    //to get account details 
    WiredaccountsResult;
    //new drop down address list
    astAcc;
    Status;
    //privacyurl
    PrivacyUrl;
    primaryAddressNicknameEdit = false;
    stateValidation = false;
    zipCodePattern = '[0-9]{5}$';
    zipCodePatternValidationMessage = 'Please enter a valid zip code';
    addressFieldPattern = '^[a-zA-Z0-9 ]+$';
    addressPatternValidationMessage = 'Special characters are not allowded.';
    isSearching = false;
    newAddress = false;

    render() {
        console.log('addessdetails',this.brandValue);
        if (this.brandValue == "GEA") {
            console.log('haier');
            return mya_GEAaddressDetails;
        } else if (this.brandValue == "Haier") {
            return mya_HaieraddressDetails;
        } else if (this.brandValue == "Cafe") {
            return mya_CafeaddressDetails;
        } else if (this.brandValue == "Bodewell") {
            console.log('addessdetails',this.brandValue);
            return Bodewell;
        }
    }

    // CSS loader function

    //   renderedCallback() {
    //     if (this.BrandValue == "GEA") {
    //         Promise.all([
    //             loadStyle(this, MYAGEACSS + '/MYAGEACSS/mya_GEAaddressDetails.css')
    //         ]);
    //     }
    //     else if (this.BrandValue == "Haier") {
    //         Promise.all([
    //             loadStyle(this, MYAHAIERCSS + '/MYAHAIERCSS/mya_HaieraddressDetails.css')
    //         ]);
    //     }
    //     else if (this.BrandValue == "Cafe") {
    //         Promise.all([
    //             loadStyle(this, MYACAFECSS + '/MYACAFECSS/mya_CafeaddressDetails.css')
    //         ]);
    //     }
    // }

    stateOptions = [
        { value: 'AK', label: 'AK' },
        { value: 'AL', label: 'AL' },
        { value: 'AR', label: 'AR' },
        { value: 'AZ', label: 'AZ' },
        { value: 'CA', label: 'CA' },
        { value: 'CO', label: 'CO' },
        { value: 'CT', label: 'CT' },
        { value: 'DC', label: 'DC' },
        { value: 'DE', label: 'DE' },
        { value: 'FL', label: 'FL' },
        { value: 'GA', label: 'GA' },
        { value: 'HI', label: 'HI' },
        { value: 'IA', label: 'IA' },
        { value: 'ID', label: 'ID' },
        { value: 'IL', label: 'IL' },
        { value: 'IN', label: 'IN' },
        { value: 'KS', label: 'KS' },
        { value: 'KY', label: 'KY' },
        { value: 'LA', label: 'LA' },
        { value: 'MA', label: 'MA' },
        { value: 'MD', label: 'MD' },
        { value: 'ME', label: 'ME' },
        { value: 'MI', label: 'MI' },
        { value: 'MN', label: 'MN' },
        { value: 'MO', label: 'MO' },
        { value: 'MS', label: 'MS' },
        { value: 'MT', label: 'MT' },
        { value: 'NC', label: 'NC' },
        { value: 'ND', label: 'ND' },
        { value: 'NE', label: 'NE' },
        { value: 'NH', label: 'NH' },
        { value: 'NJ', label: 'NJ' },
        { value: 'NM', label: 'NM' },
        { value: 'NV', label: 'NV' },
        { value: 'NY', label: 'NY' },
        { value: 'OH', label: 'OH' },
        { value: 'OK', label: 'OK' },
        { value: 'OR', label: 'OR' },
        { value: 'PA', label: 'PA' },
        { value: 'PR', label: 'PR' },
        { value: 'RI', label: 'RI' },
        { value: 'SC', label: 'SC' },
        { value: 'SD', label: 'SD' },
        { value: 'TN', label: 'TN' },
        { value: 'TX', label: 'TX' },
        { value: 'UT', label: 'UT' },
        { value: 'VA', label: 'VA' },
        { value: 'VT', label: 'VT' },
        { value: 'WA', label: 'WA' },
        { value: 'WI', label: 'WI' },
        { value: 'WV', label: 'WV' },
        { value: 'WY', label: 'WY' },
    ]

    //privacy url

    @wire(getmyaConfigs)
    WiredUrl(result) {
        if (result) {
            this.PrivacyUrl = result.data;
            console.log('url', this.PrivacyUrl)
        }
    }

    //new get address details
    @wire(Mya_GetAddressDetails)
    WiredAddressList(result) {
        this.wiredAddressResult = result;
        if (result) {
            this.AddressList = result;
            this.AddressList1 = result;
            console.log('add details',this.AddressList);
        }
    }

    AssetList
    //get aseet list
    @wire(Mya_AssetList)
    WiredAssets(result) {
        if (result) {
            this.AssetList = result;
            console.log(this.AssetList);
        }
    }

    //get primary mbl number,email
    @wire(getAccountInfo, { UserId: USER_ID })
    address(result) {
        this.wireFilterbyAccountResult = result;
        if (result.data) {
            try {
                let response = result.data;
                if (response.Success) {
                    //Contact info
                    this.loggedUser = response.ContactDetails;
                    this.currentUserContactId = this.loggedUser.Id;
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

    primaryAddressHandler(event) {
        this.checkvalue = event.target.value
        if (this.checkvalue === "true") {
            this.primaryAddress = true
        } else {
            this.primaryAddress = false
        }
    }

    setPrimaryAddress(event) {
        Mya_UpdateContLoc({ ContId: event.target.dataset.value, Primary: true })
            .then(result => {
                this.clearall();
                return refreshApex(this.wiredAddressResult)
            })
            .catch(error => {
                console.error(error)
            });
    }

    editPrimaryAddressNickname(event) {
        this.ContLocId = event.currentTarget.dataset.value
        this.isModalOpen1 = true;
        this.primaryAddressNicknameEdit = true;
    }


    selectOptions = [{ label: 'Search with other address', value: '' }];

    @wire(Mya_GetAddressDetails)
    lists({ error, data }) {
        if (data) {
            for (const list of data) {
                const option = {
                    label: list.Account__r.BillingStreet,
                    value: list.Account__c
                };
                this.selectOptions = [...this.selectOptions, option];
            }
        } else if (error) {
            console.error(error);
        }
    }

    modalHandler() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
        this.stateValidation = false;
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

    ContLocId

    modalHandler1(event) {
        this.ContLocId = event.currentTarget.dataset.value
        this.isModalOpen1 = true;
    }
    closeModal1() {
        this.isModalOpen1 = false;
        this.primaryAddressNicknameEdit = false;
        this.stateValidation = false;
    }

    AddressChangedHandler(event) {
        this.AccAddress = event.target.value;
    }
    CityChangedHandler(event) {
        this.AccCityName = event.target.value;
    }
    StateChangedHandler(event) {
        this.AccState = event.target.value;
        this.isStateInputValid();
    }
    CodeChangedHandler(event) {
        this.AccZipCode = event.target.value;
    }
    nameChangedHandler(event) {
        this.AccName = event.target.value;
    }
    createAcc() {
        if (this.isInputValid()) {
            Mya_AddressValidation({ Address: this.AccAddress, City: this.AccCityName, State: this.AccState, Code: this.AccZipCode, Primary: this.primaryAddress, NickName: this.AccName })
                .then(result => {
                    this.isModalOpen = false;
                    this.Status = result.data;
                    console.log('status' + this.Status)
                    this.clearall()
                    return refreshApex(this.wiredAddressResult)
                        .then(res => {
                            return refreshApex(this.AssetList)
                        })
                }).catch(error => {
                    console.log(error)
                })
            console.log(this.Status)
        }
    }

    clearall() {
        this.AccAddress = undefined;
        this.AccCityName = undefined;
        this.AccCityName = undefined;
        this.AccState = undefined;
        this.AccZipCode = undefined;
        this.AccName = undefined;
        this.primaryAddress = false;
        this.UpdatedName = undefined;
        this.UpdatedPrimaryAddress = false;
        this.primaryAddressNicknameEdit = false;
    }



    NameUpdateHandler(event) {
        this.UpdatedName = event.target.value
    }

    PrimaryAddUpdateHandler(event) {
        this.checkvalue1 = event.target.value
        if (this.checkvalue1 === "true") {
            this.UpdatedPrimaryAddress = true
        } else {
            this.UpdatedPrimaryAddress = false
        }
    }

    UpdateAddress(event) {
        let ContLocation = event.target.value;
        let IsPrimary = this.primaryAddressNicknameEdit ? true : false;
        Mya_UpdateContLoc({ ContId: ContLocation, NickName: this.UpdatedName, Primary: IsPrimary })
            .then(result => {
                this.isModalOpen1 = false
                this.clearall();
                return refreshApex(this.wiredAddressResult)
            })
            .catch(error => {
                console.error(error)
            })

    }



    //new delete a record

    isDelModal = false
    ContId
    AccId
    DeleteModal

    DelmodalOpen(event) {

        this.ContId = event.currentTarget.dataset.value;
        let Acc = this.AddressList.data.filter((item) => item.Id == this.ContId)[0];
        this.AccId = Acc.Account__c;
        let Assets = this.AssetList.data.filter((item) => item.Account_Location__c == this.AccId)[0];
        if (Assets == null) {
            this.DeleteModal = true;
        } else {
            this.isDelModal = true;
        }
    }

    DelmodalClose() {
        this.isDelModal = false;
    }

    DeleteModalClose() {
        this.DeleteModal = false;
    }

    DelConId

    DelAccAsset(event) {

        this.DelConId = event.target.value
        Mya_DelAddress({ ConId: this.DelConId })
            .then(result => {
                this.isDelModal = false;
                this.DeleteModal = false;
                return refreshApex(this.wiredAddressResult)
            })
            .catch(error => {
                console.log(error)
            })
    }

    newAdd
    ContactLocationId
    SelBillingStreet
    SelAddressId
    SelBillingCity
    SelBillingState
    SelCode
    SelAddId
    disableAddress = false

    //new address details from dropdown

    addressHandler(event) {
        if (event.target.value != '') {
            this.newAdd = event.target.value
            if (this.newAdd != '') {
                Mya_GetAddressDetails()
                    .then(result => {
                        for (const list of result) {
                            if (list.Account__c == this.newAdd) {
                                this.SelBillingStreet = list.Account__r.BillingStreet;
                                this.SelBillingCity = list.Account__r.BillingCity;
                                this.SelBillingState = list.Account__r.BillingState;
                                this.SelCode = list.Account__r.BillingPostalCode;
                                this.SelAddId = list.Account__c;
                                this.SelAddressId = list.Id;
                            }

                        }
                    }).catch(error => {
                        console.log('errorlog=' + error)
                    })
                this.disableAddress = true;
                // Revalidate address fields
                Promise.resolve().then(() => {
                    let inputFields = this.template.querySelectorAll('.validate');
                    inputFields.forEach(inputField => {
                        inputField.reportValidity();
                    });
                });
            }
        } else {
            this.newAdd = null
            this.disableAddress = false
        }
    }

    addressSelected;
    searchAddress(event) {
        this.isSearching = true;
        this.ContactLocationId = event.target.value;
        let searchData = {};
        if (this.newAdd) {
            this.addressSelected = {
                Address1: this.SelBillingStreet,
                City: this.SelBillingCity,
                State: this.SelBillingState,
                PostalCode: this.SelCode,
                Firstname: this.loggedUser.FirstName,
                Lastname: this.loggedUser.LastName,
                Email: this.loggedUser.Email,
                Phone: this.primaryPhone,
            }
            searchData = {
                AddressLine1: this.SelBillingStreet,
                Locality: this.SelBillingCity,
                Region: this.SelBillingState,
                PostalCode: this.SelCode,
                PhoneNumber: this.primaryPhone,
                EmailAddress: this.loggedUser.Email,
                LastName: this.loggedUser.LastName
            }
            //this.searchAfxProducts(searchData, this.SelAddId);
            this.newAddress = false;
            this.searchAfxProducts(searchData);
        } else {
            if (this.isInputValid()) {
                this.addressSelected = {
                    Address1: this.AccAddress,
                    City: this.AccCityName,
                    State: this.AccState,
                    PostalCode: this.AccZipCode,
                    Firstname: this.loggedUser.FirstName,
                    Lastname: this.loggedUser.LastName,
                    Email: this.loggedUser.Email,
                    Phone: this.primaryPhone,
                }
                searchData = {
                    AddressLine1: this.AccAddress,
                    Locality: this.AccCityName,
                    Region: this.AccState,
                    PostalCode: this.AccZipCode,
                    PhoneNumber: this.primaryPhone,
                    EmailAddress: this.loggedUser.Email,
                    LastName: this.loggedUser.LastName
                }
                //this.saveSearchAddress(searchData);
                this.newAddress = true;
                this.searchAfxProducts(searchData);
            } else {                
                this.isSearching = false;
            }
        }
    }

    searchResult;
    searchProducts;
    noProducts;

    searchAfxProducts(input) {
        searchAssetsFromAFX(input)
            .then(result => {
                this.searchResult = JSON.parse(result);
                console.log('Product search results: ', this.searchResult);
                this.saveAfxLocation(this.searchResult.Assets,input);
            })
            .catch(error => {
                this.error = error;
                console.error(error);
                this.isDelModal = false;
                this.isSearching = false;
            });
    }

    saveAfxLocation(assetList, address) {        
        if(this.newAddress) {
            this.saveSearchAddress(assetList,address);
        } else {
            this.saveAfxProducts(assetList, this.selectedAddress.Id);
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
        let assets = [];
        let assetCount = 1;
        let validAssetList = assetList.filter(el => !el.IsAccessory);
        if(validAssetList.length > 0) {
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
                            this.setNewLocation(addressId);
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
            this.setNewLocation(addressId);
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

    setNewLocation(addressId) {
        Mya_UpAssetAddress({ NewAccId: addressId, ContactLocation_Id: this.ContactLocationId })
            .then(response => {
                this.isDelModal = false;
                return refreshApex(this.wiredAddressResult)
                    .then(res => {
                        return refreshApex(this.AssetList)
                    })
            })
            .catch(error => {
                console.log(error);
                this.isDelModal = false;
                this.isSearching = false;
            })
    }

}