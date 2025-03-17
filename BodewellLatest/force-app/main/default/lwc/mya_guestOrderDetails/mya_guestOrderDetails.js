import { LightningElement, wire, api } from 'lwc';
import getOrderList from '@salesforce/apex/Mya_MyOrderItems.getOrderListRefNo';
import Mya_MyAgentDetails from '@salesforce/apex/Mya_MyAgentDetails.Mya_MyAgentDetails';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import PRODUCT_IMAGE from '@salesforce/resourceUrl/Mya_Install';
import NO_IMAGE from '@salesforce/resourceUrl/productimage';
import SERVICE_IMAGE from '@salesforce/resourceUrl/MYA_ServiceImage';

// Templates
import GEA from "./mya_guestOrderDetails.html";
import Cafe from "./mya_guestOrderDetailsCafe.html";
import Haier from "./mya_guestOrderDetailsHaier.html";

export default class Mya_guestOrderDetails extends NavigationMixin(LightningElement)
{
  @api BrandValue;
  isLoading = true;
  image = PRODUCT_IMAGE;
  noImage = NO_IMAGE;
  serviceImage = SERVICE_IMAGE;

  // UI render based on brand and user status
  render() {
    if (this.BrandValue == "GEA") {
      return GEA;
    }
    else if (this.BrandValue == "Haier") {
      return Haier;
    }
    else if (this.BrandValue == "Cafe") {
      return Cafe;
    }
  }

  rid;
  rem;
  order = [];
  error;
  isPrint;
  Orders;
  showMsg=false;

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.rid = currentPageReference.state.recordid;
      this.rem = currentPageReference.state.recordem;
      this.isPrint = currentPageReference.state.print;
      this.getOrders();
    }
  }

  handleBackOrder() {
    this[NavigationMixin.Navigate]({
      type: 'comm__namedPage',
      attributes:
      {
        name: 'MYA_CheckOrderStatus__c'
      },
      state:
        {}
    });
  }

  getOrders() {
    getOrderList({ OrderRefNo: this.rid })
      .then(result => {
        console.log('getOrderList -> response :', result);
        debugger;
        this.Orders = result;
        this.OrderDetails();
        this.showMsg = false;
        this.isLoading = false;

      })
      .catch(error => {
        if(error != null)
        {
          this.showMsg = true;
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
        console.log(this.Details)
        this.ShipingMethod = this.Details.ShippingMethod
        if (this.ShipingMethod.includes("Home Delivery") || this.Details.MixedShipFlag == true  || this.ShipingMethod.includes("SDS Delivery")) {
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
            }
          }
        }
        else if (this.ShipingMethod.includes("FedEx")) {
          this.Ship = true
        }
        else if (this.ShipingMethod.includes("Will Call")) {
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
    this.isLoading = false;
  }

  print() {
    if (this.isPrint == true) {
      window.print();
    }
    else {
      console.log('no print')
    }
  }

  handlePrint() {
    this[NavigationMixin.GenerateUrl]({
      type: 'comm__namedPage',
      attributes:
      {
        name: 'MYA_Print_Order_Details_Guest__c'
      },
      state:
      {
        recordid: this.rid,
        print: true,
      }
    }).then(url => { window.open(url) });
  }
}