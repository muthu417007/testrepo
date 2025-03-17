import { LightningElement, wire, api } from 'lwc';
import getOrderList from '@salesforce/apex/Mya_MyOrderItems.getOrderList';
import getBodewellOrderSummary from '@salesforce/apex/BWC_OrderConfirmationController.getBodewellOrders';
import getOrderCount from '@salesforce/apex/Mya_MyOrderItems.getOrderCount';
import getContact from '@salesforce/apex/Mya_OrderHelper.getContact';

import GetURLs from '@salesforce/apex/Mya_OrderHelper.getURL';
import smartOrderLogo from '@salesforce/resourceUrl/smartOrderLogo';
import Mya_MyAgentDetails from '@salesforce/apex/Mya_MyAgentDetails.Mya_MyAgentDetails';
import PRODUCT_IMAGE from '@salesforce/resourceUrl/Mya_Install';
import NO_IMAGE from '@salesforce/resourceUrl/productimage';
import OrderPaginationCount from '@salesforce/label/c.mya_orderPaginationNo';
import orderProcessingMessage from '@salesforce/label/c.mya_orderProcessingMessage';




// User ID
import USER_ID from '@salesforce/user/Id';

import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

// Templates
import Bodewell from "./bwc_myaMyOrders.html";


export default class Mya_myOrder_individualOrder extends NavigationMixin(LightningElement) {
    contact;
    PageLinks;
    //serviceImage = SERVICE_IMAGE;
    orderCount = 0;
    totalOrders = 0;
    showPrevButtonflag = false;
    showNextButtonflag = true;
    orderItemCount;
    OrderPaginationCount;
    OrderProcessMessage = orderProcessingMessage;
    usr1
    usid


    redirectUrl = '';
    redirectLinkVisible = false;
    Orders;
    isLoading = true;
    image = PRODUCT_IMAGE;
    noImage = NO_IMAGE;
    @api recordId;
    @api brand = 'GEA';
    

    @api pageTitleLabel;
    @api smartOrderLinkLabel;
    @api orderNoLabel;
    @api orderDateLabel;
    @api orderRefNoLabel;
    @api orderTotalLabel;
    @api orderStatusLabel;

    @api assistanceLabel;
    @api phoneLabel;
    @api T13Label;
    @api T21Label;
    @api T22Label;
    @api T23Label;
    @api T31Label;
    @api T32Label;
    @api T33Label;

    @api ViewOrderLinkLabel;
    @api ReturnItemLink;
    @api TrackMyOrderLink;
    @api RescheduleLink;
    @api DeliveryInformationLink;

    bodewellOrders;
    bodewellOrderListItems;
    bodewellOrderNumber;
    selectedValue = 6;
    options = [
        { label: 'The past 6 months', value: '6' },
        { label: 'The past 1 year', value: '12' },
        { label: 'The past 2 year', value: '24' },
    ];

    handleChange(event) {
        debugger
        this.selectedValue = event.target.value;
        this.isLoading = true;
    }

    // UI render based on brand and user status
    render() {
        console.log('this.brand',this.brand);
       
            this.usr = USER_ID
            console.log('Bodewell Template rendered');
            return Bodewell;
      
    }

    handlePrevOrder() {


        this.orderCount = this.orderCount - parseInt(OrderPaginationCount);
        this.showNextButtonflag = true;
        if (this.orderCount - parseInt(OrderPaginationCount) < 0) {
            this.showPrevButtonflag = false;
        }
        this.isLoading = true;
    }

    handleNextOrder() {


        this.orderCount = this.orderCount + parseInt(OrderPaginationCount);
        this.showPrevButtonflag = true;
        if (this.orderCount + parseInt(OrderPaginationCount) >= this.orderItemCount) {

            this.showNextButtonflag = false;
        }
        this.Orders = null;
        this.isLoading = true;

    }

    connectedCallback() {
        console.log("inside connected callback");
    }

    @wire(getContact, { UserId: USER_ID }) Cont({ data, err }) {
        if (data) {
            this.contact = data[0];
            console.log('this.contact: ', this.contact);
            this.GetURLs(this.contact);
        } else if (err) {
            console.error(err);

        }
    }

    @api number;
   // @wire(getBodewellOrderSummary, { Id: '$number' })
   @wire(getBodewellOrderSummary, { UserId: '$usr', ordCount: '$orderCount', noOfMonths: '$selectedValue' })
    BodewellOrderList({ data, err }) {
        this.isLoading = true;
        if (data) {
            this.bodewellOrders = data;
            console.log('tthis.bodewellOrders in get order list  ', this.bodewellOrders);
        }
        if (err) {
            console.log(err)
            this.isLoading = false;
            //this.showNextButtonflag = false;
        }
    }




    @wire(getOrderList, { UserId: '$usr', ordCount: '$orderCount', noOfMonths: '$selectedValue' })
    OrderList({ data, err }) {
        console.log('this.orders in get order list  ', data);
        this.isLoading = true;
        if (data) {
            this.Orders = data;
            console.log('this.orders in get order list  ', this.Orders);
            this.isLoading = false;
            this.OrderCount();

        }
        if (err) {
            console.log(err)
            this.isLoading = false;
            //this.showNextButtonflag = false;
        }
    }

