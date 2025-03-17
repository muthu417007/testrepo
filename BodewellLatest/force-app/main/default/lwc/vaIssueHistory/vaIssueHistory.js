import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import apiDataChannel from "@salesforce/messageChannel/apidatachannel__c";
import { createMessageContext, releaseMessageContext, subscribe, unsubscribe } from 'lightning/messageService';
import { MessageContext, APPLICATION_SCOPE, publish } from 'lightning/messageService';
import uid from '@salesforce/user/Id';
import getInteactionHistory from '@salesforce/apex/VA_ChatApiRelatedData.getVaChatDetail';
import getModelResponse from '@salesforce/apex/VA_ChatApiRelatedData.getModelData';
import getSerialResponse from '@salesforce/apex/VA_ChatApiRelatedData.getSerialData';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import PART_NAME from '@salesforce/schema/Case.First_Name__c';
import QTY from '@salesforce/schema/Case.First_Name__c';
import ORDER from '@salesforce/schema/Case.Last_Name__c';
import ORD_DATE from '@salesforce/schema/Case.First_Name__c';
import ORD_BY from '@salesforce/schema/Case.Last_Name__c';
import NOTES from '@salesforce/schema/Case.First_Name__c';
import CASE_NUMBER from '@salesforce/schema/Case.CaseNumber';

export default class VaIssueHistory extends NavigationMixin(LightningElement) {
    isIssueHistory=false;
    @api rId;
    @track userId=uid;
    subscription=null;
    viewAuditRecord=true;
    @track applianceType;
    recordPageUrl;
    @track problemCategory;
    @track selectedProblem;
    @track modelColumns=[];
    @track serialColumns=[];
    @track modelNumberData = [];
    @track serialNumberData = [];
    @track 
    @track phone;
    @track model;
    @track serial;
    @track param1;
    @track historyData=[];
    @track historyColumns=[];
    @track partsRecords= [];
    @track partsColumns = [];
    @track nopartsRecords=true;
    context = createMessageContext();
    @track caseRecordId;

