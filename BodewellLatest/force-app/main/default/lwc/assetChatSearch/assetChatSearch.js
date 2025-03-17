import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import MODEL_NUM from '@salesforce/schema/Asset.Model_Number__c';
import SERIAL_NUM from '@salesforce/schema/Asset.SerialNumber';//Serial_Number__c
//import APPLIANCE_TYPE from '@salesforce/schema/Asset.Appliance_Type__c';
import PRODUCT_LINE_DESC from '@salesforce/schema/Asset.Product_Line_Desc__c';
import PHONE_NUM from '@salesforce/schema/Asset.Primary_Phone__c';
import PRODUCT_SKU from '@salesforce/schema/Product2.StockKeepingUnit';
import IS_MANUFACTURING_MODEL from '@salesforce/schema/Product2.Is_Manufacturing_Model__c';
import MARKETING_MODEL from '@salesforce/schema/Product2.Marketing_Model__c';
import { MessageContext, APPLICATION_SCOPE, publish } from 'lightning/messageService';
import apidatachannel from "@salesforce/messageChannel/apidatachannel__c";
import modeleventchannel from "@salesforce/messageChannel/modeleventchannel__c";
//import getContacts from '@salesforce/apex/GetGraphQLAPIData.getArchivedContacts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkSerialWarranty from '@salesforce/apex/VA_ChatApiRelatedData.checkSerialWarranty';
import getProductData from '@salesforce/apex/VA_ChatApiRelatedData.getProduct2Record';
//import getApplianceModelMapping from '@salesforce/apex/VA_ChatApiRelatedData.getApplianceModelMappingData';
//import getMuleData from '@salesforce/apex/RequestMuleAPIData.getMuleAPIData';
import getEndecaData from '@salesforce/apex/VA_RequestEndecaApiData.EndecaData';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import uid from '@salesforce/user/Id';
import VA_CHATDETAIL_OBJ from '@salesforce/schema/VAChat_Details__c';
import Appliance_Type_Values from '@salesforce/schema/VAChat_Details__c.ApplianceType__c';
import createVAChatDetail from '@salesforce/apex/VA_ChatApiRelatedData.upsertVaChatDetail';
import { getObjectInfo, getPicklistValues, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';

export default class AssetChatSearch extends LightningElement {
    @track vaAuditRecord=VA_CHATDETAIL_OBJ;
    @track shopPopup=true;
    @track userid=uid;
    @track ReceivedAPIDataflag=false;
    @track marketingModel;
    @wire(MessageContext)
    context;
    @ track isapicall=false;
    parameters = {};
    @api recordId;
    category='';
    error;
    @api rId;
    firstLetter='';
    secondLetter='';
    currentPageReference = null; 
    urlStateParameters = null;
    enrId = null;
    @api modelNumber='';
    @api serialNumber='';
    applianceType;
    //modelProductLines={};
    @track fetchProblemsFlag=false;
    phoneNumber='';
    selectedProblem;
    selectedProblemLabel;
    description;
    warrantySerial=false;
    @track applianceTypeValues=[];
    @track problemcategory = [];
    showpicklist = false;
    dependentDisabled=true;
    showdependent = false;
    picklistValuesObj;
    @track applianceTypeLabel;
    //@track isVisibleAsset=false;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.urlStateParameters = currentPageReference.state;
          this.setParametersBasedOnUrl();
       }
    }
    /*@wire(getApplianceModelMapping)
    wiredProductModelsData({error,data}) {
        if(data){
            for(let t=0;t<data.length;t++){
                let ky = data[t]["Appliance_Type_Name__c"];
                let val = data[t]["Partial_Models_List__c"].split(',');
                console.log('key is '+ky);
                this.modelProductLines[ky]= val;
            }
        }
        else if(error){
            console.log('error is '+error);
        }
    }*/
    setParametersBasedOnUrl() {
        this.enrId = this.urlStateParameters.EnrId || null;
        console.log('url is '+JSON.stringify(this.urlStateParameters));
        if(JSON.stringify(this.urlStateParameters)!='{}')
            this.recordId=this.urlStateParameters.ws.split('/')[4];
     }

     @wire(getObjectInfo, { objectApiName: VA_CHATDETAIL_OBJ })
    vaChatDetailData;

    @wire(getPicklistValuesByRecordType, { objectApiName: 'VAChat_Details__c', recordTypeId: '$vaChatDetailData.data.defaultRecordTypeId' })
    fetchPicklist({error,data}){
         
        if(data && data.picklistFieldValues){

            this.picklistValuesObj = data.picklistFieldValues;
            let applianceValues = data.picklistFieldValues.ApplianceType__c.values;
            let appTypeValues = [];
            for (let i = 0; i < applianceValues.length; i++) {
                appTypeValues.push({
                    label: applianceValues[i].label,
                    value: applianceValues[i].value
                });
            }
            this.applianceTypeValues = appTypeValues;
            this.fetchProblemsFlag = true;
            if(this.applianceType){

                this.handleapplianceType();
            }
            
        } else if(error){
            console.log(error);
        }
    }

    /*@wire(getPicklistValues,
        {
            recordTypeId: '$vaChatDetailData.data.defaultRecordTypeId',
            fieldApiName: Appliance_Type_Values
        }
    )
    wiredApplianceTypes({data,error}){
        if(data){
            console.log('data is '+JSON.stringify(data));
            this.applianceTypeValues = data.values;
        }
        if(error){
            console.log('error '+error);
        }
    }*/

    /*connectedCallback(){
        
        //this.parameters = this.getQueryParameters();
        console.log('parameters are :-->'+JSON.stringify(this.parameters));
        //this.recordId=this.parameters.ws.split('/')[4];
        console.log('record id is -->'+this.recordId);
        
    }*/
    getQueryParameters() {

        var params = {};
        var sch=location.search;
        var search = location.search.substring(1);
        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        }

        return params;
    }
    closePopup(){
        this.shopPopup=false;
        window.history.back();
    }
    previousScreen(){
        window.history.back();
    }

    @wire(getRecord, { recordId: '$recordId', fields: [MODEL_NUM,SERIAL_NUM,PRODUCT_LINE_DESC,PHONE_NUM] })
    wiredUser({error,data}) {
        if(error){
            this.error=error;
        }
        else if(data){
            this.modelNumber=data.fields.Model_Number__c.value;
            this.serialNumber=data.fields.SerialNumber.value;
            this.firstLetter=this.serialNumber.charAt(0);
            this.secondLetter=this.serialNumber.charAt(1);
            this.phoneNumber=data.fields.Primary_Phone__c.value;
            this.applianceType=data.fields.Product_Line_Desc__c.value;
            //this.updateApplianceType();

        }
    }

    @wire(getProductData, { productSKU: '$modelNumber' })
    wiredProductRecord({error,data}) {
        if(error){
            this.error=error;
        }
        else if(data){
            if(data.length>0){
                let isManufacturingModel = data[0].Is_Manufacturing_Model__c;
                let marketModelRec = data[0].Marketing_Model__c;
                if(isManufacturingModel == 'Yes' && marketModelRec!=null && marketModelRec!=''){
                    this.marketingModel = data[0].Marketing_Model__r.StockKeepingUnit;
                }
                else {
                    this.marketingModel = this.modelNumber; 
                }
                console.log('marketing model is '+this.marketingModel);
                
            }
            else {
                this.marketingModel = this.modelNumber;
            }

        }
    }

    /*updateApplianceType(){
        if(this.modelNumber!=null){
            let partialModel = this.modelNumber.length>5?this.modelNumber.substring(0,5):this.modelNumber;

            for(let key in this.modelProductLines){
                let modelMappingList = this.modelProductLines[key];
                console.log('key is '+key+' '+modelMappingList.includes(partialModel));
                if(modelMappingList.includes(partialModel) || modelMappingList.includes(this.modelNumber))
                {
                    this.applianceType = key;
                    if(this.fetchProblemsFlag)
                        this.handleapplianceType();
                    break;
                }
            }
            console.log('appliance type is '+partialModel+' '+this.applianceType);
        }
    }*/

    @wire(checkSerialWarranty,{serialNumber: '$serialNumber'})
    chekSerial({error,data}){
        console.log('check serial sssssssss'+this.serialNumber);
        if(data){
            console.log('inside warranty'+JSON.stringify(data));
            let monthsMap= {
                'January' : 1,
                'February' : 2,
                'March' :3,
                'April' :4,
                'May' :5,
                'June' :6,
                'July' :7,
                'August' :8,
                'September':9,
                'October': 10,
                'November':11,
                'December':12
            }
            let date=new Date()
            let mon=date.getMonth()+1;
            let year=date.getFullYear();
            let vmon;
            let vyear;
            //console.log(monthsMap[jsonData[0].Month_Name__c]);
            for(let i=0;i<data.length;i++){
                if(data[i].DeveloperName==this.serialNumber.charAt(0)){
                    vmon=monthsMap[data[i].Month_Name__c];
                }
                if(data[i].DeveloperName==this.serialNumber.charAt(1)) {
                    vyear=Number(data[i].Valid_Year__c);
                }
            }
            console.log('months;'+vmon+' year '+vyear);
            if(vmon && vyear){
                let mondif = (year - vyear) * 12;
                mondif -= vmon;
                mondif += mon;
                console.log('diff '+mondif);
                if(mondif>=0 && mondif<=18)
                    this.warrantySerial=true;
                else {
                    this.warrantySerial=false;
                }
            }
            else {
                this.warrantySerial=false;
            }   
        }
        else if(error){
            this.error=error;
            console.log('error-->'+JSON.stringify(error));
        }

    }
    callEndicaApiData(){
        getEndecaData({ SKU: this.marketingModel })
            .then((resp)=>{
                //console.log('Endica Response is--->> '+resp);
                let endicares=JSON.parse(resp);
                endicares["model"]= this.modelNumber;
                if(this.modelNumber != this.marketingModel)
                    endicares["mktmodel"]=this.marketingModel;
                else 
                    endicares["mktmodel"] = '';
                endicares["serial"]=this.serialNumber;
                endicares["appliancetype"]= this.applianceType;
                endicares["appliancetypelabel"]= this.applianceTypeLabel; //{ 'appliancevalue':this.applianceType, 'appliancelabel': this.applianceTypeLabel };
                let endicapl=JSON.stringify(endicares);
                let payload = {
                    source: "LWC",
                    messageBody: { record: endicapl }
                };

                publish(this.context, modeleventchannel, payload);
                
                //console.log('endica res -:: '+JSON.stringify(endicares));
                this.isapicall=false;
                this.shopPopup=false;

            })
            .catch(error => {
                console.log('Endica api response failed');
                this.isapicall = false;
                this.shopPopup = false;
            })

    }
    /*checkSerialNumberWarranty(){
        
        checkSerialWarranty({ fl: this.serialNumber.charAt(0), sl:this.serialNumber.charAt(1) })
        .then((jsonData) => {
            let monthsMap= {
                'January' : 1,
                'February' : 2,
                'March' :3,
                'April' :4,
                'May' :5,
                'June' :6,
                'July' :7,
                'August' :8,
                'September':9,
                'October': 10,
                'November':11,
                'December':12
            }
            console.log('response is '+JSON.stringify(jsonData));
            let date=new Date()
            let mon=date.getMonth()+1;
            let year=date.getFullYear();
            let vmon;
            let vyear;
            console.log(monthsMap[jsonData[0].Month_Name__c]);
            for(let i=0;i<jsonData.length;i++){
                if(jsonData[i].DeveloperName==this.serialNumber.charAt(0)){
                    vmon=monthsMap[jsonData[i].Month_Name__c];
                }
                else {
                    vyear=Number(jsonData[i].Valid_Year__c);
                }
            }
            console.log('months;'+vmon+' year '+vyear);
            let mondif = (year - vyear) * 12;
            mondif -= vmon;
            mondif += mon;
            if(mondif<=12)
                this.warrantySerial=true;
            else {
                this.warrantySerial=false;
            }   

        })
        .catch((error)=>{
            console.log('eror is '+JSON.stringify(error));
        })
    }*/
    updateSerial(event){
        console.log('inpt given serial');
        this.serialNumber = event.detail.value; //this.template.querySelector('lightning-input[data-name="serial"]').value.trim();
        
    }
    launchVa(){
        console.log('inside va');
        this.isapicall=true;
        this.description = this.template.querySelector("lightning-textarea").value;
        this.selectedProblem = this.template.querySelector('[data-id="selectedProblem"]').value;
        this.applianceType = this.template.querySelector('[data-id="applianceTypeData"]').value;
        this.modelNumber = this.template.querySelector('lightning-input[data-name="model"]').value.trim();
        this.serialNumber = this.template.querySelector('lightning-input[data-name="serial"]').value.trim();
        //this.applianceType = this.template.querySelector('lightning-input[data-name="applianceType"]').value.trim();
        this.phoneNumber = this.template.querySelector('lightning-input[data-name="phone"]').value.trim();
        console.log('model -'+this.modelNumber+' serial '+this.serialNumber+' app type '+this.applianceType+'desc  '+this.description);
        console.log('problem categery -'+this.selectedProblem+' phone '+this.phoneNumber);
        //this.checkSerialNumberWarranty();

        for(let vr=0;vr<this.applianceTypeValues.length;vr++) {
            if(this.applianceType == this.applianceTypeValues[vr].value){
                this.applianceTypeLabel = this.applianceTypeValues[vr].label;
                console.log('appliance type label is '+this.applianceTypeLabel);
            }
        }

        for(let vr2=0;vr2<this.problemcategory.length;vr2++) {
            if(this.selectedProblem == this.problemcategory[vr2].value){
                this.selectedProblemLabel = this.problemcategory[vr2].label;
                console.log(' problem category label is  '+this.selectedProblemLabel);
            }
        }
        if(!this.selectedProblem || !this.modelNumber || !this.serialNumber || !this.applianceType || !this.phoneNumber){
            this.isapicall=false;
            const toastEvent = new ShowToastEvent({
                title: 'Required Fields Missing',
                message: 'Please input required Fields',
                variant: 'error'
            });
            dispatchEvent(toastEvent);
        }
        else {
             if(!this.warrantySerial){
                //this.isapicall=false;
                const toastEvent = new ShowToastEvent({
                    title: 'Out of Warranty',
                    message: 'Serial number is not within warranty.',
                    variant: 'warning'
                });
                dispatchEvent(toastEvent);
        
            }
        
            this.publishChatPayload();
            console.log('model number is '+this.modelNumber);
            this.callEndicaApiData();
            //this.upsertAuditRecord();

        }
    }
    /*updateSearchFields(event){
        this.isVisibleAsset=true;
    }*/
    handleproblemcategory(event){
        this.category = event.detail.value;
        console.log('category'+this.category);
    }
    handleModelUpdate(event){
        this.modelNumber = event.detail.value;
        //if(this.modelNumber.length<5)
            //this.applianceType = '';
        console.log('model no is '+this.modelNumber+' '+this.applianceType);
        //this.updateApplianceType();
    }
    handleapplianceType(event){
        if(event)
            this.applianceType=event.detail.value;
        

        if (this.applianceType) {
            this.dependentDisabled = false;
            let data1 = this.picklistValuesObj; 
            let probCategory = data1.ProblemCategory__c;
            let controllerValueIndex = probCategory.controllerValues[this.applianceType];
            let problemPicklistValues = data1.ProblemCategory__c.values;
            let problemPicklists = [];
            //Iterate the picklist values for the problem category field
            problemPicklistValues.forEach(key => {
                for (let i = 0; i < key.validFor.length; i++) {
                    if (controllerValueIndex == key.validFor[i]) {
                        console.log('lael is ');
                        problemPicklists.push({
                            label: key.label,
                            value: key.value
                        });
                        console.log('label is ');
                    }
                }
            })
            if (problemPicklists && problemPicklists.length > 0) {
                this.problemcategory = problemPicklists;
            }
        }

    }
    get problemcategory1(){
        return [
            { label: 'Door won\'t open/close', value: 'Door_won\'t_open/close' },
            { label: 'Burner Bowl Issues(chipped / cracked / broken)', value: 'Burner_Bowl_Issues(chipped/cracked/broken)' },
            { label: 'Burner Operation Issues', value: 'Burner_Operation_Issues' },
            { label: 'Cleaning Issues', value: 'Cleaning_Issues' },
            { label: 'Cooktop Damp / Moist', value: 'Cooktop_Damp/Moist' },
            { label: 'Cooktop Noisy / Oven Noisy', value: 'Cooktop_Noisy/Oven_Noisy' },
            { label: 'Cooktop Still Hot to Touch', value: 'Cooktop_Still_Hot_to_Touch' },
            { label: 'Damaged / Missing Parts', value: 'Damaged/Missing_Parts' },
            { label: 'Door / Window / Storage Drawer Issues', value: 'Door/Window/Storage_Drawer_Issues'},
            
        ];
    }

    get applianceTypeValues1(){
        return [
            { label: 'Compactors', value: 'compactors' },
            { label: 'Dishwasher', value: 'dishwasher' },
            { label: 'Disposer', value: 'disposer' },
            { label: 'Dryer', value: 'dryer' },
            { label: 'Electric Range', value: 'electricrange' },
            { label: 'Freezer', value: 'freezer' },
            { label: 'Gas Range', value: 'gasrange' },
            { label: 'Microwave Ovens', value: 'mwo' },
            { label: 'Room Air Conditioners', value: 'rac'},
            
        ];
    }

    publishChatPayload(){
        let chatPl={ 'phoneNumber': this.phoneNumber, 'problemCategory': this.selectedProblem, 
                      'modelNumber': this.modelNumber, 'serialNumber': this.serialNumber,
                      'description': this.description, 'applianceType': this.applianceType, 'warrantySerial' : this.warrantySerial,
                      'problemCategoryLabel': this.selectedProblemLabel, 'applianceTypeLabel': this.applianceTypeLabel
                    };
        //let chatStringPayload=JSON.stringify(chatPl);
        let chatPayload = {
            source: "LWC",
            messageBody: { record: chatPl }
        };
        publish(this.context, apidatachannel, chatPayload);
        this.dispatchEvent(
            new CustomEvent("submit", {
                detail: { record: chatPl }
            })
        );
    }
    upsertAuditRecord(){
        this.vaAuditRecord.ApplianceType__c=this.applianceType;
        this.vaAuditRecord.ModelNo__c=this.modelNumber;
        this.vaAuditRecord.ProblemCategory__c=this.selectedProblem;
        this.vaAuditRecord.SerialNo__c=this.serialNumber;
        this.vaAuditRecord.AdditionalDesc__c=this.description!=null?this.description:'';
        this.vaAuditRecord.Requested_by__c=this.userid;
        this.vaAuditRecord.Phone__c=this.phoneNumber;

        this.upsertVaChatDetail();
        console.log('method to create audit record for VA');
    }

    upsertVaChatDetail(){

        createVAChatDetail( { auditRecord : this.vaAuditRecord })
        .then(result => {
            this.vaAuditRecord=result;
        })
        .catch(error => {
            console.log('error occured'+JSON.stringify(error));
        });
    }

    /*getorderlistdata(pl) {
        this.ReceivedAPIDataflag = true;
        getContacts({ phone: pl })
        .then((jsonResponse) => {
            let payload = {
                source: "LWC",
                messageBody: { record: jsonResponse }
            };
            //console.log('response is '+jsonResponse);
            this.ReceivedAPIDataflag = false;
            publish(this.context, apidatachannel, payload);
        })
            .catch((error) => {
                this.ReceivedAPIDataflag = false;
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Status Code: '+error.status+' Server Issue',
                    variant: 'error',
                });
                dispatchEvent(evt);
           });
    }*/
    
}