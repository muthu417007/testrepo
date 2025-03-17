import { LightningElement,track,api,wire } from 'lwc';
import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue, createRecord } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import MODEL_NUM from '@salesforce/schema/Asset.Model_Number__c';
import SERIAL_NUM from '@salesforce/schema/Asset.SerialNumber'; //Serial_Number__c';
import BILLING_STREET from '@salesforce/schema/Asset.Account.BillingStreet';
import BILLING_CITY from '@salesforce/schema/Asset.Account.BillingCity';
import BILLING_STATE from '@salesforce/schema/Asset.Account.BillingState';
import BILLING_POSTAL from '@salesforce/schema/Asset.Account.BillingPostalCode';
import BILLING_COUNTRY from '@salesforce/schema/Asset.Account.BillingCountry';
import SHIPPING_STREET from '@salesforce/schema/Asset.Account.ShippingStreet';
import SHIPPING_CITY from '@salesforce/schema/Asset.Account.ShippingCity';
import SHIPPING_STATE from '@salesforce/schema/Asset.Account.ShippingState';
import SHIPPING_POSTAL from '@salesforce/schema/Asset.Account.ShippingPostalCode';
import SHIPPING_COUNTRY from '@salesforce/schema/Asset.Account.ShippingCountry';
import PRIMARY_PHONE from '@salesforce/schema/Asset.Primary_Phone__c';
import CONSUMER_NAME from '@salesforce/schema/Asset.Contact.Name';
import OWNER_CONTACT from '@salesforce/schema/Asset.Contact.Id';
import OWNER_ACCOUNT from '@salesforce/schema/Asset.Account.Id';
import MANUFACTURING_LOCATION from '@salesforce/schema/Asset.Product2.Manufacturing_Location__c';
import uid from '@salesforce/user/Id';
import VA_CHATDETAIL_OBJ from '@salesforce/schema/VAChat_Details__c';
import CASE_RECORD from '@salesforce/schema/Case';
import createVAChatDetail from '@salesforce/apex/VA_ChatApiRelatedData.upsertVaChatDetail';
//import upsertCaseRec from '@salesforce/apex/VA_ChatApiRelatedData.upsertCaseRecord';
import apiDataChannel from "@salesforce/messageChannel/apidatachannel__c";
import { createMessageContext, releaseMessageContext, subscribe, unsubscribe } from 'lightning/messageService';
import { MessageContext, APPLICATION_SCOPE, publish } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ConsumerState from '@salesforce/schema/Case.State__c';
import CASE_OBJECT from '@salesforce/schema/Case';
import getQueueRecordId from '@salesforce/apex/VA_ChatApiRelatedData.getFSSavewithPartsQueueID';

