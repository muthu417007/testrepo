import { LightningElement, api, wire } from 'lwc';
import OrdStatusLogo from '@salesforce/resourceUrl/MYA_GEOrdStatus';
import OrdStatusLogoCafe from '@salesforce/resourceUrl/MYA_CafeOrdStatus';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
//metadata
import getmyaConfigs from '@salesforce/apex/Mya_ProductDetails.getmyaConfigs';

// Templates
import GEA from "./mya_checkOrderStatus.html";
import Cafe from "./mya_checkOrderStatusCafe.html";
import Haier from "./mya_checkOrderStatusHaier.html";

//css
// import MYAGEACSS from '@salesforce/resourceUrl/MYAGEACSS';
// import MYACAFECSS from '@salesforce/resourceUrl/MYACAFECSS';
// import MYAHAIERCSS from '@salesforce/resourceUrl/MYAHAIERCSS';
// import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class Mya_checkOrderStatus extends NavigationMixin(LightningElement)
{
    OSL = OrdStatusLogo;
    OSLC = OrdStatusLogoCafe;
    emailAdd;
    refNo;
    recaptchaResponse;
    generalError;
    PageLinks = [];
    @api brand = 'GEA';
    @api pageTitleLabel;
    @api findOrderButtonLabel;
    @api referenceNoLabel;
    @api emailAddressLabel;

    // UI render based on brand and user status
    render() {
        if (this.brand == "GEA") {
            return GEA;
        }
        else if (this.brand == "Haier") {
            return Haier;
        }
        else if (this.brand == "Cafe") {
            return Cafe;
        }
    }

    // CSS loader function
    // renderedCallback() {
    //     if (this.brand == "GEA") {
    //         Promise.all([
    //             loadStyle(this, MYAGEACSS + '/MYAGEACSS/mya_checkOrderStatus.css')
    //         ]);
    //     }
    //     else if (this.brand == "Haier") {
    //         Promise.all([
    //             loadStyle(this, MYAHAIERCSS + '/MYAHAIERCSS/mya_checkOrderStatusHaier.css')
    //         ]);
    //     }
    //     else if (this.brand == "Cafe") {
    //         Promise.all([
    //             loadStyle(this, MYACAFECSS + '/MYACAFECSS/mya_checkOrderStatusCafe.css')
    //         ]);
    //     }
    // }

    
    @wire(getmyaConfigs)
    Links({ data, err }) {
        if (data) {
            this.PageLinks = data;
        }
        if (err) {
            console.log(err)
        }
    }

    RefNo(event) {
        this.refNo = event.target.value;
    }
    EmailAdd(event) {
        this.emailAdd = event.target.value;
    }
    onVerified(event) {
        this.recaptchaResponse = event.detail.response;
        this.generalError = false;
    }

    HandleLogin(event) {

        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'MYA_My_Orders__c'
            },
            state: {
            }
        });
    }

    handleFindOrder(event) {
        if (this.recaptchaResponse != null) {
            if (this.refNo != null && this.emailAdd != null) {
                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes:
                    {
                        name: 'MYA_Guest_Order_Details__c'
                    },
                    state:
                    {
                        recordid: this.refNo,
                        recordem: this.emailAdd
                    }
                });
            }
        }
    }
}