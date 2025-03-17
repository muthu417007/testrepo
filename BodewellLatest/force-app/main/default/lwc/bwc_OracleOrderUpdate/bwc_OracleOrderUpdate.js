import { LightningElement, wire, api } from 'lwc';
import { OrderItemsAdapter } from 'commerce/orderApi';
import getOrderSummaryDetails from '@salesforce/apex/BWC_OracleOrderUpdateController.getOrderSummaryDetails';
import { CurrentPageReference } from 'lightning/navigation';

export default class Bwc_OracleOrderUpdate extends LightningElement {
    orderSummaryIdInstance;
    orderSummaryDetailArray = [];
    mediaurl;
    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            this.orderSummaryIdInstance = currentPageReference.attributes.recordId;
        }
    }
    @wire(OrderItemsAdapter, { orderSummaryId: '$orderSummaryIdInstance' })
    OrderItemsAdapterMethod({ error, data }) {
        if (data) {
            console.log('order data-->', data);
            let itemObject = {};

            let orderSummaryArray = [];
            data.items.forEach(dataInstance => {
                let orderSummaryDetailObject = {};
                // console.log('dataInstance-->',dataInstance);
                orderSummaryDetailObject['Id'] = dataInstance.orderItemSummaryId;
                orderSummaryDetailObject['orderSummaryId'] = dataInstance.orderSummaryId;
                //orderSummaryDetailObject['productName'] = dataInstance.product.fields.str.text;
                //orderSummaryDetailObject['productSKU'] = dataInstance.product.fields.Product2.StockKeepingUnit.text;
                orderSummaryDetailObject['media'] = dataInstance.product.media.url;
                //this.mediaurl = dataInstance.product.media.url;
                orderSummaryArray.push(orderSummaryDetailObject);
                console.log("orderSummaryArray-->", orderSummaryArray);
            });
            itemObject['item'] = orderSummaryArray;
            console.log('itemObject-->', itemObject);
            getOrderSummaryDetails({
                orderSummaryIdObjectList: itemObject
            })
                .then(result => {
                    console.log('success-->', result);
                    this.orderSummaryDetailArray = result;
                })
                .catch(error => {
                    console.log('error');
                });
        }
        else {
            console.log('error order-->', error);
        }
    }
    handleClick(event) {
        console.log("value-->" + event.target.value);
        //let selectedOrderSummaryId = event.target.value;
        if (this.orderSummaryDetailArray === 1) {
            alert('You will not able to cancel this item');
        }
        this.orderSummaryDetailArray = this.orderSummaryDetailArray.filter(this.updateOrderSummary);
        console.log("this.orderSummaryDetailArray-->", this.orderSummaryDetailArray);
    }
    updateOrderSummary(data) {
        console.log("data.Id-->" + data.Id);
        return data.Id !== event.target.value;
    }
}