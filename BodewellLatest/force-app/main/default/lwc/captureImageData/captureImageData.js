import { LightningElement, api, track, wire } from 'lwc';
import { getBarcodeScanner } from 'lightning/mobileCapabilities';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord,getFieldValue,deleteRecord,createRecord } from 'lightning/uiRecordApi';
import attachFiles from '@salesforce/apex/CreateAssetsController.attachFilesToGEAAsset';
import getBrands from '@salesforce/apex/CreateAssetsController.getBrandValuesIntoList';
import getTextFromPicture from '@salesforce/apex/CreateAssetsController.getTextFromPictureOCR';
import FORM_FACTOR from '@salesforce/client/formFactor';

const GEAAssetfields = [
    'Asset.Model_Number__c',
    'Asset.SerialNumber',
    'Asset.InstallDate',
    'Asset.Scanned_Barcode_Value__c'
]

export default class CaptureImageData extends LightningElement {
    @api recordId;
    isBarcodeScan = false;
    isScan = false;
    isCapturePicture = false;
    scanButtonDisabled = false;
    showSpinner = false;
    isDesktop = FORM_FACTOR === 'Large' ? true : false;
    scannedBarcode = '';
    scannedSerialNumber = '';
    scannedModel = '';
    myScanner;
    selectedBrand;
    showOtherBrandInput = false;
    otherBrand;
    brandsList;
    GEAAssetId;
    OCRfileId;
    textFromPicture = [];
    @track ocrOptions = [];

    @wire(getBrands)
    prepareBrandsList({ error, data }){
        if (data) {
            let brands = [];

            data.forEach(brand => {
                brands.push({
                    label: brand, 
                    value: brand
                });
            });

            this.brandsList = brands;
        }
    }

    @track uploadedFiles = [];
    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg'];
    }

    @wire(getRecord, { recordId: '$recordId', fields: ['Case.Owner_Consent__c', 'Case.Contact.AccountId']})
    caseRecord;

    get ownerconsent() {
        return getFieldValue(this.caseRecord.data, 'Case.Owner_Consent__c');
    }

    get accountid() {
        return getFieldValue(this.caseRecord.data, 'Case.Contact.AccountId');
    }

