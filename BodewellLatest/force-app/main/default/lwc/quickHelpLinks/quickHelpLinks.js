import { LightningElement, wire } from 'lwc';
import QuickLinks from '@salesforce/apex/THD_MDO_OrdersData.fetchQuickLinks';

const COLUMNS = [
    { label: 'Name', fieldName: 'Name__c' },
    { label: 'Url', fieldName: 'Quick_Link__c' }
];
export default class QuickHelpLinks extends LightningElement {
    records;
    wiredRecords;
    error;
    columns = COLUMNS;
    draftValues = [];
    @wire(QuickLinks)
    wiredRecs(value) {

        this.wiredRecords = value;
        const { data, error } = value;

        if (data) {

            this.records = data;
            this.error = undefined;

        } else if (error) {

            this.error = error;
            this.records = undefined;

        }
    }
}