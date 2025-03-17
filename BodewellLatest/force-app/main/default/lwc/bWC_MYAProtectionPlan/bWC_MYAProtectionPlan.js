import { LightningElement, track, api   } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import getProductProtectionSubscription from '@salesforce/apex/BWC_MYA_Subscriptions.getProductProtectionSubscription';
import getUserInfoViaAccountId from '@salesforce/apex/BWC_MYA_Subscriptions.getUserInfoViaAccountId'; 
import cancel from '@salesforce/apex/BWC_ManageSubscription.cancel';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import ToastContainer from 'lightning/toastContainer';
//import BASE_PATH from '@salesforce/community/basePath';

export default class BWC_MYAProtectionPlan extends LightningElement {

    //basePath = BASE_PATH;
    loggedInUserId = USER_ID;
    isLoading = false;
    isBodewellMember = true;
    expanded = false;
    hasProtectionPlans = false;
    @track protectionPlans = [];

    //Agent S
    @track isEnableUrl = true;
    @api recordId;
    //Agent I

    async connectedCallback() {
        this.isLoading = true;
        const toastContainer = ToastContainer.instance();
        toastContainer.maxToasts = 10;
        toastContainer.toastPosition = 'top-middle';
        //Agent S
        if(this.recordId){
            this.isLoading = false;
            const user = await getUserInfoViaAccountId({accountId : this.recordId});
            this.loggedInUserId = user.Id;
            this.isEnableUrl = false;
        }
        //Agent E
        this.getProtectionPlanInfo(this.loggedInUserId);
    }
    @api
    showErrorToastMessage(message) {
       this.dispatchEvent( new ShowToastEvent({
            title: ' ',
            message: message,
            variant: 'error',     
        })
        );
    }

    getProtectionPlanInfo(input) {
        getProductProtectionSubscription({ userId: input })
            .then(response => {
                if (response.success) {
                    console.log('getProductProtectionSubscription => ', response);
                    let accountInfo = response.data.accountInfo;
                    let accountSubInfo = response.data.accSubInfo;
                    let planInfo = response.data.planInfo;
                    let oderSummarysInfo = response.data.oderSummarysInfo;
                    let cardInfo = response.data.cardInfo;

                    let subPlan = accountSubInfo.map((item, index) => {
                        return {
                            index: index + 1,
                            order: item.Order__c,
                            id: item.Id,
                            image: item.Order_Product__r.Product2.BWC_Main_Image__c,
                            title: this.getTitle(planInfo, item.Order_Product__r.cart_Item_Id__c),
                            product: item.Order_Product__r.Product2.BWC_Product_Marketing_Description__c,
                            expanded: false,
                            activationDate: this.getDate(item.Order_Product__r.BWC_Start_Date__c, false, planInfo, item.Order_Product__r.cart_Item_Id__c),
                            renewalDate: this.getDate(item.Order_Product__r.BWC_Start_Date__c, true, planInfo, item.Order_Product__r.cart_Item_Id__c),
                            cost: this.getPrice(planInfo, item.Order_Product__r.cart_Item_Id__c),
                            lastPayment: this.getDate(item.Order_Product__r.BWC_Start_Date__c, false, planInfo, item.Order_Product__r.cart_Item_Id__c),
                            paymentMethod: this.getPaymentMethod(item,cardInfo,oderSummarysInfo)

                        }
                    });
                    this.protectionPlans = subPlan;
                    if(this.protectionPlans.length > 0) {                        
                        this.hasProtectionPlans = true;
                    }
                    console.log('subPlan = > ', subPlan);
                    this.isLoading = false;
                }
            }).catch(error => {
                console.error('error : ', error);
            });
    }

    getTitle(planInfo, cartItem) {
        debugger;
        let desc = planInfo.bwcServiceInfo.filter(item => item.Cart_Item__c == cartItem)[0];
        if (desc) {
            return desc.BWC_Service_Description__c;
        } else {
            return null;
        }
    }

    getPrice(planInfo, cartItem) {
        debugger;
        let plan = planInfo.bwcServiceInfo.filter(item => item.Cart_Item__c == cartItem)[0];
        if (plan) {
            if(plan.BWC_SKU__c == 'BDC1') {
                return '$' + plan.BWC_Service_Price__c + '/Month';
            } else {
                return '$' + plan.BWC_Service_Price__c;
            }
        } else {
            return null;
        }
    }

    getPaymentMethod(accSub, cardInfo, orderInfo) {
        debugger;
        let paymentMethod;
        let payment;        
        let orderSum = orderInfo.filter(item => item.OrderSummary.OriginalOrderId == accSub.Order__c);
        if(orderSum) {
            payment = orderSum[0].PaymentMethodId;
            let cardDetails = cardInfo.filter(item => item.Id == payment);
            if(cardDetails) {
                debugger;
                paymentMethod = cardDetails[0].CardType + ' ending in ' + cardDetails[0].DisplayCardNumber.substr(cardDetails[0].DisplayCardNumber.length - 8);
            }
        }        
        return paymentMethod;
    }

    getDate(dateval, isExp, planInfo, cartid) {
        let formattedDate; 
        const date = new Date(dateval);
        if(isExp) {
            let plan = planInfo.bwcServiceInfo.filter(item => item.Cart_Item__c == cartid)[0];
            if(plan.BWC_SKU__c == 'BD483') {
                date.setMonth(date.getMonth() + 48);
            } else if(plan.BWC_SKU__c == 'BD245') {
                date.setMonth(date.getMonth() + 24);
            } else if(plan.BWC_SKU__c == 'BD125') {
                date.setMonth(date.getMonth() + 12);
            } else {
                date.setMonth(date.getMonth() + 1);
            }
            formattedDate = date.toLocaleDateString('en-GB', {
                year: 'numeric',
                month: '2-digit',
                day: '2-digit'
            });
        } else {
            formattedDate = date.toLocaleDateString('en-GB', {
                year: 'numeric',
                month: '2-digit',
                day: '2-digit'
            });
        }
        return formattedDate;
    }

    handleAccordianView(event) {
        let clickedSec = event.currentTarget.dataset.id;
        let clickedItem = this.protectionPlans.find((item) => item.id === clickedSec);
        clickedItem.expanded = !clickedItem.expanded;
    }

    cancelMembership()
    {
        this.isLoading = true;
        console.log('In cancel Membership');
        console.log('loggedInUserId - ', this.loggedInUserId);
        cancel({userId : this.loggedInUserId}).then(result => {
            console.log('result - ', result);
            if(result == 'error')
            {
                this.showErrorToastMessage('Something went wrong while cancelling membership, please contact system administrator');
            }
            this.isLoading = false;
        }).catch(error => {
            console.log('error - ', error);
            this.isLoading = false;
            
        });
    }

}