//**BARCORDE SCANNER */

    handleBarcodeScan(event) {
        this.scannedBarcode = '';
        this.scannedSerialNumber = '';
        this.scannedModel = '';
        this.ocrOptions = [];

        if (this.myScanner != null && this.myScanner.isAvailable()) {
            const scanningOptions = {barcodeTypes: []};
            this.myScanner
                .beginCapture(scanningOptions)
                .then((result) => {
                    this.isBarcodeScan = true;
                    this.scannedBarcode = decodeURIComponent(result.value);
                    let snRegex = /\&S=(.*?)\&/;
                    let modelRegex = /\&M=(.*?)\&/;
                    if(snRegex.exec(this.scannedBarcode) && snRegex.exec(this.scannedBarcode).length >=2){
                        this.isScan = true;
                        this.scannedSerialNumber = snRegex.exec(this.scannedBarcode)[1];
                        if (this.ocrOptions.filter(o => o.value === this.scannedSerialNumber).length === 0) {
                            this.ocrOptions = [ ...this.ocrOptions, {label: this.scannedSerialNumber, value: this.scannedSerialNumber} ];
                        }
                    }
                    if(modelRegex.exec(this.scannedBarcode) && modelRegex.exec(this.scannedBarcode).length >=2){
                        this.isScan = true;
                        this.scannedModel = modelRegex.exec(this.scannedBarcode)[1];
                        if (this.ocrOptions.filter(o => o.value === this.scannedModel).length === 0) {
                            this.ocrOptions = [ ...this.ocrOptions, {label: this.scannedModel, value: this.scannedModel} ];
                        }
                    }

                    this.showToast('Success: ', 'Barcode scanned successfully!', 'success');
                })
                .catch((error) => {
                    this.showToast('Error: ','There was a problem scanning the barcode: ' + JSON.stringify(error) + ' Please try again.','error');
                })
                .finally(() => {
                    this.myScanner.endCapture();
                });
        } else {
            this.showToast('Error: ', 'Try again from the Salesforce app on a mobile device.', 'error');
        }
    }

    connectedCallback() {
        this.myScanner = getBarcodeScanner();
        if (this.myScanner == null || !this.myScanner.isAvailable()) {
            this.scanButtonDisabled = true;
        }
    }

    handleClearBarcode(){
        this.isBarcodeScan = false;
        this.scannedBarcode = '';
        this.scannedModel = '';
        this.scannedSerialNumber = '';
    }

    //**CREATE ASSETS */

    @wire(getRecord, { recordId: '$GEAAssetId', fields: GEAAssetfields })
    wiredGEAAsset(value) {
        if(value.data && this.GEAAssetId) {
            //create Case Asset
            const recordInput = {
                apiName: 'Case_Asset__c',
                fields: {
                    Case__c: this.recordId,
                    Asset__c: this.GEAAssetId,
                    Brand__c: this.selectedBrand,
                    Other_Brand__c: this.otherBrand,
                    Model_Number__c: value.data.fields.Model_Number__c.value,
                    Serial_Number__c: value.data.fields.SerialNumber.value,
                    Install_Date__c: value.data.fields.InstallDate.value,
                    Scanned_Barcode_Value__c: value.data.fields.Scanned_Barcode_Value__c.value
                }
            };
            createRecord(recordInput)
                .then(asset => {
                    this.showToast('Success: ', 'Assets were created successfully!', 'success');
                    this.resetInputForm();
                    this.showSpinner = false;
                })
                .catch(error => {
                    this.showToast('Error: ', "An error occurred while attempting to save Case Asset: " + error.body.message, 'error');
                    this.showSpinner = false;
                });
        } else if (value.error) {
            this.showToast('Error', value.error,'error');
            this.showSpinner = false;
        }
    }

    handleBrandChange(event){
        this.selectedBrand = event.target.value;

        if(this.selectedBrand == 'Other Non-GEA'){
            this.showOtherBrandInput = true;
        } else {
            this.showOtherBrandInput = false;
        }
    }

    handleOtherBrandChange(event){
        this.otherBrand = event.target.value;
    }

    handleSubmit(event) {
        const fields = event.detail.fields;
        fields.AccountId = this.accountid;
        fields.Is_Created_By_Quick_Action__c = true;
        fields.BrandName__c = this.selectedBrand;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        this.showSpinner = true;
    }

    handleSuccess(event) {
        this.GEAAssetId = event.detail.id;
        this.attachFilesToAsset();
    }

    handleError(event) {
        this.showSpinner = false;
        this.showToast('Error: ', "An error occurred while attempting to save GEA Asset: " + event.detail.detail, 'error');
    }

    resetInputForm() {
        let inputFields = this.template.querySelectorAll('lightning-input-field');
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
        inputFields = this.template.querySelectorAll('.brand');
        if (inputFields) {
            inputFields.forEach(field => {
                field.value = '';
            });
        }
        inputFields = this.template.querySelectorAll('.otherBrand');
        if (inputFields) {
            inputFields.forEach(field => {
                field.value = '';
            });
        }

        this.scannedBarcode = '';
        this.uploadedFiles = [];
        this.isBarcodeScan = false;
        this.isScan = false;
        this.isCapturePicture = false;
        this.selectedBrand = '';
        this.otherBrand = '';
        this.showOtherBrandInput = false;
    }

    attachFilesToAsset(){
        const filesIdList = [];
        this.uploadedFiles.forEach(file => {
            filesIdList.push(file.documentId);
        });

        if(filesIdList.length > 0){
            attachFiles({ assetId: this.GEAAssetId, filesIdList: filesIdList })
                .then(result => {})
                .catch(error => {
                    this.showToast('Error: ',"An error occurred while attaching files to the GEA Asset " + error.body.message,'error');
                });
        }
    }

    //**PICTURE UPLOAD */

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        this.uploadedFiles.push(uploadedFiles[0]);
        this.isCapturePicture = true;
        this.showToast('Success: ','File uploaded Successfully!','success');
    }

    handleDeleteFile(event) {
        const fileToDeleteId = event.target.dataset.item;
        deleteRecord(fileToDeleteId)
            .then(() => {
                const index = this.uploadedFiles.map(file => {return file.documentId;}).indexOf(fileToDeleteId);
                this.uploadedFiles.splice(index, 1);
                this.showToast('Success: ','File deleted successfully!','success');
            })
            .catch(error => {
                this.showToast('Error:',error.body.message,'error');
            });
    }

    //**OCR SCANNER */

    @wire(getTextFromPicture, {
        documentId: '$OCRfileId'
    })
    wiredText(value) {
        this.textFromPicture = value.data;
        if(this.textFromPicture && this.textFromPicture.length > 0){
            this.ocrOptions = [];
            for(let i=0; i<this.textFromPicture.length; i++){
                if (this.ocrOptions.filter(o => o.value === this.textFromPicture[i]).length === 0) {
                    this.ocrOptions = [ ...this.ocrOptions, {label: this.textFromPicture[i], value: this.textFromPicture[i]} ];
                }
            }
            this.isScan = true;
        }
    }

    handleOCRScan(event) {
        const uploadedFiles = event.detail.files
        this.uploadedFiles.push(uploadedFiles[0]);
        this.isCapturePicture = true;

        const documentId = uploadedFiles[0].documentId;
        this.OCRfileId = documentId;
        this.showToast('Success: ','File scanned and uploaded successfully!','success');
    }

    handleSerialNumberChange(event){
        this.scannedSerialNumber = event.detail.value;
    }

    handleModelChange(event){
        this.scannedModel = event.detail.value;
    }

    handleClearOCR(){
        this.textFromPicture = [];
        this.isScan = false;
    }

    //**SHOW TOAST */

    showToast(title,message,variant) {
        this.dispatchEvent(new ShowToastEvent({title: title, message: message, variant: variant}));
    }
}