import { LightningElement,api,track,wire } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import getBodewellSubscription from '@salesforce/apex/BWC_MYA_Subscriptions.getBodewellSubscription'; 
import getUserInfoViaAccountId from '@salesforce/apex/BWC_MYA_Subscriptions.getUserInfoViaAccountId'; 
import { NavigationMixin } from "lightning/navigation";

//import BASE_PATH from '@salesforce/community/basePath';
 
export default class Bwc_MYA_Subscriptions extends NavigationMixin(LightningElement) {

    @api paymentHistoryLink = '/mya-payment-history';    
    paymentHistoryLinkURL;
    //basePath = BASE_PATH;
    loggedInUserId = USER_ID;
    loggedInUserAccountId;
    bodewellMembershipDetails;
    bodewellMembershipPayment;
    bodewellMembershipStartDate;
    bodewellMembershipExpDate;
    bodewellMembershipSub;
    expanded = false;
    isLoading = true;
    isBodewellMember = false;
    //Agent S
    @track isEnableUrl = true;
    @track enableManageSubscription = true;
    @api recordId;
    @api isCancelButton;
    //Agent I


    async connectedCallback() {
        //Agent S
        this.isEnableUrl = this.isCancelButton ? this.isCancelButton : false;
        this.enableManageSubscription = (this.isCancelButton || this.recordId) ? false : true;
        if(this.recordId){
            this.expanded = true;
            this.isLoading = false;
            const user = await getUserInfoViaAccountId({accountId : this.recordId});
            this.loggedInUserId = user.Id;
        }
        //Agent E
        this.getSubscriptionInfo(this.loggedInUserId);
        //this.paymentHistoryLinkURL = this.basePath + this.paymentHistoryLink;
    }

    //Agent S
    get componentCss(){
        return this.recordId ? 'background-color:white;' : 'background-color:white;width:50rem;margin:auto;';
    }
    //Agent E

    getSubscriptionInfo(input) {
        getBodewellSubscription({ userId: input })
            .then(response => {
                if(response.success){
                    this.bodewellMembershipDetails = response.data.accountInfo;
                    this.bodewellMembershipSub = response.data.accSubInfo;
                    this.bodewellMembershipPayment = response.data.cardInfo;
                    this.isLoading = false;
                    if(this.bodewellMembershipDetails) {                    
                        this.isBodewellMember = this.bodewellMembershipDetails.Bodewell_Member__c;
                        console.log('bodewellMembershipDetails',this.bodewellMembershipDetails);
                        this.bodewellMembershipStartDate = this.getDate(this.bodewellMembershipDetails.Bodewell_Member_Start_Date__c);
                        this.bodewellMembershipExpDate = this.getDate(this.bodewellMembershipDetails.Bodewell_Member_Expiration_Date__c);
                        this.bodewellMemebrshipCost = this.getCost(this.bodewellMembershipSub?.Order_Product__r.UnitPrice);
                    }
                }                
            }).catch(error => {                
                console.error('error : ', error);
            });
    }

    getCost(cost) {
        return '$' + cost + '/Yearly';
    }

    getDate(dateval) {
        let formattedDate; 
        const date = new Date(dateval);        
        formattedDate = date.toLocaleDateString('en-GB', {
                year: 'numeric',
                month: '2-digit',
                day: '2-digit'
            });
        return formattedDate;
    }

    handleAccordianView() {
        if(this.recordId){
            this.expanded = true;
        }
        else{
            this.expanded = !this.expanded;
        }
    }

    //Agent S
    paymentHistoryRedirect(){
        if(!this.recordId){
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "MYA_Payment_History__c"
                }
            });
        }
    }

    get containerServiceCss(){
        return (this.recordId && !this.isCancelButton) ? 'justify-content: center;' : '';
    }
    get bodewellServiceImageCss(){
        return (this.recordId && !this.isCancelButton) ? 'width: 88px;' : '';
    }
    get imageHeight(){
        return (this.recordId && !this.isCancelButton) ? 'height: 60px;' : '';
    }
    get containerSizing(){
        return (this.recordId && !this.isCancelButton) ? 'padding-left: 0px; margin-right: 16px;' : '';
    }
    //Agent E
}