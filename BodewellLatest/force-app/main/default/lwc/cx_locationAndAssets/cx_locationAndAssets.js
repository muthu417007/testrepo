import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getLocations from '@salesforce/apex/CX_LocationAndAssetsController.getLocations';
import getAssets from '@salesforce/apex/CX_LocationAndAssetsController.getAssets';

const locationColumns = [
    {label: 'Street', fieldName: 'BillingStreet', type: 'text'},
    {label: 'City', fieldName: 'BillingCity', type: 'text'},
    {label: 'State', fieldName: 'BillingState', type: 'text'},
    {label: 'Zip code', fieldName: 'BillingPostalCode', type: 'text'}
];
const assetColumns = [
    {label: 'Model number', fieldName: 'Model_Number__c', type: 'text'},
    {label: 'Serial number', fieldName: 'SerialNumber', type: 'text'},
    {label: 'Install date', fieldName: 'InstallDate', type: 'date'},
    {label: 'Brand', fieldName: 'BrandName__c', type: 'text'},
    {label: 'Product type', fieldName: 'Product_Type__c', type: 'text'},
    {label: 'Product line', fieldName: 'Product_Line__c', type: 'text'},
    {label: 'Location', fieldName: 'AccountId', type: 'text'}
];

export default class Cx_locationAndAssets extends LightningElement {

    @api contactId;
    @api CX_contactId;

    locations = [];
    assets = [];

    locationColumns = locationColumns;
    assetColumns = assetColumns;

    newLocation = {
        BillingStreet: '',
        BillingCity: '',
        BillingState: '',
        BillingPostalCode: ''
    };
    newAsset = {
        Model_Number__c: '',
        SerialNumber: '',
        InstallDate: '',
        BrandName__c: '',
        Product_Type__c: '',
        Product_Line__c: '',
        AccountId: ''
    };

    @wire(getLocations, { contactId: '$contactId' })
    wireLocations ({error, data}) {
        if (data) {
            this.locations = data;
        } else if (error) {
            this.locations = [];
            this.showToast('error', error);
        }
    }

    @wire(getAssets, { contactId: '$contactId' })
    wireAssets ({error, data}) {
        if (data) {
            this.assets = data;
        } else if (error) {
            this.assets = [];
            this.showToast('error', error);
        }
    }

    handleCreateLocationClick () {
        let newArray = JSON.parse(JSON.stringify(this.locations));
        newArray.push(this.newLocation);
        this.locations = newArray;
    }

    handleCreateAssetClick () {
        let newArray = JSON.parse(JSON.stringify(this.assets));
        newArray.push(this.newAsset);
        this.assets = newArray;
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

    handleLocationSelect (event) {
        let selectLocationEvent = new CustomEvent('locationselected', {detail: event.detail.selectedRows});
        this.dispatchEvent(selectLocationEvent);
    }
    
    handleAssetSelect (event) {
        let selectAssetEvent = new CustomEvent('assetselected', {detail: event.detail.selectedRows});
        this.dispatchEvent(selectAssetEvent);
    }

    handleBillingStreetChange (event) {
        this.newLocation.BillingStreet = event.detail.value;
    }
    handleBillingCityChange (event) {
        this.newLocation.BillingCity = event.detail.value;
    }
    handleBillingStateChange (event) {
        this.newLocation.BillingState = event.detail.value;
    }
    handleBillingPostalCodeChange (event) {
        this.newLocation.BillingPostalCode = event.detail.value;
    }
    handleModelNumerChange (event) {
        this.newAsset.Model_Number__c = event.detail.value;
    }
    handleSerialNumberChange (event) {
        this.newAsset.SerialNumber = event.detail.value;
    }
    handleInstallDataChange (event) {
        this.newAsset.InstallDate = event.detail.value;
    }
    handleBrandNameChange (event) {
        this.newAsset.BrandName__c = event.detail.value;
    }
    handleProductTypeChange (event) {
        this.newAsset.Product_Type__c = event.detail.value;
    }
    handleProductLineChange (event) {
        this.newAsset.Product_Line__c = event.detail.value;
    }
    handleAccountLocationChange (event) {
        this.newAsset.AccountId = event.detail.value;
    }
}