export default class VaQuickActions extends NavigationMixin(LightningElement) {
    issaveparts=false;
    @track userId=uid;
    @track queueid;
    subscription=null;
    @track caseCreating=false;
    commentMsgFlag=false;
    @track vaAuditRecord=VA_CHATDETAIL_OBJ;
    @track caseRecord= CASE_RECORD;
    @track applianceType;
    @track applianceTypeLabel;
    @track problemCategory;
    @track problemCategoryLabel;
    @track SWPDisabled = false;
    @track phone;
    @track model;
    @track serial;
    @track param1;
    @track notes;
    @track userPhone;
    @track consumerName;
    @track displayCase;
    @track SWPcaseNumber;
    @track partsDesc;
    @track partsQty;
    STCDisabled=false;
    @track partsConfirmFlag=false;
    NSDisabled=false;
    @track totalparts=1;
    @track partslimit=8;
    @track streetAddress1;
    @track streetAddress2;
    @track zipCode;
    @track city;
    @track state;
    @track country;
    @track caseRecordId;
    @track caseNumber;
    @track ownerContactId;
    @track caseRecordTypeId;
    @track warrantySerial = false;
    @track ownerAccountId;
    @track manufacturingLocation;
    keyIndex = 0;
    error;
    urlStateParameters;
    enrId;
    @api recordId;
    context = createMessageContext();
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.urlStateParameters = currentPageReference.state;
          this.setParametersBasedOnUrl();
       }
    }
    @wire(getQueueRecordId, { queueName : 'FSSWPSavewithParts'})
    wiredQueue({error,data}) {
        if(error){
            console.log('error occured while queue retriving');
        }
        else if(data) {
            this.queueid = data;
            console.log('queue id is -> '+this.queueid);
        }
    }
    setParametersBasedOnUrl() {
        this.enrId = this.urlStateParameters.EnrId || null;
        console.log('url is '+JSON.stringify(this.urlStateParameters));
        if(JSON.stringify(this.urlStateParameters)!='{}')
            this.recordId=this.urlStateParameters.ws.split('/')[4];
     }

     @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    caseObjectData;

    @wire(getPicklistValues,
        {
            recordTypeId: '$caseObjectData.data.defaultRecordTypeId',
            fieldApiName: ConsumerState
        }
    )
    ConsumerState;


     @wire(getRecord, { recordId: '$recordId', fields: [MODEL_NUM,SERIAL_NUM,BILLING_STREET,BILLING_CITY,BILLING_STATE,BILLING_POSTAL,BILLING_COUNTRY,SHIPPING_STREET,SHIPPING_CITY,SHIPPING_STATE,SHIPPING_POSTAL,SHIPPING_COUNTRY,PRIMARY_PHONE,CONSUMER_NAME,OWNER_CONTACT,OWNER_ACCOUNT,MANUFACTURING_LOCATION] })
     wiredUser({error,data}) {
         if(error){
             this.error=error;
         }
         else if(data){
            console.log('model and serial -->'+JSON.stringify(data)+' '+data.fields.SerialNumber.value);
            this.streetAddress1=data.fields.Account.value.fields.ShippingStreet.value;
            this.ownerAccountId =data.fields.Account.value.fields.Id.value;
            this.city=data.fields.Account.value.fields.ShippingCity.value;
            //this.state=data.fields.Account.value.fields.ShippingState.value;
            this.zipCode=data.fields.Account.value.fields.ShippingPostalCode.value;
            this.country=data.fields.Account.value.fields.ShippingCountry.value;
            this.userPhone= data.fields.Primary_Phone__c.value;
            console.log('owner phone is '+this.userPhone);
            this.manufacturingLocation = data.fields.Product2.value.fields.Manufacturing_Location__c.value;
            this.consumerName = data.fields.Contact.value.fields.Name.value;
            this.ownerContactId = data.fields.Contact.value.fields.Id.value;
            console.log('owner account id is '+this.ownerAccountId);
         }
     }
     @wire(getObjectInfo, {objectApiName : CASE_RECORD})
     getObjectData({data,error}){
        if(data){
            console.log('default record type id is '+data.defaultRecordTypeId);
            //console.log('all record types '+JSON.stringify(data.recordTypeInfos));
            let recordTypeInfo = data.recordTypeInfos;
            for(let [key, recordtypeval] of Object.entries(recordTypeInfo)){
                if(recordtypeval.name == 'FS - Save with Parts')
                    this.caseRecordTypeId = recordtypeval.recordTypeId;

            }
            console.log('record type id is '+this.caseRecordTypeId);
        }
        else if(error){
            console.log('error'+error);
        }
     }
    connectedCallback(){
        //this.handleSubscribe();
        console.log('record');
    }
    disconnectedCallback() {
        this.handleUnsubscribe();
    }
    handleSubscribe() {
     if (this.subscription) {
         return;
     }
     this.context = createMessageContext();
     this.subscription = subscribe(this.context, apiDataChannel, (message) => {
         console.log('quick action component msg is ' + JSON.stringify(message));
         let msg = message.messageBody;
         let dt=msg.record;
         this.applianceType=dt.applianceType;
         this.applianceTypeLabel = dt.applianceTypeLabel;
         this.problemCategory=dt.problemCategory;
         this.problemCategoryLabel = dt.problemCategoryLabel;
         this.phone=dt.phoneNumber;
         this.model=dt.modelNumber;
         this.serial=dt.serialNumber;
         this.param1=dt.description;
         this.upsertAuditRecord();
     }, { scope: APPLICATION_SCOPE });
     
 }
    @track itemList = [
        {
            id: 0
        }
    ];
    saveParts(event){
        this.issaveparts=true;

    }
    closeModal(){
        this.issaveparts=false;
    }

    addRow() {
        if(this.itemList.length<8){
            ++this.keyIndex;
            var newItem = [{ id: this.keyIndex }];
            this.itemList = this.itemList.concat(newItem);
            this.totalparts=this.itemList.length;
        }
        else {
            console.log('max parts');
        }
    }

    removeRow(event) {
        if (this.itemList.length >= 2) {
            this.itemList = this.itemList.filter(function (element) {
                return parseInt(element.id) !== parseInt(event.target.accessKey);
            });
            this.totalparts=this.itemList.length;
        }
    }
    handleAuditCreation(event){
        console.log('event record is '+JSON.stringify(event.detail));
        let inputPayload=event.detail.record;
        this.applianceType=inputPayload.applianceType;
        this.applianceTypeLabel = inputPayload.applianceTypeLabel;
         this.problemCategory=inputPayload.problemCategory;
         this.problemCategoryLabel = inputPayload.problemCategoryLabel;
         this.phone=inputPayload.phoneNumber;
         this.model=inputPayload.modelNumber;
         this.serial=inputPayload.serialNumber;
         this.param1=inputPayload.description;
         this.warrantySerial = inputPayload.warrantySerial;

         if(!this.warrantySerial){
            this.NSDisabled = true;
            this.STCDisabled = true;
            this.SWPDisabled = true;
         }
         this.upsertAuditRecord();
     
    }
    handleNotSaveCall(){
        this.vaAuditRecord.Status__c='NS';
        console.log('record updated');
        this.upsertVaChatDetail();
    }
    handleSaveCall(){
        this.vaAuditRecord.Status__c='STC';
        console.log('record updated');
        this.upsertVaChatDetail();
        this.showToast('success','Success','Your response has been recorded');
    }
    upsertAuditRecord(){
        this.vaAuditRecord.ApplianceType__c=this.applianceType;
        this.vaAuditRecord.ModelNo__c=this.model;
        this.vaAuditRecord.ProblemCategory__c=this.problemCategory;
        this.vaAuditRecord.SerialNo__c=this.serial;
        this.vaAuditRecord.AdditionalDesc__c=this.param1!=null?this.param1:'';
        this.vaAuditRecord.Requested_by__c=this.userId;
        this.vaAuditRecord.Phone__c=this.phone;
        this.vaAuditRecord.Manufacturing_Site__c = this.manufacturingLocation;
        if(!this.warrantySerial)
            this.vaAuditRecord.Status__c='OW';
        else
            this.vaAuditRecord.Status__c='AB';
        this.upsertVaChatDetail();
        console.log('method to create audit record for VA');
    }

    upsertVaChatDetail(){

        createVAChatDetail( { auditRecord : this.vaAuditRecord })
        .then(result => {
            this.vaAuditRecord=result;
            console.log('vaAudit '+JSON.stringify(this.vaAuditRecord));
            this.caseCreating=false;
        })
        .catch(error => {
            console.log('error occured'+JSON.stringify(error));
        });
    }

    /*upsertCase(){

        upsertCaseRec( { caseRecord : this.caseRecord })
        .then(result => {
            console.log('result came----'+JSON.stringify(result));
            this.caseRecord=result;
            this.vaAuditRecord.Case__c = this.caseRecord.Id;
            console.log('caseRec '+JSON.stringify(this.caseRecord));
            this.upsertVaChatDetail();
            this.showToast('success','Success','Case#'+this.caseRecord.CaseNumber+' successfully created.');
            
            this.issaveparts=false;
        
        })
        .catch(error => {
            console.log('error occured while case creation '+JSON.stringify(error));
        });
    }*/

    handleUnsubscribe() {
        unsubscribe(this.subscription);
        this.subscription = undefined;
        releaseMessageContext(this.context);
    }
    get subscribeStatus() {
        return this.subscription ? 'TRUE' : 'FALSE';
    }

    closePartsConfirm() {
        this.partsConfirmFlag = false;
        this.issaveparts=true;
    }
     
    checkPartsConfirm() {
        this.partsConfirmFlag = true;
        this.issaveparts=false;
    }
    checkparts(){
        
        //this.partsConfirmFlag = false;
        //this.issaveparts=true;
        console.log('event created');
        
        this.userPhone = this.template.querySelector('lightning-input[data-name="userphone"]').value.trim();
        this.consumerName = this.template.querySelector('lightning-input[data-name="consumername"]').value.trim();
        this.streetAddress1 = this.template.querySelector('lightning-input[data-name="address1"]').value.trim();
        this.streetAddress2 = this.template.querySelector('lightning-input[data-name="address2"]').value.trim();
        this.city = this.template.querySelector('lightning-input[data-name="city"]').value.trim();
        //this.state = this.template.querySelector('lightning-input[data-name="state"]').value.trim();
        this.state = this.template.querySelector('[data-id="ConsumerState"]').value;
        this.zipCode = this.template.querySelector('lightning-input[data-name="zipcode"]').value.trim();
        console.log('address selected'+this.streetAddress1+' '+this.streetAddress2);
        this.notes= this.template.querySelector('lightning-textarea[data-name="notes"]').value;
        console.log('Notes selected'+this.notes);
        let partsDescInputs = this.template.querySelectorAll('.partsdesc');
        this.partsDesc='';
        let partsQtyInputs = this.template.querySelectorAll('.partsqtys');
        this.partsQty='';
        let haspartsInput=true;
        console.log('parts input started');
        partsDescInputs.forEach( (item,idx) => {
            console.log('Desc --------->> '+item.value);
            if(item.value && partsQtyInputs[idx].value)
                this.partsDesc +=(idx+1)+'. '+item.value+' - '+ partsQtyInputs[idx].value+'\n';
            else {
                haspartsInput = false;
                this.showToast('error','Required Fields Missing','Please input the required fields');

            }
        });
        partsQtyInputs.forEach( item => {
            console.log('qty --------->> '+item.value);
            this.partsQty += item.value+' ';
        });
        console.log('parts desc => '+partsDescInputs.length+' '+partsQtyInputs.length);
        if(!haspartsInput || !this.userPhone || !this.consumerName || !this.streetAddress1 || !this.zipCode || !this.city || !this.state){
            this.showToast('error','Required Fields Missing','Please input the required fields');
        }
        else {
            console.log('event updated');
            this.caseCreating=true;
            //this.issaveparts=false;
            this.vaAuditRecord.Status__c='SWP';
            //this.upsertVaChatDetail();
            this.caseRecord.Case_Type__c= 'Parts';
            this.caseRecord.Subject= 'Factory Service VA - Save with Parts';
            this.caseRecord.Origin = 'Factory Service - VA';
            this.caseRecord.Comments = this.partsDesc;
            this.caseRecord.Parts_Research_Notes__c=this.notes;
            this.caseRecord.Phone_Number__c= this.userPhone;
            this.caseRecord.First_Name__c= this.consumerName;
            this.caseRecord.Last_Name__c= this.consumerName;
            this.caseRecord.Street_Address__c= this.streetAddress1+' '+this.streetAddress2;
            this.caseRecord.City__c=this.city;
            //this.caseRecord.State__c=this.state;
            this.caseRecord.Zip_Postal_Code__c=this.zipCode;
            this.caseRecord.Country__c=this.country;
            this.caseRecord.Model_Number__c= this.model;
            this.caseRecord.Serial_Number__c= this.serial;
            this.caseRecord.Product_Type__c = this.applianceTypeLabel;
            this.caseRecord.RecordTypeId = this.caseRecordTypeId;
            console.log('---------upsert  starts ...');
            //this.upsertCase();
            this.insertCaseRecord();
            console.log('upsert done');
            this.STCDisabled=true;
            this.NSDisabled=true;
            this.SWPDisabled = true;
        }       
    }

    showToast(variant,title,message){
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        dispatchEvent(toastEvent);

    }
    insertCaseRecord(event){
        let nameList = this.consumerName.split(" ");
        let lastnameList = nameList.slice(1);
        let caseFields = {
            'Case_Type__c' : 'Parts',
            'Origin' : 'Factory Service - VA',
            'Reason' : 'Parts',
            'Subject' : 'Factory Service VA - Save with Parts - '+this.model+' - '+this.serial,
            'Phone_Number__c' : this.userPhone,
            'First_Name__c' : nameList[0],
            'ContactId' : this.ownerContactId,
            'AccountId' : this.ownerAccountId,
            'Last_Name__c' : lastnameList.join(" "),
            'Street_Address__c' : this.streetAddress1+' '+this.streetAddress2,
            'City__c' : this.city,
            'State__c' : this.state,
            'Zip_Postal_Code__c' : this.zipCode,
            //'Country__c' : this.country,
            'Model_Number__c' : this.model,
            'Product_Type__c' : this.applianceTypeLabel,
            'Comments' : this.partsDesc,
            'Serial_Number__c' : this.serial,
            'Parts_Research_Notes__c' : this.notes,
            'RecordTypeId' : this.caseRecordTypeId,
            'AssetId' : this.recordId,
            'OwnerId' : this.queueid //'00G7A0000047FBYUA2'
        };

        let caseObjectFields = { 'apiName' : 'Case', fields : caseFields };

        createRecord(caseObjectFields)
        .then((record) => {
            console.log('record is '+record.id);
            this.vaAuditRecord.Case__c = record.id;
            this.caseRecordId = record.id;
            this.displayCase = true;
            this.caseNumber = record.fields.CaseNumber.value;
            this.SWPcaseNumber = 'Save with Parts case # '+this.caseNumber;
            console.log('caseRec '+JSON.stringify(record));
            this.upsertVaChatDetail();
            
            this.showToast('success','Success','Case#'+record.fields.CaseNumber.value+' successfully created.');
            this.issaveparts=false;
        
        })
        .catch(error => { 
            this.caseCreating = false;
            this.showToast('error','Failed','Case creation failed.');
            
            console.log('error occured-- '+JSON.stringify(error))});

    }

    openCaseRecord(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.caseRecordId,
                actionName: 'view'
            }
        });

    }
    addComments(){
        this.handleNotSaveCall();
        this.commentMsgFlag=true;
    }
    handleCommentsAdded() {
        let comments=this.template.querySelector('lightning-textarea[data-name="comments"]').value.trim();
        console.log('comments added are '+comments);
        this.vaAuditRecord.VAReponseComments__c=comments;
        this.upsertVaChatDetail();
        this.commentMsgFlag=false;
        this.showToast('success','Success','Your response has been recorded');
    }
    closeComments(){
        this.commentMsgFlag=false;
        this.showToast('success','Success','Your response has been recorded');
    }
}