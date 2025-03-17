import { api, LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getCase from '@salesforce/apex/CX_MatchCaseContactController.getCase';
import getContacts from '@salesforce/apex/CX_MatchCaseContactController.getContacts';
import getExternalContacts from '@salesforce/apex/CX_MatchCaseContactController.getExternalContacts';

import matchContact from '@salesforce/apex/CX_MatchCaseContactController.matchContact';

import { handleError, showToast } from 'c/cx_utils'

/**
 * Class responsible for handling the logic to match a Case and a Contact
 * @extends {NavigationMixin} and {LightningElement}
 */
export default class Cx_matchCaseContact extends NavigationMixin(LightningElement) {
    @api recordId;

    case;
    @track contacts = [];
    @track externalContacts = [];
    @track loading = false;

    /**
    * A lifecycle hook that runs when the component is starting
    */
    async connectedCallback() {
        this.loading = true;
        await this.getCase();
        await Promise.all([
            this.getContacts(),
            this.getExternalContacts()
        ]);
        this.saveIndex();
        this.removeDuplicates();
        this.loading = false;
    }

    /**
    * A method that gets the current case
    */
     async getCase() {
        try {
            this.case = await getCase({ caseId: this.recordId });
        } catch(ex) {
            handleError(this, ex);
        }
    }

    /**
    * A method that checks for matching contacts in Salesforce for the case
    */
    async getContacts() {
        try {
            const contactsSF = JSON.parse(await getContacts({ email: this.case.CX_Contact_Email__c, phone: this.case.CX_Contact_Phone__c }));
            contactsSF.filter(contact => !contact.Phone).forEach(contact => contact.Phone = contact.MobilePhone ?? contact.VOIP_Phone__c ?? contact.OtherPhone);
            this.contacts.push(...contactsSF);

        } catch(ex) {
            handleError(this, ex);
        }
    }

    /**
    * A method that checks for matching external contacts for the case
    */
     async getExternalContacts() {
        try {
            this.externalContacts = JSON.parse(await getExternalContacts({ email: this.case.CX_Contact_Email__c, phone: this.case.CX_Contact_Phone__c }));
            this.contacts.push(...this.externalContacts.map(contact => contact.contactSalesforce));
        } catch(ex) {
            handleError(this, ex);
        }
    }

    /**
    * A method that saves the index to the object
    */
    saveIndex() {
        this.contacts.forEach((contact, index) => contact.index = index);
    }

    /**
    * A method that removes duplicates (when a contact exists in SF and in the external database with the same PersonId)
    */
    removeDuplicates() {
        for(let i = 0; i < this.contacts.length; i++) {
            const currentContact = this.contacts[i];
            this.contacts = this.contacts.filter(contact => ((contact.Id && currentContact.Id && contact.Id !== currentContact.Id) || (contact.PersonID__c && currentContact.PersonID__c && contact.PersonID__c !== currentContact.PersonID__c)) || contact.index === currentContact.index);
        }
    }

    /**
     * A method that handles the Match button click, it will call SF to save the match and refresh the page
     * @param {event} event - A click event
     */
    async handleMatchClick(event) {
        try {
            this.loading = true;
            const contactMatch = this.contacts.find(contact => contact.index === event.detail);

            await matchContact({ caseId: this.recordId, contactMatchStr: JSON.stringify(contactMatch), searchResultStr: contactMatch.Id ? null : JSON.stringify(this.externalContacts) });
            showToast(this, 'Case updated!', 'Contact matched!', 'success');

            this.loading = false;
            this.dispatchEvent(new CustomEvent('refreshpage', {}));
        } catch(ex) {
            handleError(this, ex);
        }
    }

    /**
     * A method that opens the Contact page after a user clicks
     * @param {event} event - A click event
     */
    handleContactClick(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.detail,
                actionName: 'view',
            },
        });
    }
}