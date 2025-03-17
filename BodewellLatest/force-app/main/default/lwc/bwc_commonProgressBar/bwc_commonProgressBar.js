import { LightningElement, api, track } from 'lwc';
import getPicklistLabelValue from '@salesforce/apex/BWC_PartsSearchController.getPicklistLabelValue';
import getOrderStatus from '@salesforce/apex/BWC_PartsSearchController.getOrderStatus';
import MyModal from 'c/bwc_orderSearchQuickAction';

export default class Bwc_commonProgressBar extends LightningElement {
    @track currentStep = "Booked";
    buttonClicked = false;
    orderNumber;
    @track steps =  [];
    @api recordId;

     async connectedCallback(){
        console.log('Parent Record Id Is >',this.recordId);
        //Agent S
        // this.updateProgressBar();
        const orderStatus = await getOrderStatus({orderSummaryId: this.recordId});
        const statusLabelValues = await getPicklistLabelValue({objectApi: 'Order', refernceFieldOnObject: 'Status'});
        for(let status in statusLabelValues){
            const newStatus = {};
            newStatus.label = status;
            newStatus.value = statusLabelValues[status];
            this.steps.push(newStatus);
        }
        console.log('Order Status > ',orderStatus);
        this.currentStep = orderStatus[0]?.OriginalOrder.Status;
        this.orderNumber = orderStatus[0]?.OriginalOrder.Order_Number__c;
        console.log('Current Step > ',this.currentStep,' orderNumber > ',this.orderNumber);
        //Agent E

    }

    //Agent S
    async updateProgressBar(){
        const orderStatus = await getOrderStatus({orderSummaryId: this.recordId});
        if(orderStatus[0]?.OriginalOrder.Status.toLowerCase() !== this.currentStep.toLowerCase() || !this.currentStep){
            const statusLabelValues = await getPicklistLabelValue({objectApi: 'Order', refernceFieldOnObject: 'Status'});
            for(let status in statusLabelValues){
                const newStatus = {};
                newStatus.label = status;
                newStatus.value = statusLabelValues[status];
                this.steps.push(newStatus);
            }
            console.log('Order Status > ',orderStatus);
            this.currentStep = orderStatus[0]?.OriginalOrder.Status;
            this.orderNumber = orderStatus[0]?.OriginalOrder.Order_Number__c;
            console.log('Current Step > ',this.currentStep,' orderNumber > ',this.orderNumber);
        }
    }
    //Agent E



    async handleGetOrderStatus(e){
        this.buttonClicked = true;
        await MyModal.open({
            label: 'Order Status',
            size: 'large',
            orderNumber: this.orderNumber,
            recordId : this.recordId
        }).then((result) => {
            console.log('Modal Opened');
            //Agent S
                this.updateProgressBar();
            //Agent E
        })
    }
}