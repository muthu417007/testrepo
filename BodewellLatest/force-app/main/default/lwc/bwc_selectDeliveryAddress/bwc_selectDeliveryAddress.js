import { LightningElement, api, track } from 'lwc';
import getDefaultAddress from '@salesforce/apex/BWC_OrderOnBehalfOfController.getDefaultAddress';

export default class Bwc_selectDeliveryAddress extends LightningElement {
    @track addressListToDisplay;
    @api accountId;

    async connectedCallback(){
        const defaultAddress = await getDefaultAddress({accountId: this.accountId});
        this.addressListToDisplay = defaultAddress;
        console.log('Default Address > ',defaultAddress);
    }
}