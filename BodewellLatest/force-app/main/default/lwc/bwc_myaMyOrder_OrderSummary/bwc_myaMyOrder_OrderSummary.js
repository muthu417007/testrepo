import { LightningElement, wire, api, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getOrderDeliveryPaymentSummary from '@salesforce/apex/BWC_OrderConfirmationController.getOrderDeliveryPaymentSummary';
import getBodewellOrdersItems from '@salesforce/apex/BWC_OrderConfirmationController.getBodewellOrdersItems';
import getBuyerGroup from '@salesforce/apex/BWC_CartController.getBuyerGroup';
import { getRecord } from 'lightning/uiRecordApi';
import User_Id from '@salesforce/user/Id';
import UserAccountIdFIELD from '@salesforce/schema/User.AccountId';
import bwc_getRelatedCartItemAll from '@salesforce/apex/BWC_ProductViewServicesController.bwc_getRelatedCartItemAll';
//SHubhada Changes
import { publish, subscribe, MessageContext } from "lightning/messageService";

//Shubhada Changes
import memberChannel from '@salesforce/messageChannel/bwc_membership__c';
   /**
 * @description A component used to show order summary on order page
 */
export default class Bwc_myaMyOrder_OrderSummary extends LightningElement {
    _rid;
    currencyCode='USD';
    totalPayment = 0.0;
    totalFinal = 0.0;
    totalCart = 0.0;
    orderPaymentDetails;
    orderSummaryLabel = "Order Summary";
    bodewellOrderListItems;
    shipToHome;
    homeDeliveryItem
    partsMethod;
    partsFee=0.0;
    hdFee=0.0;

    partShipppingFlag;
    _installationFee=0.0;
    memberInstallationFee=0.0;
    protectionPlanFee=0.0;
    protectionPlanFeeMember=0.0;
    zipCode;
    _cartId;
    isMember;
    _accountId;
    @api
    get rid() {
        return this._rid;
    }
    set rid(value) {
        this._rid = value;
        console.log('this.rid===' + this._rid);
        //this.getRelatedServices();
    }
   @track  subTotal=0.0;
   @track subtotalFinal=0.0;
    @wire(getOrderDeliveryPaymentSummary, { orderSummaryId: '$_rid' })
    BodewellPaymentSummary({ data, err }) {
        console.log(' PaymentSummary Orders from order Summary', data);
        if (data) {
            this.orderPaymentDetails = data;
            let valueAll = this.orderPaymentDetails.map((item) => {
                this.totalPayment = item.OrderSummary.GrandTotalAmount;
               this.subTotal= item.OrderSummary.TotalAdjustedProductAmount;
                this.totalCart = item.OrderSummary.GrandTotalAmount;
                this._cartId = item.OrderSummary.BWC_Cart_Id__c;
                console.log('Total Ammount===' + this.totalPayment);
                console.log('Total _cartId===' + this._cartId);
                this.calculateTotal();
            })

        }
        else {

            this._rid = this._rid + ' ';
            console.log('PaymentSummary==>' + JSON.stringify(err))

        }
    }

    calculateTotal() {
        this.totalFinal = 0.0;

        console.log('Total totalCart===' + this.totalCart);
        console.log('Total memberInstallationFee===' + this.memberInstallationFee);
        console.log('Total _installationFee===' + this._installationFee);
        console.log('Total hdFee===' + this.hdFee);
        console.log('Total partsFee===' + this.partsFee);
        if (this.isMember) {
            if (this.partsFee === 7.95) {
                this.totalFinal = (parseFloat(this.totalCart) + parseFloat(this.memberInstallationFee)+parseFloat(this.protectionPlanFeeMember)).toFixed(2);

            }
            else {

                this.totalFinal = (parseFloat(this.totalCart) + parseFloat(this.memberInstallationFee) + parseFloat(this.partsFee)+parseFloat(this.protectionPlanFeeMember)).toFixed(2);


            }

        }
        else {
            this.totalFinal = (parseFloat(this.totalCart) + parseFloat(this._installationFee) + parseFloat(this.hdFee) + parseFloat(this.partsFee)+parseFloat(this.protectionPlanFee)).toFixed(2);

        }

        console.log('totalFinal' + this.totalFinal);
    }
    //shubhada changes
    subscription = null;
    @wire(MessageContext)
    messageContext;
    connectedCallback() {
this.handleSubscribe();
        if (localStorage.getItem('zipcode')) {
            //An Id key is in the local Storage
            this.localStorageZipCode = JSON.parse(localStorage.getItem('zipcode'));
            this.zipCode = this.localStorageZipCode.Zipcode;
            //Clear local storage after getting the values

        }
    }
   
    messageData;
    handleSubscribe() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(this.messageContext, memberChannel, (message) => {
            console.log('install------' + message.message);
          
            this.messageData = message.message;
            if (this.messageData === 'Install' )
             {
              this.installationFeeServices();
            }

        });


    }
    @wire(getRecord, { recordId: User_Id, fields: [UserAccountIdFIELD] })
    currentUserInfo({ error, data }) {
        if (data) {

            this._accountId = data.fields.AccountId.value;
            console.log('data===' + JSON.stringify(data));

        } else if (error) {
            this.error = error;
        }
    }


    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this._rid = currentPageReference.state.recordid;
            console.log('this.rid order summary ', this._rid);

        }
        if (currentPageReference.state.orderNumber) {
            this._rid = currentPageReference.state.orderNumber;
            this.orderSummaryLabel = '';
        }
    }

   
    @wire(getBodewellOrdersItems, { Id: '$_rid' })
    BodewellOrderListItems({ data, err }) {
        //console.log('tthis.bodewellOrders in get order list items',this.number);
        // this.isLoading = true;
        if (data) {
            this.bodewellOrderListItems = data;
            this.filterCartItems();

            console.log('this.bodewellOrders in get order list items ', this.bodewellOrderListItems);
        }
        else {
            this._rid = this._rid + ' ';
            console.log(err)
        }
    }

  
    filterCartItems() {

        console.log('this.bodewellOrderListItems->', JSON.stringify(this.bodewellOrderListItems));
        this.bodewellOrderListItems = this.bodewellOrderListItems.map((item) => {
            console.log("Item Order" + JSON.stringify(item));

            //BWC_Shipping_Method__c, BWC_Ship_Date__c,product2.BWC_Delivery_Type__c,cartId
            if (item?.Product2?.BWC_Delivery_Type__c === 'hd' && item.OriginalOrderItem.BWC_Shipping_Method__c!='Will Call' ) {
                this.homeDeliveryItem = true;
                this.hdFee = 99;



            }


            if (item?.Product2?.BWC_Delivery_Type__c) {
                if (item.Product2.BWC_Delivery_Type__c === 'sps fee') {
                    this.shipToHome = true;
                    console.log('Delivery type===' + item.Product2.BWC_Delivery_Type__c);



                    if (item.OriginalOrderItem.BWC_Shipping_Method__c == 'Parts-FEDEX-Priority-Overnight') {
                        this.partsFee = 19.95;
                        this.totalPayment = this.totalPayment + this.partsFee;
                    }

                    if (item.OriginalOrderItem.BWC_Shipping_Method__c == 'Parts-FEDEX-Ground-1-7-Days') {
                        this.partsFee = 7.95;
                    }
                    if (item.OriginalOrderItem.BWC_Shipping_Method__c == 'Parts-FEDEX-2nd Day Air') {
                        this.partsFee = 17.95;
                        this.totalPayment = this.totalPayment + this.partsFee;

                    }



                }
                //member value for partsShipFee
                if (this.partsFee === 7.95 && this.isMember === true) {
                    this.partShipppingFlag = 'FREE';


                }
                else {
                    this.partShipppingFlag = '';
                    this.totalPayment = this.totalPayment + this.partsFee;

                }



            }





        })

        this.calculateTotal();

    }
    @track free = '';
    @wire(getBuyerGroup, { acctId: '$_accountId' })
    buyerGroups({ data, error }) {

        if (data) {
            console.log("buyerGroups data" + JSON.stringify(data));
            console.log("buyerGroups acctId" + this._accountId);
            //considering user belongs to only one buyer group at a time

            if (data[0].BuyerGroup != undefined && data[0].BuyerGroup.Name != undefined) {
                if (data[0].BuyerGroup.Name === 'Member') {
                    this.isMember = true;
                    this.free = 'FREE';
                }
                else {
                    this.isMember = false;
                    this.free = '';
                }
            }
            this.installationFeeServices();


        }
        else if (error) {
            console.log('buyerGroups error ' + JSON.stringify(error));
        }
    }
  

    installationFeeServices() {
      this.subtotalFinal=0.0;
        console.log("@@@__cartId", this._cartId);
        console.log("@@@isMember", this.isMember);
        console.log("@@@zipCode", this.zipCode);
        bwc_getRelatedCartItemAll({ itemId: this._cartId, isMember: this.isMember, zipCode: this.zipCode })
            .then(result => {
                console.log('data Total Install====', JSON.stringify(result));
                this._installationFee = result.totalFee;
                this.memberInstallationFee = result.memberTotalFee;
                this.protectionPlanFee = result.protectionPlanTotal;
                this.protectionPlanFeeMember=result.protectionPlanForMember;

                console.log("@@@_installationFee", this._installationFee);
                console.log("@@@memberInstallationFee", this.memberInstallationFee);
                console.log("@@@protectionPlanFee", this.protectionPlanFee);
                console.log("@@@protectionPlanFeeMember", this.protectionPlanFeeMember);

                this.calculateTotal();
                if (this.isMember) {
                    this.subtotalFinal=(this.subTotal+this.protectionPlanFeeMember+this.memberInstallationFee).toFixed(2);
                    this.totalPayment = this.totalPayment + this.memberInstallationFee+this.protectionPlanFee;
                }
                else {
                    this.totalPayment = this.totalPayment + this._installationFee;
                    this.totalPayment = this.totalPayment + this.hdFee+this.protectionPlanFee;
                    this.subtotalFinal=(this.subTotal+this.protectionPlanFee+this._installationFee).toFixed(2);
                }
                console.log("@@@subTotal", this.subTotal);
            })

            .catch(error => {
                console.log('error===', JSON.stringify(error));
                throw error;
            })


    }

}