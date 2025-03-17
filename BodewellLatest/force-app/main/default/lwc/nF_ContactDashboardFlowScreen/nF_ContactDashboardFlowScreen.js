import { LightningElement, api } from 'lwc';

export default class NF_ContactDashboardFlowScreen extends LightningElement {
    @api contactId;
    contactDashboardUrl='';

    connectedCallback() {
        this.contactDashboardUrl = '/apex/contactDashboard?id=' + this.contactId;
    }
}