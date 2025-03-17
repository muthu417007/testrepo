import { LightningElement, api, track, wire } from 'lwc';
// Templates
import Cafe from "./mya_AccountDetails_Cafe.html";
import GEA from "./mya_AccountDetails_GEA.html";
import Haier from "./mya_AccountDetails_Haier.html";
import Bodewell from "./mya_AccountDetails_Bodewell.html";
// Style loader
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
// Style files
import MYAGEACSS from '@salesforce/resourceUrl/MYAGEACSS';
import MYACAFECSS from '@salesforce/resourceUrl/MYACAFECSS';
import MYAHAIERCSS from '@salesforce/resourceUrl/MYAHAIERCSS';
// LDS
import { createRecord, updateRecord, deleteRecord, getRecord } from 'lightning/uiRecordApi';
// User ID
import USER_ID from '@salesforce/user/Id';

// Apex methods
import getUserDetails from '@salesforce/apex/MYA_UserDetailsController.getUserDetails';
import getContactDetails from '@salesforce/apex/MYA_UserDetailsController.getContactDetails';
import updateContactPoint from '@salesforce/apex/MYA_UserDetailsController.updateContactPoint';
import getContactPointByContactId from '@salesforce/apex/MYA_UserDetailsController.getContactPointByContactId';
import setPrimaryOnDelete from '@salesforce/apex/MYA_UserDetailsController.setPrimaryOnDelete';
import setPrimaryOnCreate from '@salesforce/apex/MYA_UserDetailsController.setPrimaryOnCreate';
import createContact from '@salesforce/apex/MYA_UserDetailsController.createContact';
import updateEmail from '@salesforce/apex/MYA_UserDetailsController.updateEmail';
import twoFactorMethodsInfo from '@salesforce/apex/MYA_UserDetailsController.twoFactorMethodsInfo';
import sendEmailVerification from '@salesforce/apex/MYA_UserDetailsController.sendEmailVerification';

import getSysAdminContactDetails from '@salesforce/apex/MYA_UserDetailsController.getContactDetailsByUserId';
import getSysAdminContactPointsDetails from '@salesforce/apex/MYA_UserDetailsController.getContactPointByUserId';
import { subscribe,publish, MessageContext } from 'lightning/messageService';
import userInformations from '@salesforce/messageChannel/User_Informations__c';
// Object References
import ID_FIELD from '@salesforce/schema/Contact.Id';
import FIRSTNAME_FIELD from '@salesforce/schema/Contact.FirstName';
import LASTNAME_FIELD from '@salesforce/schema/Contact.LastName';
import EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import CONTACT_POINT_OBJECT from "@salesforce/schema/Contact_Point__c";
import CONTACT_POINT_CONTACT_ID from "@salesforce/schema/Contact_Point__c.Id";
import CONTACT_POINT_CONTACT_TYPE from "@salesforce/schema/Contact_Point__c.ContactType__c";
import CONTACT_POINT_IS_PRIMARY from "@salesforce/schema/Contact_Point__c.MYAISPrimary__c";
import CONTACT_POINT_MYA_INCLUDE from "@salesforce/schema/Contact_Point__c.MYA_Included__c";
import CONTACT_POINT_PHONE from "@salesforce/schema/Contact_Point__c.Phone__c";
import CONTACT_POINT_CONTACT_REF from "@salesforce/schema/Contact_Point__c.Contact__c";
import CONTACT_POINT_MYA_DELETED from "@salesforce/schema/Contact_Point__c.MYA_IsDeleted__c";
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';

export default class Mya_AccountDetails extends NavigationMixin(LightningElement) {
    // Config properties

