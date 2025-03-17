import { LightningElement,track,api,wire } from 'lwc';

import getCase from '@salesforce/apex/CX_CreateContactAssetLocationController.getCase';

import validateAsset from '@salesforce/apex/CX_CreateContactAssetLocationController.validateAsset';
import createAsset from '@salesforce/apex/CX_CreateContactAssetLocationController.createAsset';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_ASSSET_OBJECT from '@salesforce/schema/Case_Asset__c';

import IN_WARRANTY_FIELD from '@salesforce/schema/Case_Asset__c.In_Warranty_CaseAsset__c';

import { showToast, handleError } from 'c/cx_utils';

export default class Cx_validateAndCreateSingleAsset extends LightningElement {

    @track model;
    @track serial;
    @track inWarrantyValue = 'No';
    @track installDate;
    @track showSpinner = false;
    @api recordId;

    case;

    @track assetValidetedDisabled = false;
    @track clearButtonsDisabled = false;
    @track createAssetDisabled = true;

    @track validateAssetResponse;
    validateButtonDisabled = false;

    @wire(getObjectInfo, { objectApiName: CASE_ASSSET_OBJECT })
    caseAssetMetaData;

    @wire(getPicklistValues,
        {
            recordTypeId: '$caseAssetMetaData.data.defaultRecordTypeId', 
            fieldApiName: IN_WARRANTY_FIELD
        }
    )
    inWarrantyPicklist;

    async connectedCallback() {
        this.showSpinner = true;
        await this.getCase();
        this.showSpinner = false;
    }

    async getCase() {
        try {
            this.case = await getCase({ caseId: this.recordId });
            this.validateCase();
        } catch(ex) {
            handleError(this, ex, 'sticky');

            this.createAssetDisabled = true;
            this.validateButtonDisabled = true;
            this.clearButtonsDisabled = true;
        }
    }

    validateCase() {
        if(!this.case.AccountId && !this.case.ContactId) {
            throw 'An Asset cannot be created because there is no Contact or Location associated to this Case.';
        } else if(!this.case.AccountId) {
            throw 'An Asset cannot be created because there is no Location associated to this Case.';
        } else if(!this.case.ContactId) {
            throw 'An Asset cannot be created because there is no Contact associated to this Case.';
        }
    }

    handleClearAssetFields(event){
        this.model = null;
        this.serial = null;
        this.installDate = null;
        this.validateButtonDisabled = false;
        this.validateAssetResponse = null;
        this.createAssetDisabled = true;
        this.inWarrantyValue = 'No';
    }

    isFieldEmpty(value){
        if(value == null || value == undefined || value == ''){
            return true;
        }
        return false;
    }

    validateAssetFields(event){

        if(this.isFieldEmpty(this.serial) ||this.isFieldEmpty(this.model) || this.isFieldEmpty(this.installDate) || this.isFieldEmpty(this.inWarrantyValue) ){
            showToast(this, 'Please fill the fields',
                'For asset validation, all the asset fields must be filled',
                'warning');
            return false;
        } 
        return true;
    }

    handleAssetCreation(event){
        if(!this.validateAssetFields(event)){
            return;
        }
        this.createAssetDisabled = true;
        this.showSpinner = true;

        createAsset(
            {
                asInfo:JSON.stringify(this.validateAssetResponse),
                caseId:this.recordId,
                modelNumber:this.model,
                serialNumber: this.serial,
                installDate: this.installDate,
                inWarranty: this.inWarrantyValue
            }
        )
        .then(result => {
            showToast(this, 'Asset Created', 'Asset Created Succesfully', 'success');
            this.showSpinner = false;
        })
        .catch(error => {
            handleError(this, error);
            this.validateButtonDisabled = false;
            this.showSpinner = false;
        });
    }

    handleAssetValidate(event){
        if(!this.validateAssetFields(event)){
            return;
        }

        this.validateButtonDisabled = true;
        this.showSpinner = true;
        validateAsset({modelNumber:this.model})
            .then(result => {
                this.validateAssetResponse = JSON.parse(result);
                if(this.isFieldEmpty(this.validateAssetResponse.BrandCode)  && this.isFieldEmpty(this.validateAssetResponse.ProductTypeDesc))
                {
                    
                    this.validateAssetResponse = null;
                    showToast(this, 'Invalid Model Number',
                        'The Model Number is not valid',
                        'warning');
                    this.validateButtonDisabled = false;   
                }else{
                    console.log('validation is succesfull');
                    showToast(this, 'Validation Successfull',
                        'Asset validation is successfull',
                        'Info'); 
                    this.createAssetDisabled = false;
                }
                this.showSpinner = false;
            })
            .catch(error => {
                handleError(this, error);
                this.validateButtonDisabled = false;
                this.showSpinner = false;
            });
    }

    handleModelChange(event){
        this.model = event.target.value;
    }

    handleSerialChange(event){
        this.serial = event.target.value;
    }

    handleWarrantyChange(event) {
        this.inWarrantyValue = event.detail.value;
    }

    handleInstallDateChange(event){
        this.installDate = event.target.value;
    }

}