import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import fetchCase from '@salesforce/apex/ConnectedAppliance_ext.fetchCase';
import connectionStatus from '@salesforce/apex/ConnectedAdmin.connectionStatus';

export default class AssetConnectStatus extends LightningElement {
    @track data1 = [];
    temp_cols=[];
    //cols=[];
    @track columns = [];
    error;
    @track hasData=false;
    Id='';
/*    @wire(getRecord,{ recordId: '$recordId', fields: ['Case.Id', 'Case.Case_Asset_NOT_ON_LAYOUT__r.Name', 'Case.Case_Asset_NOT_ON_LAYOUT__r.MAC_Address__c'] }) case_asset_status;

    get inputboxval() {
        if (this.sflag) {
            this.sflag = 0;
            if(this.case_asset_status.data){
                this.Id=this.case_asset_status.data.fields.Id.value;
                console.log('case asset');
            }
            
            this.searchRecord();
        }
        return this.Id;
    }
    searchRecord(){
        //@api recordId;
        fetchCase({ RecId: this.Id })
            .then((response) => {
                console.log('resposne is'+response);
                return JSON.parse(response);
            })
            .then((jsonResponse) => {
                this.columns = Object.keys(jsonResponse[0]);
                this.data1 = jsonResponse;
            }) 
            .catch(error => {
                console.log('error data'+error);
                this.error=error;
            })
        }*/
    @api recordId;
    
        @wire(fetchCase,{RecId:'$recordId'})
        async wiredClass({data, error}){
        if(data){
            this.columns = [];
            let data2 = JSON.parse(data);
            if(data2.length>0){
                this.hasData=true;
            }
            //this.records = dataEditing.length;
            let cols=Object.keys(data2[0]);
            for(let i=0;i<cols.length;i++){
                this.temp_cols.push({ label: cols[i], fieldName: cols[i], sortable: true, value: cols[i] });
            }
            this.temp_cols.push({label:'Presence',fieldName:'Presence',sortable: true,value: 'Presence'});
            this.columns=this.temp_cols;

            for(let i=0;i<data2.length;i++){
                if(data2[i].MacAddress!=null){
                    //let resp=await this.getconnectionstatus(data2[i].MacAddress);
                    await connectionStatus({macAddress: data2[i].MacAddress})
                    .then((data)=>{
                        console.log('data is '+data);
                        data2[i]['Presence']=data;
                    })
                    
                
                }
                else {
                    data2[i]['Presence']='Not Connectable';
                }
            }
            this.data1 = data2;
            
        }
        else if(error){
            console.log('error occured '+error);
            this.error = error;
        }
        
    }
    /*async getconnectionstatus(macaddress) {
        console.log('value of mac is '+macaddress);
        await connectionStatus({macAddress: macaddress})
                    .then((data)=>{
                        console.log('data is '+data);
                        return data;
                    })
        
    }*/
    
/*    connectedCallback(){
    fetchCase({RecId:'$recordId'})
    .then((data)=>{
        console.log('resposne received');
        let data2 = JSON.parse(data);
        //console.log(JSON.stringify(dataEditing));
        //this.records = dataEditing.length;
        this.columns=Object.keys(data2[0]);
        this.data1 = data2;
        
    })
    .catch((error)=>{
        console.log('error occured '+error);
        this.error = error;
    })
    
}*/
}