    @api brand = 'GEA';
    @api pageTitleLabel;
    @api loginProfile;
    @api fullNameLabel;
    @api firstNameLabel;
    @api lastNameLabel;
    @api editNameSuccessLabel;
    @api emailAddressLabel;
    @api emailAddressEditLabel;
    @api editEmailSuccessLabel;
    @api passwordLabel;
    @api primaryPhoneNumberLabel;
    @api primaryPhoneNumberEditLabel;
    @api editPrimaryPhoneSuccessLabel;
    @api additionalPhoneNumberLabel;
    @api additionalPhoneNumberEditLabel;
    @api editPhoneSuccessLabel;
    @api addPhoneNumberLabel;
    @api addPhoneNumberEditLabel;
    @api addPhoneSuccessLabel;
    @api editPhoneValidationLabel;
    @api editOptionLabel;
    @api removeOptionLabel;
    @api phoneNumberConsentMessage;
    @api removePhoneModalHeader;
    @api removePhoneModalBody;
    @api removePhoneModalSubmitLabel;
    @api removePhoneModalCancelLabel;

    //User Details
    currentUser;
    currentUserName;
    currentUserEmailId;
    currentUserFirst;
    currentUserLastName;
    currentUserContactId;
    // common variables
    isLoading = true;
    fieldValue = '';
    selectedField = {};
    //basic info variables
    isNameEditOpen = false;
    isEmailEditOpen = false;
    isPasswordEditOpen = false;
    isNameUpdated = false;
    isEmailUpdated = false;
    isEmailUpdatedExist = false;
    isEmailVerified = true;
    emailVerificationSent = false;
    contactName;
    contactEmail;
    firstName;
    lastName;
    email;
    contact;
    contactFields;
    paymentInfo;
    namePattern = '[A-Za-z]*';
    passwordPattern = '(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}';
    emailPattern = '[A-Za-z0-9._+-]+@[a-z0-9-]+.[a-z]{2,}$';
    emailPatternValidationMessage = 'Please enter a valid email';

    // phone section variables
    @track additionalPhoneList;
    primaryPhone;
    primaryPhoneId;
    editedPrimaryPhone;
    additionalPhone;
    selectedRecordId;
    isPrimaryPhoneEditOpen = false;
    isAdditionalPhoneEditOpen = false;
    isAlreadyExist = false;
    isValidPrimaryPhoneNumber = true;
    isModalOpen = false;
    addPhone = false;
    deleteModalOpen = false;
    isPrimary = false;
    isVisiblePrimaryCheck = false;
    selectedRecord;
    contactPoints;
    contactPointFields;
    
    phonePattern = '[0-9]{3}-[0-9]{3}-[0-9]{4}|[0-9]{10}$';
    phonePatternValidationMessage = 'Please enter a valid phone number';
    // wire result
    // wireContactResult;
    // wireContactPointsResult;
    wireResult;
    @wire(MessageContext)
    messageContext;

    // CSS loader function
    renderedCallback() {
        if (this.brand == "GEA") {
            /*Promise.all([
                loadStyle(this, MYAGEACSS + '/MYAGEACSS/mya_AccountDetails_GEA.css')
            ]);*/
        } else if (this.brand == "Haier") {
            /*Promise.all([
                loadStyle(this, MYAHAIERCSS + '/MYAHAIERCSS/mya_AccountDetails_Haier.css')
            ]);*/
        } else if (this.brand == "Cafe") {
            /* Promise.all([
                 loadStyle(this, MYACAFECSS + '/MYACAFECSS/mya_AccountDetails_Cafe.css')
             ]);*/
        }
    }
    // UI render based on brand and user status
    render() {
        console.log('BrandValue 156',this.brand);
        if (this.brand == "GEA") {
            return GEA;
        } else if (this.brand == "Haier") {
            return Haier;
        } else if (this.brand == "Cafe") {
            return Cafe;
        } else if (this.brand == "Bodewell") {
            console.log('Brandvalue is Bodewell')
            return Bodewell;
        }
    }

