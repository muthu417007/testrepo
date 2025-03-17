import { LightningElement, api, track } from 'lwc';

export default class OrdersListView extends LightningElement {
    @track order_columns = [];
    @track orderdata = [];
    @api
    consumerdata(orderdata, order_columns) {

        this.orderdata = orderdata;
        this.order_columns = order_columns;
    }
}