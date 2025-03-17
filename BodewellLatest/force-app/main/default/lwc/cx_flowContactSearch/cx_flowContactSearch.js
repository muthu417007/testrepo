import { api, LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getContacts from '@salesforce/apex/CX_FlowContactSearchController.getContacts';
import getExternalContacts from '@salesforce/apex/CX_FlowContactSearchController.getExternalContacts';

import restoreContact from '@salesforce/apex/CX_FlowContactSearchController.restoreContact';
import relateContactCase from '@salesforce/apex/CX_FlowContactSearchController.relateContactCase';

import { handleError } from 'c/cx_utils'
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';

/**
 * Class responsible for handling the logic to select a contact and pass it's id to the flow
 * @extends {NavigationMixin} and {LightningElement}
 */
export default class Cx_flowContactSearch extends NavigationMixin(LightningElement) {
    @track inputType = 'phone';
    @track inputValue = '';

    @api caseId;
    @api contactId;
    @api createNewContact = false;
    @api showNewContactButton;
    @api newContactData;

    @track contacts = [];
    @track externalContacts = [];
    @track loading = false;

    windowEventListener;
    @track selectClasses = 'slds-col';
    @track inputClasses = 'slds-col';
    
    resizeTimeout;
    @track allowResize = true;
    firstRender = true;

    /**
    * A lifecycle hook that runs when the component renders or re-renders an item on the screen,
    * also checks how the component should look (alignment) and add the necessary listeners to resize/zoom window events
    */
    renderedCallback() {
        if(this.firstRender) {
            const component = this;
            this.windowEventListener = () => {component.defineInputSize()};
            window.addEventListener("resize", this.windowEventListener);
            window.addEventListener("zoom", this.windowEventListener);
            component.defineInputSize();
            this.firstRender = false;
        }    
    }

    /**
    * A lifecycle hook that runs when the component is closed, removing all listeners
    */
    disconnectedCallback() {
        window.removeEventListener(this.windowEventListener);
    }

    /**
    * A method that defines how the inputs should be aligned
    */
    defineInputSize() {
        if(!this.allowResize) {
            return;
        }

        const inputField = this.template.querySelector(`[data-id="${this.inputType}"]`);
        
        if(inputField.clientWidth < 150) {
            this.selectClasses = 'slds-col slds-size_1-of-1';
            this.inputClasses = 'slds-col slds-size_5-of-6';
        }
        else {
            this.selectClasses = 'slds-col slds-size_2-of-6';
            this.inputClasses = 'slds-col slds-size_3-of-6';
        }

        this.allowResize = false;
        this.resizeTimeout = setTimeout(() => {this.allowResize = true}, 1000);
    }

    /**
    * A method that checks for matching contacts in Salesforce
    */
    async getContacts() {
        try {
            const contactsSF = JSON.parse(await getContacts({ email: this.inputType === 'email' ? this.inputValue : null, phone: this.inputType === 'phone' ? this.inputValue : null }));
            contactsSF.filter(contact => !contact.Phone).forEach(contact => contact.Phone = contact.MobilePhone ?? contact.VOIP_Phone__c ?? contact.OtherPhone);
            this.contacts.push(...contactsSF);

        } catch(ex) {
            handleError(this, ex);
        }
    }

    /**
    * A method that checks for matching external contacts
    */
     async getExternalContacts() {
        try {
            this.externalContacts = JSON.parse(await getExternalContacts({ email: this.inputType === 'email' ? this.inputValue : null, phone: this.inputType === 'phone' ? this.inputValue : null }));
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
     * A method that handles the Select button click, it will call SF to restore the contact if it has no Id and fire the flow events 
     * @param {event} event - A click event
     */
    async handleSelectClick(event) {
        try {
            this.loading = true;
            const contactMatch = this.contacts.find(contact => contact.index === event.detail);

            this.contactId = contactMatch.Id;

            if(!contactMatch.Id) { 
                this.contactId = await restoreContact({ contactMatchStr: JSON.stringify(contactMatch), searchResultStr: JSON.stringify(this.externalContacts) })
            }
            
            if(this.caseId) {
                await relateContactCase({ caseId: this.caseId, contactId: this.contactId });
            }
            
            this.dispatchEvent(new FlowAttributeChangeEvent('contactId', this.contactId));
            this.dispatchEvent(new FlowNavigationNextEvent());
        } catch(ex) {
            handleError(this, ex);
        } finally {
            this.loading = false;
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

    /**
     * A method that handles the combo box change event
     * @param {event} event - A change event
     */
    handleChange(event) {
        this.inputType = event.detail.value;
    }

    /**
     * A method that handles the search button click, validating the input and calling the search methods
     */
    async handleSearchClick() {
        try {
            let inputField;

            if(this.inputType === 'email') {
                inputField = this.template.querySelector('[data-id="email"]');
            } else {
                inputField = this.template.querySelector('[data-id="phone"]');
            }

            if(!inputField.reportValidity()) {
                return;
            }

            this.inputValue = inputField.value;

            this.loading = true;
            this.contacts = [];
            this.externalContacts = [];

            await Promise.all([
                this.getContacts(),
                this.getExternalContacts()
            ]);

            this.saveIndex();
            this.removeDuplicates();
        } catch(ex) {
            handleError(this, ex);
        } finally {
            this.loading = false;
        }
    }

    handleNewContactClick() {
        this.createNewContact = true;
        this.dispatchEvent(new FlowAttributeChangeEvent('createNewContact', this.createNewContact));
        this.dispatchEvent(new FlowAttributeChangeEvent('newContactData', this.inputValue));
        this.dispatchEvent(new FlowNavigationNextEvent());
    }

    get isInputTypePhone() {
        return this.inputType === 'phone';
    }

    get isInputTypeEmail() {
        return this.inputType === 'email';
    }

    get inputOptions() {
        return [
            { label: 'Phone', value: 'phone' },
            { label: 'Email', value: 'email' }
        ];
    }

    get disableLinkClick() {
        return false;
    }
}