    @wire(getUserDetails, { UserId: USER_ID })
    userDetails(result) {
        this.wireResult = result;
        if (result.data) {
            this.currentUser = result.data[0];
            this.currentUserName = this.currentUser.Name;
            this.currentUserEmailId = this.currentUser.Email;
            this.currentUserFirst = this.currentUser.FirstName;
            this.currentUserLastName = this.currentUser.LastName;
            if (this.currentUser.ContactId) {
                this.currentUserContactId = this.currentUser.ContactId;
                this.getUserContactDetails();

                this.getUserContactPointDetails();
                //console.log('phone ' _+ this.primaryPhone);
            } else {
                this.getSysAdminUserContactDetails();
                this.getSysAdminUserContactPointDetails();
            }

        } else if (result.error) {
            this.error = error;
            console.error('getRecord -> else if error response :', error);
        }
    }

    refreshDetails() {
        if (this.currentUser.ContactId) {
            this.getUserContactDetails();
            this.getUserContactPointDetails();
        } else {
            this.getSysAdminUserContactDetails();
            this.getSysAdminUserContactPointDetails();
        }
    }

    getUserContactDetails() {
        getContactDetails({ ContactId: this.currentUserContactId })
            .then(result => {
                this.contact = result[0];
                this.contactName = this.contact.FirstName + ' ' + this.contact.LastName;
                this.contactEmail = this.contact.Email ? this.contact.Email : this.currentUserEmailId;
                this.isLoading = false;
            })
            .catch(error => {
                this.error = error;
                console.error('getContactDetails -> error response :', error);
                this.isLoading = false;
            });

        twoFactorMethodsInfo({ userId: USER_ID })
            .then(result => {

                this.emailVerificationSent = false;
                if (result) {
                    this.isEmailVerified = result.HasUserVerifiedEmailAddress;
                }
            })
            .catch(error => {
                this.error = error;
                console.error('isEmailVerified -> error response :', error);
                this.isLoading = false;
            });
    }

    getUserContactPointDetails() {
        getContactPointByContactId({ ContactId: this.currentUserContactId })
            .then(result => {
                this.contactPoints = result;
                const primary = this.contactPoints.filter(el => el.MYAISPrimary__c)[0];
                if (primary) {
                    this.primaryPhone = primary.Phone__c;
                    this.primaryPhoneId = primary.Id;
                }
                else{
                    this.primaryPhone =null;
                }
                const additionalList = this.contactPoints.filter(el => !el.MYAISPrimary__c);
                this.additionalPhoneList = [];
                additionalList.forEach(item => {
                    var field = {
                        Id: item.Id,
                        Phone__c: item.Phone__c,
                        IsEdit: false,
                        IsUpdated: false,
                        IsValid: true
                    }
                    this.additionalPhoneList.push(field);
                });
                this.isLoading = false;
            })
            .catch(error => {
                this.error = error;
                console.error('getContactPointByContactId -> error response :', error);
                this.isLoading = false;
            });
    }

    getSysAdminUserContactDetails() {
        getSysAdminContactDetails()
            .then(result => {
                this.contact = result[0];
                this.currentUserContactId = this.contact.Id;
                this.contactName = this.contact.FirstName + ' ' + this.contact.LastName;
                this.contactEmail = this.contact.Email ? this.contact.Email : this.currentUserEmailId;
            })
            .catch(error => {
                this.error = error;
                console.error('getContactDetails -> error response :', error);
            });
    }

    getSysAdminUserContactPointDetails() {
        getSysAdminContactPointsDetails()
            .then(result => {
                this.contactPoints = result;
                const primary = this.contactPoints.filter(el => el.MYAISPrimary__c)[0];
                if (primary) {
                    this.primaryPhone = primary.Phone__c;
                    this.primaryPhoneId = primary.Id;
                }
                const additionalList = this.contactPoints.filter(el => !el.MYAISPrimary__c);
                this.additionalPhoneList = [];
                additionalList.forEach(item => {
                    var field = {
                        Id: item.Id,
                        Phone__c: item.Phone__c,
                        IsEdit: false,
                        IsUpdated: false,
                        IsValid: true
                    }
                    this.additionalPhoneList.push(field);
                });
            })
            .catch(error => {
                this.error = error;
                console.error('getContactPointByContactId -> error response :', error);
            });
    }

