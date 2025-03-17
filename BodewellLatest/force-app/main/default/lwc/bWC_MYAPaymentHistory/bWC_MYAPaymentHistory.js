import { LightningElement, api } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import getBodewellSubscriptionPayments from '@salesforce/apex/BWC_MYA_Subscriptions.getBodewellSubscriptionPayments';
import BASE_PATH from '@salesforce/community/basePath';

export default class BWC_MYAPaymentHistory extends LightningElement {

    @api subscriptionLink = '/mya-my-subscriptions';
    subscriptionPageUrl;
    basePath = BASE_PATH;
    loggedInUserId = USER_ID;
    bodewellMembershipDetails;
    bodewellMembershipPayment;
    bodewellMembershipSub;
    bodewellMembershipPaymentSummary;
    paymentHistoryInfo;
    paymentInfo;
    hasPpaymentHistory = false;

    connectedCallback() {
        this.subscriptionPageUrl = this.basePath + this.subscriptionLink;
        this.getSubscriptionSubscriptionInfo(this.loggedInUserId);
    }

    getSubscriptionSubscriptionInfo(input) {
        getBodewellSubscriptionPayments({ userId: input })
            .then(response => {
                if (response.success) {
                    this.bodewellMembershipDetails = response.data.accountInfo;
                    this.bodewellMembershipSub = response.data.accSubInfo;
                    this.bodewellMembershipPayment = response.data.cardInfo;
                    this.bodewellMembershipPaymentSummary = response.data.paymentSummaryInfo;
                    this.setpaymentHistoryInfo();
                }
            }).catch(error => {
                console.error('error : ', error);
            });
    }

    setpaymentHistoryInfo() {

        this.paymentInfo = this.bodewellMembershipPaymentSummary.map((item, index) => {
            return {
                id: index,
                orderId: item.OrderSummary.OriginalOrderId,
                paymentMethodId: item.PaymentMethodId,
                displayCardNumber: this.bodewellMembershipPayment.filter(elm => elm.Id == item.PaymentMethodId)[0].DisplayCardNumber,
                cardType: this.bodewellMembershipPayment.filter(elm => elm.Id == item.PaymentMethodId)[0].CardType
            }
        });

        this.paymentHistoryInfo = this.bodewellMembershipSub.map((item, index) => {
            return {
                id: index,
                date: item.Start_Date__c,
                description: item.Order_Product__r.Product2.Name,
                method: this.paymentInfo.filter(it => it.orderId == item.Order__c)[0].cardType + this.paymentInfo.filter(it => it.orderId == item.Order__c)[0].displayCardNumber,
                cost: item.Amount__c,
                total: item.Amount__c
            }
        });
        this.hasPpaymentHistory = this.paymentHistoryInfo.length > 0 ? true : false;
    }

}