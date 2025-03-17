import { api, LightningElement } from 'lwc';

/**
 * Component that shows an item in the duplicated cases list
 */
export default class Cx_checkDuplicatedCasesItem extends LightningElement {
    @api caseRecord;

    /**
     * Method that fires an event when a case number is clicked
     */
    handleCaseClick() {
        this.dispatchEvent(new CustomEvent('caseclick', { detail: this.caseRecord.Id }))
    }
}