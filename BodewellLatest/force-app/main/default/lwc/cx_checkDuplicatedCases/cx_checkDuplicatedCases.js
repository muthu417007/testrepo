import { api, LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getDuplicatedCases from '@salesforce/apex/CX_CheckDuplicatedCasesController.getDuplicatedCases';

import { handleError } from 'c/cx_utils'

export default class Cx_checkDuplicatedCases extends NavigationMixin(LightningElement) {
    @api recordId;
    @api teamPersona;

    @track cases;
    @track loading = false;

    /**
    * A lifecycle hook that runs when the component is starting
    */
    async connectedCallback() {
        this.loading = true;
        await this.getDuplicatedCases();
        this.loading = false;
    }

    /**
    * A method that searches for duplicated cases
    */
    async getDuplicatedCases() {
        try {
            this.cases = await getDuplicatedCases({ caseId: this.recordId, persona: this.teamPersona });
        } catch(ex) {
            handleError(this, ex);
        }
    }

    /**
     * A method that opens the Case page after a user clicks
     * @param {event} event - A click event
     */
     handleCaseClick(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.detail,
                actionName: 'view',
            },
        });
    }

    get hasDuplicatedCases() {
        return this.cases && this.cases.length;
    }
}