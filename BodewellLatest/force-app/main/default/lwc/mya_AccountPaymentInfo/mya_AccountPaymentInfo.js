import { LightningElement, wire, api } from 'lwc';
// Templates
import Cafe from "./mya_AccountPaymentInfo_Cafe.html";
import GEA from "./mya_AccountPaymentInfo_GEA.html";
import Haier from "./mya_AccountPaymentInfo_Haier.html";
import Bodewell from "./mya_AccountPaymentInfo_Bodewell.html";

// User ID
import USER_ID from '@salesforce/user/Id';
import getUserDetails from '@salesforce/apex/MYA_UserDetailsController.getUserDetails';
import getPaymentInfo from '@salesforce/apex/MYA_PartsAPIController.getPaymentInfo';
// Base path
import basePath from '@salesforce/community/basePath';

export default class Mya_AccountPaymentInfo extends LightningElement {

    @api brand = 'GEA';
    currentUser;
    currentUserEmailId;
    error;
    paymentInfo;
    wireResult;
    editPaymentUrl;
    UID;
    isDeleteModalOpen = false;


    // UI render based on brand and user status
    render() {
        console.log('BrandValue line29',this.brand);
        if (this.brand == "GEA") {
            return GEA;
        } else if (this.brand == "Haier") {
            return Haier;
        } else if (this.brand == "Cafe") {
            return Cafe;
        }  else if (this.brand == "Bodewell") {
            console.log('brand paymentinfo',this.brand);
            return Bodewell;
        }
    }

    @wire(getUserDetails, { UserId: USER_ID })
    userDetails(result) {
        this.wireResult = result;
        if (result.data) {
            this.currentUser = result.data[0];
            this.currentUserEmailId = this.currentUser.Email;
            if (this.currentUserEmailId) {
                this.getUserPaymentInfo(this.currentUserEmailId);
            } else {
                this.getUserPaymentInfo(this.currentUserEmailId);
            }

        } else if (result.error) {
            this.error = error;
            console.error('getUserDetails -> else if error response :', error);
        }
    }

    getUserPaymentInfo(email) {
       // let emailInput = 'honey.shetty@geappliances.com';
        let emailInput = email;
        getPaymentInfo({ Email: emailInput })
            .then(result => {
                this.paymentInfo = null;
                if (result.Success) {
                    let resObj = JSON.parse(result.Response);
                    if (resObj[0][0] == "billing_details" && resObj[1][0] == "card_details" && resObj[0][1].billAdrs1 != '' && resObj[1][1].lastFourDgt != '') {
                        this.paymentInfo = {
                            billingDetails: resObj[0][1],
                            cardDetails: resObj[1][1]
                        }
                    }
                    this.UID = result.UID;
                    this.editPaymentUrl = window.location.origin + '/' + result.EditPaymentUrl;
                }
                console.log('this.paymentInfo: ', this.paymentInfo);
            })
            .catch(error => {
                this.error = error;
                this.paymentInfo = null;
                console.error(error);
            });
    }

    editPayment(event) {
        let form = this.template.querySelector('form');
        form.submit();
    }

    handleFormSubmit() {
        console.log('Success')
    }

    handleDelete() {
        this.isDeleteModalOpen = true;
    }

    confirmDelete() {
        this.isDeleteModalOpen = false;
    }

    closeDeleteModal() {
        this.isDeleteModalOpen = false;
    }
}