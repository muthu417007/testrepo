import { LightningElement, wire, api } from 'lwc';
import getOrderList from '@salesforce/apex/Mya_MyOrderItems.getOrderListNo';
import Mya_MyAgentDetails from '@salesforce/apex/Mya_MyAgentDetails.Mya_MyAgentDetails';
import Id from '@salesforce/user/Id';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

import mya_MyOrderDetail_GEA from './mya_MyOrderDetail_GEA.html';
import mya_MyOrderDetail_Cafe from './mya_MyOrderDetail_Cafe.html';
import mya_MyOrderDetail_Haier from './mya_MyOrderDetail_Haier.html';
import { ingestDataConnector } from 'lightning/analyticsWaveApi';

import Mya_Install from '@salesforce/resourceUrl/Mya_Install';
import PROUDUCT_IMAGE from '@salesforce/resourceUrl/productimage';
import SERVICE_IMAGE from '@salesforce/resourceUrl/MYA_ServiceImage';

//css
import MYAGEACSS from '@salesforce/resourceUrl/MYAGEACSS';
import MYACAFECSS from '@salesforce/resourceUrl/MYACAFECSS';
import MYAHAIERCSS from '@salesforce/resourceUrl/MYAHAIERCSS';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class Mya_MyOrderDetail extends NavigationMixin(LightningElement) {


    @api BrandValue;
    isLoading = true;

    render() {
        if (this.BrandValue == "GEA") {
            return mya_MyOrderDetail_GEA
        } else if (this.BrandValue == "Haier") {
            return mya_MyOrderDetail_Haier
        } else if (this.BrandValue == "Cafe") {
            return mya_MyOrderDetail_Cafe
        } else {
            return mya_MyOrderDetail_GEA
        }
    }

    // CSS loader function

    //   renderedCallback() {
    //     if (this.BrandValue == "GEA") {
    //         Promise.all([
    //             loadStyle(this, MYAGEACSS + '/MYAGEACSS/mya_MyOrderDetail_GEA.css')
    //         ]);
    //     }
    //     else if (this.BrandValue == "Haier") {
    //         Promise.all([
    //             loadStyle(this, MYAHAIERCSS + '/MYAHAIERCSS/mya_MyOrderDetail_Haier.css')
    //         ]);
    //     }
    //     else if (this.BrandValue == "Cafe") {
    //         Promise.all([
    //             loadStyle(this, MYACAFECSS + '/MYACAFECSS/mya_MyOrderDetail_Cafe.css')
    //         ]);
    //     }
    // }

    image = Mya_Install;
    noimage = PROUDUCT_IMAGE;
    serviceImage = SERVICE_IMAGE;

    rid;
    order = [];
    error;
    isPrint;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.rid = currentPageReference.state.recordid;
            this.isPrint = currentPageReference.state.print;
            this.getOrders();
        }
    }

    handleBackOrder() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'MYA_My_Orders__c'
            },
            state: {}
        });
    }


    //order
    Orders

    // @wire(getOrderList, { UserId: Id })
    // OrderList({ data, err }) {
    //     if (data) {
    //         this.Orders = data;
    //         this.OrderDetails();
    //     }
    //     if (err) {
    //         console.log(err)
    //     }
    // }

    getOrders() {
        getOrderList({ OrderRefNo: this.rid })
          .then(result => {
            console.log('getOrderList -> response :', result);
            this.Orders = result;
            this.OrderDetails();
            this.isLoading = false;
            
    
          })
          .catch(error => {
            if(error != null)
            {
              this.showMsg = true;
              this.isLoading = false;
            }
            this.error = error;
            console.error('getOrderList -> error response :', error);
          });
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
        for (const Ord of this.Orders) {
            if (Ord.OrderRefNumber == this.rid) {
                this.Details = Ord
                this.ShipingMethod = this.Details.ShippingMethod
                if (this.ShipingMethod.includes("Home Delivery") || this.Details.MixedShipFlag == true || this.ShipingMethod.includes("SDS Delivery")) {
                    this.Delivery = true

                    if (this.Delivery == true) {
                        if (this.Details.OrderStatusPendFlag == true) {
                            this.DeliveryPending = true
                            this.LineItems = this.Details.LineItemList
                            for (const item of this.LineItems) {
                                if (item.ShowLineItemFlagDetail == true && this.DateList.includes(item.ItemArrivalDate) == false) {
                                    this.DateList = [...this.DateList, item.ItemArrivalDate];
                                }
                            }
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
    }

    print() {
        if (this.isPrint == true) {
            window.print();
        }
    }

    handlePrint() {
        this[NavigationMixin.GenerateUrl]({
            type: 'comm__namedPage',
            attributes: {
                name: 'MYA_print_order_details__c'
            },
            state: {
                recordid: this.rid,
                print: true,
            }
        }).then(url => { window.open(url) });

    }
}