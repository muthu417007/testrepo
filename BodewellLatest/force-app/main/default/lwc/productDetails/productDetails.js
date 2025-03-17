import { LightningElement, api, wire, track } from 'lwc';
//import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
//import { updateRecord } from 'lightning/uiRecordApi';
//import { refreshApex } from '@salesforce/apex';
//import { NavigationMixin } from 'lightning/navigation';
import Id_Field from '@salesforce/schema/Asset.Id';
import Model_Number from '@salesforce/schema/Asset.Model_Number__c';
import OriginalModelNumber from '@salesforce/schema/Asset.OriginalModelNumber__c';
import Serial_Number from '@salesforce/schema/Asset.SerialNumber';
import Install_Date from '@salesforce/schema/Asset.InstallDate';
import Nickname from '@salesforce/schema/Asset.AssetNickname__c';
import Valid_Model from '@salesforce/schema/Asset.ModelValidityFlag__c';
import MYA_EndecaResponseDetails from '@salesforce/apex/MYA_EndecaApiHandler.MYA_EndecaResponseDetails';

const img_columns = [
    { label: 'Image Id'},
    { label: 'Image Name' }
];   


export default class productDetails extends LightningElement {

productImages = [];
columns = img_columns;
AstDetail;
modelNo;
recordId;
ValidModel;
wiredAssetDetails;
assetDetails;
@api recordId;

@wire(getRecord, { recordId: '$recordId', fields: [Model_Number, OriginalModelNumber, Serial_Number, Install_Date] })
WiredAsset(result) {
    this.wiredAssetDetails = result;
    if (result) {
        this.assetDetails = result;
        if (this.assetDetails.data) {
            this.modelNo = this.assetDetails.data.fields.Model_Number__c.value;
            this.ValidModel = this.assetDetails.data.fields.ModelValidityFlag__c.value;
        }
        if(!this.modelNo) {
            this.modelNo = this.assetDetails.data.fields.OriginalModelNumber__c.value;
        }
        /*MYA_EndecaResponseDetails({ SKU: this.modelNo }) //call endeca function to get product details
            .then((res) => {
            this.AstDetail = res.ProductInfo;
            console.log('AstDetail: '+ this.AstDetail);
        }).catch((error) => {
            console.error('Product Details: ',error);
        });*/
    }
}       
}