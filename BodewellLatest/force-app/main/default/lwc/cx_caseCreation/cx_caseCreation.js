import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createCase from '@salesforce/apex/CX_CaseCreationController.createCase';

export default class Cx_caseCreation extends LightningElement {

    @api contactId;
    selectedLocation;
    selectedAssets = [];

    caseSubject;
    caseType;

    isLoading = false;

    handleSubmit () {
        this.isLoading = true;
        createCase({subject: this.caseSubject, type: this.caseType, contactId: this.contactId, location: this.selectedLocation[0], geaAssets: this.selectedAssets})
            .then((response) => {
                this.showToast('success', 'Case created successfully: ' + response);
                this.isLoading = false;
            }).catch((e) => {
                this.showToast('error', e.body.message);
                this.isLoading = false;
        });
    }

    handleLocationSelected (event) {
        this.selectedLocation = event.detail;
    }
    handleAssetSelected (event) {
        this.selectedAssets = event.detail;
    }

    showToast (type, message) {
        let toastTitle = (type === "error" ? "Error" : "" )
        const evt = new ShowToastEvent({
            title: toastTitle,
            message: message,
            variant: type
        });
        this.dispatchEvent(evt);
    }

    handleSubjectChange (event) {
        this.caseSubject = '' + event.detail.value;
    }

    handleTypeChange (event) {
        this.caseType = '' + event.detail.value;
    }
}