    sendVerificationEmail() {
        let url = window.location.href;
        let experience = window.location.pathname.split('/')[1];
        sendEmailVerification({ userId: USER_ID, experienceName: experience, callbackUrl: url })
            .then(result => {
                this.emailVerificationSent = true;
            })
            .catch(error => {
                this.error = error;
                console.error('sendEmailVerification -> error response :', error);
                this.isLoading = false;
            });
    }

    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }

    handleNameEdit(event) {
        this.isNameEditOpen = true;
        this.firstName = this.contact.FirstName;
        this.lastName = this.contact.LastName;
    }

    handleFirstNameChange(event) {
        this.firstName = event.detail.value;
        this.contactName = this.firstName + ' ' + this.lastName;
    }

    handleLastNameChange(event) {
        this.lastName = event.detail.value;
        this.contactName = this.firstName + ' ' + this.lastName;
    }

    handleNameEditSubmit(event) {
        this.isLoading = true;
        if (this.isInputValid()) {
            const fields = {};
            fields[ID_FIELD.fieldApiName] = event.target.dataset.id;
            fields[FIRSTNAME_FIELD.fieldApiName] = this.firstName;
            fields[LASTNAME_FIELD.fieldApiName] = this.lastName;
            const recordInput = { fields };
            updateRecord(recordInput)
                .then((res) => {
                    publish(this.messageContext, userInformations, {message: this.firstName});
                    this.isNameUpdated = true;
                    this.isNameEditOpen = false;
                    this.isLoading = false;
                    console.log('Name update event');
                    this.gtmEvent('Name');
                    console.log('Name update fired');
                    setTimeout(() => {
                        this.isNameUpdated = false;
                        this.refreshDetails();
                    }, 5000);
                })
                .catch(error => {
                    console.error('UpdateRecord: ', error);
                });
        }
    }

    handleEmailEdit(event) {
        this.isEmailEditOpen = true;
        this.emai = this.contact.Email;
    }

    handleEmailChange(event) {
        this.email = event.detail.value;
    }

    handleEmailEditSubmit(event) {
        this.isEmailUpdatedExist = false;
        if (this.isInputValid()) {
            this.isLoading = true;
            let input = {
                contactId: this.currentUserContactId,
                email: this.email
            };
            updateEmail(input)
                .then(result => {
                    if (result.Success) {
                        this.isEmailUpdated = true;
                        this.isEmailEditOpen = false;
                        this.isLoading = false;
                        console.log('Email update event');
                        this.gtmEvent('Email');
                        console.log('Email update fired');
                        setTimeout(() => {
                            this.isEmailUpdated = false;
                            this.refreshDetails();
                        }, 5000);
                    } else {
                        this.isLoading = false;
                        this.isEmailUpdatedExist = true;
                        this.editEmailExistLabel = result.Message;
                    }
                }).catch(error => {
                    this.isLoading = false;
                    console.error('Email update error :', error);
                });
        }
    }

    navigateToPasswordReset() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'MYA_Update_Password__c'
            }
        });
    }

    handlePrimaryPhoneEdit(event) {
        this.isPrimaryPhoneEditOpen = true;
        this.editedPrimaryPhone = ('' + this.primaryPhone).replace(/\D/g, '');
    }

    handlePrimaryPhoneChange(event) {
        this.editedPrimaryPhone = event.detail.value;
    }

    handlePrimaryPhoneEditSubmit(event) {
        if (this.isInputValid()) {
            this.isLoading = true;
            let phone = ('' + this.editedPrimaryPhone).replace(/\D/g, '');
            let duplicate = this.contactPoints.filter(el => el.Phone__c == phone && el.Phone__c != this.primaryPhone);
            if (duplicate.length == 0) {
                this.isValidPrimaryPhoneNumber = true;
                const fields = {};
                fields[CONTACT_POINT_CONTACT_ID.fieldApiName] = event.target.dataset.id;
                fields[CONTACT_POINT_PHONE.fieldApiName] = phone;
                const recordInput = { fields };
                updateRecord(recordInput)
                    .then((res) => {
                        this.primaryPhone = this.editedPrimaryPhone;
                        this.isPrimaryPhoneUpdated = true;
                        this.isPrimaryPhoneEditOpen = false;
                        this.isLoading = false;
                        console.log('Primary Phone update event');
                        this.gtmEvent('Primary Phone');
                        console.log('Primary Phone update fired');
                        setTimeout(() => {
                            this.isPrimaryPhoneUpdated = false;
                            this.refreshDetails();
                        }, 5000);
                    })
                    .catch(error => {
                        console.error('updateRecord :', error);
                    });
            } else {
                this.isValidPrimaryPhoneNumber = false;
                this.isLoading = false;
            }
        }
    }

    handleCloseEdit(event) {
        if (event.currentTarget.dataset.value == 'name') {
            this.isNameEditOpen = false;
        }
        if (event.currentTarget.dataset.value == 'email') {
            this.isEmailEditOpen = false;
        }
        if (event.currentTarget.dataset.value == 'primaryPhone') {
            this.isPrimaryPhoneEditOpen = false;
        }
        if (event.currentTarget.dataset.value == 'additionalPhone') {
            let clickedSec = event.currentTarget.dataset.id;
            let clickedItem = this.additionalPhoneList.find((item) => item.Id === clickedSec);
            clickedItem.IsEdit = false;
        }
        if (event.currentTarget.dataset.value == 'newPhone') {
            this.addPhone = false;
        }
    }

    handleAdditionalPhoneEdit(event) {
        let clickedSec = event.currentTarget.dataset.id;
        let clickedItem = this.additionalPhoneList.find((item) => item.Id === clickedSec);
        clickedItem.IsEdit = true;
        clickedItem.EditedPhoneNumber = ('' + clickedItem.Phone__c).replace(/\D/g, '');
    }

    handleAdditionalPhoneChange(event) {
        let clickedSec = event.currentTarget.dataset.id;
        let clickedItem = this.additionalPhoneList.find((item) => item.Id === clickedSec);
        clickedItem.EditedPhoneNumber = event.detail.value;
    }
    isAdditionalPrimary = false;
    updatedContactPointId
    handleAdditionalPhoneEditSubmit(event) {
        let clickedSec = event.currentTarget.dataset.id;
        let clickedItem = this.additionalPhoneList.find((item) => item.Id === clickedSec);
        this.updatedContactPointId = clickedItem.Id;
        this.updatedContactPointId = this.updatedContactPointId.slice(0, -3);
        if (this.isAdditionalPrimary) {
            this.updateContactPointDetails();
            this.isAdditionalPrimary = false;
        } 
        if (this.isInputValid()) {
            this.isLoading = true;
            let phone = ('' + clickedItem.EditedPhoneNumber).replace(/\D/g, '');
            let duplicate = this.contactPoints.filter(el => el.Phone__c == phone && el.Phone__c != clickedItem.Phone__c);
            if (duplicate.length == 0) {
                clickedItem.IsValid = true;
                const fields = {};
                fields[CONTACT_POINT_CONTACT_ID.fieldApiName] = clickedItem.Id;
                fields[CONTACT_POINT_PHONE.fieldApiName] = phone;
                const recordInput = { fields };
                updateRecord(recordInput)
                    .then((res) => {
                        clickedItem.Phone__c = clickedItem.EditedPhoneNumber;
                        clickedItem.IsUpdated = true;
                        clickedItem.IsEdit = false;
                        this.isLoading = false;
                        console.log('Additional Phone update event');
                        this.gtmEvent('Additional Phone');
                        console.log('Additional Phone update fired');
                        this.refreshDetails();
                        // setTimeout(() => {
                        //     this.refreshDetails();
                        // }, 5000);
                    })
                    .catch(error => {
                        console.error('updateRecord :', error);
                    });

            } else {
                clickedItem.IsValid = false;
                this.isLoading = false;
            }
        }
    }

    updateContactPointDetails() {
        updateContactPoint({ updatedContactPointIds: this.updatedContactPointId }).then(result => {
        }).catch(error => {
            console.error('Update Contact Point Error :', error);
        });
    }

    handleAddPhone(event) {
        this.addPhone = true;
        this.isPrimary = false;
        this.additionalPhone = '';
        this.isVisiblePrimaryCheck = this.contactPoints.length > 0 ? true : false;
    }

    handleAddPhoneChange(event) {
        this.additionalPhone = event.detail.value;
    }

    handleCheck(event) {
        this.isPrimary = event.target.checked;
    }

    handleAdditionalPrimaryCheck(event) {
        this.isAdditionalPrimary = event.target.checked;
    }

    handleAddPhoneSubmit(event) {
        if (this.isInputValid()) {
            this.isLoading = true;
            let phone = ('' + this.additionalPhone).replace(/\D/g, '');
            let duplicate = this.contactPoints.filter(el => el.Phone__c == phone);
            if (duplicate.length == 0) {
                this.isAlreadyExist = false;
                const primaryPhone = this.contactPoints.length == 0 ? true : this.isPrimary;

                let input = {
                    contactId: this.currentUserContactId,
                    phone: phone,
                    isPrimary: primaryPhone
                };
                createContact(input)
                    .then(result => {
                        this.addPhone = false;
                        this.isLoading = false;
                        console.log('Phone create event');
                        if (primaryPhone) {
                            this.gtmEvent('Primary Phone');
                        } else {
                            this.gtmEvent('Additional Phone');
                        }
                        console.log('Phone create fired');
                        this.refreshDetails();
                    }).catch(error => {
                        console.error('create contact error :', error);
                    });
            } else {
                this.isAlreadyExist = true;
                this.isLoading = false;
            }
        }
    }

    handlePhoneRemove(event) {
        this.deleteModalOpen = true;
        this.selectedRecordId = event.target.dataset.id;
        const body = document.body;
        body.style.height = '100vh';
        body.style.overflowY = 'hidden';
    }

    closeDeleteModal() {
        this.deleteModalOpen = false;
        const body = document.body;
        body.style.height = '';
        body.style.overflowY = '';
    }

    submitDelete(event) {
        this.isLoading = true;
        if (this.selectedRecordId) {
            const fieldObj = this.contactPoints.filter((item) => item.Id == this.selectedRecordId)[0];
            const fields = {};
            fields[CONTACT_POINT_CONTACT_ID.fieldApiName] = fieldObj.Id;
            fields[CONTACT_POINT_MYA_DELETED.fieldApiName] = true;

            const recordInput = { fields };
            console.log('recordInput',recordInput);
            updateRecord(recordInput)
                .then((res) => {
                    if (fieldObj.MYAISPrimary__c) {
                        this.updatePrimaryPhone();
                    } else {
                        this.isLoading = false;
                        this.gtmEvent('Additional Phone');
                        this.refreshDetails();
                        this.closeDeleteModal();
                    }
                })
                .catch(error => {
                    console.error('updateRecord: ', error);
                });
        } else {
            this.isLoading = false;
        }
    }

    updatePrimaryPhone() {
        setPrimaryOnDelete({ ContactId: this.currentUserContactId })
            .then(result => {
                this.isLoading = false;
                console.log('Primary Phone update event');
                this.gtmEvent('Primary Phone');
                console.log('Primary Phone update fired');
                this.refreshDetails();
                this.closeDeleteModal();
            }).catch(error => {
                console.error('SetPrimaryOnDelete :', error);
            });
    }
    gtmEvent(field) {
        let accountUpdateEvent = new CustomEvent(
            'gtm__myAccountUpdate', {
            detail: {
                fieldUpdated: field
            }
        });
        document.dispatchEvent(
            accountUpdateEvent, {
            bubbles: true,
            composed: true
        });
        console.log('gtmEvent fired.');
    }
}