    orderData() {
        getOrderList({ UserId: this.usr, ordCount: this.orderCount })
            .then(result => {
                this.Orders = result;
                this.isLoading = false;
                this.OrderCount();
            })
            .catch(error => {
                console.log(error)
                this.isLoading = false;
            })
    }

    OrderCount() {
        getOrderCount({ UserId: this.usr })
            .then(result => {
                this.orderItemCount = result;
                if (result < parseInt(OrderPaginationCount) + 1) {
                    this.showNextButtonflag = false;
                }
            })
            .catch(error => {
                console.log(error)
                this.showNextButtonflag = false;
            })
    }

    GetURLs(contact) {
        GetURLs()
            .then(result => {
                console.log('getURL -> response :', result);
                console.log('contact -> response :', contact);


                this.PageLinks = result;
                let encodedParams = encodeURIComponent('UID=' + contact.Global_Customer_Id__c + '&email_address=' + this.contact.Email);
                let encodedStateUrl = encodeURIComponent(this.PageLinks.stateURL__c);
                let encodedPartsUrl = encodeURIComponent(this.PageLinks.partsURL__c);
                this.redirectUrl = this.PageLinks.smartURL__c + encodedPartsUrl + this.PageLinks.partsURLParams__c + encodedStateUrl + encodedParams;
                this.redirectLinkVisible = true;
                console.log('this.redirectUrl: ', this.redirectUrl);


            })
            .catch(error => {
                this.error = error;

            });
    }

    SOL = smartOrderLogo;

    handleOrderDetails(event) {

        var rid = event.target.value;
        console.log('rid', rid);
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'MYA_Order_Details__c'
            },
            state: {
                recordid: rid
            }
        });
    }

    OpenModal = false;
    orderNo;
    Modal(event) {

        try {
            this.orderNo = event.target.value;
            this.OrderDetails();
            this.OpenModal = true;

        } catch (ex) {
            console.error(ex)

        }
    }

    closeModal() {

        this.OpenModal = false;
        this.orderNo = undefined;
        this.Details = undefined;
        this.Agent = undefined;
        this.Delivery = false;
        this.DeliveryPending = false;
        this.Ship = false;
        this.PickUp = false;
        this.LineIt = [];
    }

    Details
    ShipingMethod
    Delivery
    Ship
    PickUp
    AgentDetails
    Agent
    LineItems
    LineIt = [];
    DeliveryPending = false
    DateList = [];
    OrderDetails() {
        try {
            for (const Ord of this.bodewellOrders) {
                console.log('ord line 281', Ord);
                if (Ord.OrderNumber == this.orderNo) {
                    this.Details = Ord
                    console.log('line num 283', this.Details)
                    this.ShipingMethod = this.Details.ShippingMethod
                    if (this.ShipingMethod.includes("Home Delivery") || this.Details.MixedShipFlag == true || this.ShipingMethod.includes("SDS Delivery")) {
                        this.Delivery = true

                        if (this.Delivery == true) {
                            if (this.Details.OrderStatusPendFlag == true) {
                                this.DeliveryPending = true
                                this.LineItems = this.Details.LineItemList
                                console.log(this.LineItems)
                                for (const item of this.LineItems) {
                                    if (item.ShowLineItemFlagDetail == true && this.DateList.includes(item.ItemArrivalDate) == false) {
                                        this.DateList = [...this.DateList, item.ItemArrivalDate];
                                    }
                                }
                                console.log(this.DateList)
                                for (const date of this.DateList) {

                                    let AssetList = []
                                    for (const prod of this.LineItems) {
                                        if (date == prod.ItemArrivalDate && prod.ShowLineItemFlagDetail == true && prod.ShipHomDelFlag == true) {

                                            AssetList = [...AssetList, prod];
                                        }
                                    }
                                    if (AssetList.length != 0) {
                                        const Ast = {
                                            AssetDetail: AssetList,
                                            ScheduleDate: date
                                        };
                                        this.LineIt = [...this.LineIt, Ast];
                                    }
                                }
                                console.log(this.LineIt)

                            }
                        }
                    } else if (this.ShipingMethod.includes("FedEx")) {
                        this.Ship = true
                    } else if (this.ShipingMethod.includes("Will Call")) {
                        this.PickUp = true
                        Mya_MyAgentDetails({ Zip: this.Details.ShipZip })
                            .then(result => {
                                this.AgentDetails = result.agents
                                for (const Ag of this.AgentDetails) {
                                    if (Ag.display_name == 'Will Call') {
                                        this.Agent = Ag;
                                    }
                                }

                            })
                            .catch(error => {
                                console.log(error)
                            })
                    }
                    if (this.isPrint == 'true') {
                        setTimeout(print, 2000);
                    }
                }
            }
        } catch (Ex) {
            console.error(Ex)
        }

    }
}