    @wire(getRecord, { recordId: '$caseRecordId', fields: [CASE_NUMBER,PART_NAME,QTY,ORDER,ORD_BY,ORD_DATE,NOTES] })
    wiredCase({error,data}) {
        if(error){
            this.error=error;
        }
        else if(data){
            this.partsRecords=[];
            let partRecord = {
                'CaseNumber' : data.fields.CaseNumber.value,
                'PartName' : data.fields.First_Name__c.value,
                'Quantity' : data.fields.Last_Name__c.value,
                'Order' : data.fields.First_Name__c.value,
                'OrderDate' : data.fields.First_Name__c.value,
                'OrderBy' : data.fields.Last_Name__c.value,
                'Notes' : data.fields.First_Name__c.value
            }
            
            this.partsRecords.push(partRecord);
            console.log('parts records '+this.partsRecords);
        }
    }
    connectedCallback(){
        this.isIssueHistory=true;
        this.historyColumns= [
                { label: 'DATE', fieldName: 'CreatedDate' },
                { label: 'SUMMARY', fieldName: 'ProblemCategory__c' },
                { label: 'STATUS', fieldName: 'Status__c' },
                { label: 'VA/BOT', fieldName: 'Va_Bot' },
                { label: 'PHONE', fieldName: 'Phone__c' },
                /*{ label: 'PARTS', type: 'button-icon', fieldName: 'checkparts', 
                    typeAttributes: { label: 'Parts', iconName: 'utility:preview', name: 'viewparts', value: 'checkparts'}}*/
                {
                        label: 'CASE#', fieldName: 'CaseNumber', type: 'button', wrapText: true, sortable: true,
                        typeAttributes: {
                          label:
                          {
                            fieldName: 'CaseNumber'
                          },
                          variant: 'base',
                          //target : '_blank'
                        }
                },
                { label: 'ORDER No.', fieldName: 'OrderNumber' },
        ];

        this.partsColumns = [ 
            {
                label: 'Case#', fieldName: 'CaseNumber', type: 'button', wrapText: true, sortable: true,
                typeAttributes: {
                  label:
                  {
                    fieldName: 'CaseNumber'
                  },
                  variant: 'base',
                  //target : '_blank'
                }
              },
            { label : 'Part#Name', fieldName : 'PartName'},
            { label: 'Qty', fieldName: 'Quantity' },
            { label: 'Order', fieldName: 'Order' },
            { label: 'Order Date', fieldName: 'OrderDate' },
            { label: 'Order By', fieldName: 'OrderBy' },
            { label: 'Notes', fieldName: 'Notes' }
                
         ];

         this.modelColumns = [ 
            { label: 'TOP 5 ISSUES', fieldName: 'TOP_5_ISSUES' }
         ];
         this.serialColumns = [
            { label: 'DATE', fieldName: 'serviceDate' },
            { label: 'PROBLEM', fieldName: 'problem' },
            { label: 'JOB DESC', fieldName: 'jobDesc' },
            { label: 'PARTS', fieldName: 'parts' }

         ];
        this.handleSubscribe();
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
         console.log('quick action component msg is ' + message);
         let msg = message.messageBody;
         let dt=msg.record;
         this.applianceType=dt.applianceType;
         this.problemCategory=dt.problemCategory;
         this.phone=dt.phoneNumber;
         this.model=dt.modelNumber;
         this.serial=dt.serialNumber;
         this.param1=dt.description;
         this.getHistoryData();
         this.getModelNumberData();
         this.getSerialNumberData();
     }, { scope: APPLICATION_SCOPE });
     
    }

    custom_sort(a, b) {
        return -(new Date(a.CreatedDate).getTime() - new Date(b.CreatedDate).getTime());
    }
    getHistoryData(){
        getInteactionHistory( {
            model :this.model, serial: this.serial, userId : this.userId
        })
        .then((res1)=> {
            console.log('resp is '+res1);
            let res2 = JSON.parse(res1);
            console.log('------------------- '+JSON.stringify(res2));
            let res = res2.records;
            res.sort(this.custom_sort);
            console.log('============ '+res);
            for(let t=0;t<res.length;t++){
                console.log('created date'+res[t].CreatedDate);
                let req_date=new Date(res[t].CreatedDate);
                let dte= req_date.getDate()+'';
                let mnt= (req_date.getMonth()+1)+'';
                if (dte.length==1)
                    dte='0'+dte;
                if(mnt.length==1)
                    mnt='0'+mnt;

                res[t].CreatedDate= mnt+'/'+dte;
                console.log('created date'+res[t].CreatedDate);

                //console.log('audit records -> '+JSON.stringify(res));
                if(res[t].Case__c!=null && res[t].Case__c!=''){
                    res[t]["CaseNumber"] = res[t].CaseNumber;
                    res[t]["CaseId"] = res[t].Case__c;
                    res[t]["OrderNumber"] = res[t].OrderNumber;
                }
            }
            this.historyData=res;
        })
        .catch(error => {
            console.log('error occured'+JSON.stringify(error));
        });
    }
    getModelNumberData(){
        getModelResponse({ model : this.model})
        .then((res)=> {
            let modelRes = JSON.parse(res);
            this.modelNumberData = modelRes.records;
        })
        .catch(error => {
            console.log('error occured'+JSON.stringify(error));
        });
    }
    getSerialNumberData(){
        getSerialResponse({ serial : this.serial, model : this.model, phone : this.phone })
        .then((res)=> {
            let serialRes = JSON.parse(res);
            this.serialNumberData = serialRes.records;
        })
        .catch(error => {
            console.log('error occured'+JSON.stringify(error));
        });
    }
    handleUnsubscribe() {
        unsubscribe(this.subscription);
        this.subscription = undefined;
        releaseMessageContext(this.context);
    }
    get subscribeStatus() {
        return this.subscription ? 'TRUE' : 'FALSE';
    }
    checkpartsdata(event){
        const row=event.detail.row;
        console.log('row is '+JSON.stringify(row));
        const actionname=event.detail.action.name;
        if(actionname=='viewparts'){
            this.partsRecords= [];
            this.nopartsRecords=true;
        
            if(row.Status__c == 'SWP' && row.Case__c != null) {
                this.caseRecordId=row.Case__c;
                this.nopartsRecords=false;
            }
            else
                this.caseRecordId = null;
            this.selectedProblem=row.ProblemCategory__c;
            this.viewAuditRecord=false;
            console.log('parts are checked ...');
        }

    }

    navigatetoCase(event) {
        let row = event.detail.row;
        this.caseRecordId = row.CaseId;
        console.log('case record id is '+this.caseRecordId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.caseRecordId,
                actionName: 'view'
            }
        });
    }
    handleBack(event){
        this.viewAuditRecord=true;
    }

}