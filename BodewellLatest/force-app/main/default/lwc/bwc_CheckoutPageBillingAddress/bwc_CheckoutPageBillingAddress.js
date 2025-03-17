/**
 * BDC-827 - As a consumer, I want a 1 page checkout flow. Section 3. Billing
 * https://geappliances.atlassian.net/browse/BDC-827
 * Deepak Wadar
 * 09/15/2023
 */
import { LightningElement, track } from 'lwc';

export default class Bwc_CheckoutPageBillingAddress extends LightningElement {
    @track firstName = '';
    @track lastName = '';
    @track address = '';
    @track addressLine2 = '';
    @track city = '';
    @track state = '';
    @track zip = '';
    @track phoneNumber = '';
}