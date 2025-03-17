import { LightningElement, api, track } from 'lwc';
import applyReferalCodeOnCart from '@salesforce/apex/BWC_ReferralCodeController.applyReferalCodeOnCart';
import removeReferralCodeOnCart from '@salesforce/apex/BWC_ReferralCodeController.removeReferralCodeOnCart';

export default class Bwc_referalCode extends LightningElement {
    @api cartDetail;
    @track referalCode;
    referralCodeisValid ;
    result;
    startSpinner;
    generalInfo = 'A referral code is a number you may have received from a service technician or customer service representative.';
    oneReferralCodeMsg = 'Only one referral code can be applied per order.'
    inputDisabled = false;
    showApplyButton = true;
    delete1 = false;
    referralCodeRemoved;

    connectedCallback(){
        console.log('Cart Details Are > ',this.cartDetail);
    }

    handleInputValue(event){
        this.referalCode = event.target.value;
        console.log('Referal Code Is > ',this.referalCode);
    }

    async handleReferalClick(){
        console.log('Ref Code '+this.referalCode);
        this.inputDisabled = true;
        this.showApplyButton = false;
        this.startSpinner = true;
        this.result = await applyReferalCodeOnCart({referralCode: this.referalCode});
        console.log('Referal Code is > ',this.result);
        this.startSpinner = false;
        if(this.result == 'TRUE'){
            console.log('+++Inside True');
            this.referralCodeisValid = true;
        }
        else if(this.result == 'FALSE'){
            console.log('+++ Inside False');
            this.referralCodeisValid = false;
        }
        console.log('++++ referralCodeisValid'+this.referralCodeisValid)
    }

    async handleRemoveRefCode(){
        if(this.referralCodeisValid == false){
            this.inputDisabled = false;
            this.result = null;
            this.referralCodeisValid = null;
            this.showApplyButton = true;
        }
        else if(this.referralCodeisValid == true){
            this.inputDisabled = false;
            this.result = null;
            this.referralCodeisValid = null;
            this.showApplyButton = true;
            //this.referralCodeRemoved = await removeReferralCodeOnCart({referralCode : this.referalCode}); 
        }
        


    }
}