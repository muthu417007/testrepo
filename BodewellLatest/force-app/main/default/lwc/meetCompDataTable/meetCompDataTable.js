import { LightningElement, api, track } from 'lwc';
import fetchMeetComps from '@salesforce/apex/MeetCompsController.fetchMeetComps';
import getMeetComps from '@salesforce/apex/MeetCompsController.getMeetComps';
import sharedjs from 'c/sharedjs';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import { NavigationMixin } from 'lightning/navigation';
import { FlowNavigationFinishEvent } from 'lightning/flowSupport';

const columns = [
    //{label: 'Account', fieldName: 'Account__c', wrapText: 'true',
        //cellAttributes: {
           // iconName: { fieldName: 'accIconName'},
           // iconPosition: 'left'
        //}
    //},
    //{label: 'Account', fieldName: 'Account__c'},
    {label: 'ACCOUNT', fieldName: 'AccountURL', type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'AccountName'
            }
        }, wrapText: true, initialWidth: 150, target: '_blank'
    },
    {label: 'MEET COMP NAME', fieldName: 'Name', initialWidth: 170},
    {label: 'CREATED BY REDOC', fieldName: 'Created_by_Redoc__c', type: 'boolean', initialWidth: 150},
    {label: 'SKU', fieldName: 'SKU__c'},
    {label: 'EFFECTIVE DATE', fieldName: 'Effective_Date__c', initialWidth: 150},
    {label: 'TERMINATION DATE', fieldName: 'Termination_Date__c', initialWidth: 200},
    {label: 'GEA MEET COMP PRICE', fieldName: 'GEA_Meet_Comp_Price__c', initialWidth: 200},
    {label: 'GEA PRIOR INVOICE PRICE', fieldName: 'GEA_Prior_Invoice_Price__c', initialWidth: 250},
    {label: 'QUANTITY', fieldName: 'Quantity__c', initialWidth: 150},
    {label: 'QUANTITY WITHOUT MEET COMP', fieldName: 'Quantity_without_Meet_Comp__c', initialWidth: 300},
    {label: 'MC TYPE', fieldName: 'MC_Type__c'},
    {label: 'GEA MODEL', fieldName: 'ModelURL', type: 'url',
    typeAttributes: {
        label: {
            fieldName: 'GEAModel'
        }
    }, wrapText: true, target:'_blank', initialWidth: 150
},
    {label: 'STAGE NAME', fieldName: 'Stage_Name__c', initialWidth: 150},
    {label: 'TRANSFERRED TO ORACLE', fieldName: 'Transferred_to_Oracle__c', type: 'boolean', initialWidth: 200}
];

export default class MeetCompDataTable extends LightningElement {//NavigationMixin(LightningElement) {
    @api ids;
    @api objectApiName;
    @track records;
    @track errors;
    columns = columns;
    allRecordsUpdated = '';
    partialUpdate = '';
    successmessage='All records updated successfully';
    infomessage='The below records did not update due to some error. Please check';

//@api termDate;
// variables for showTostEvent
   /* @api title;
    @api message;
    @api variant;
    @api iconName;
    @api delay;
    @api recordName;
    @api url;
    @api actionLabel;*/

    connectedCallback(){
        console.log('inside connected callback');
        console.log('ids before splitting-->'+this.ids);
        if(this.ids){
            console.log('inside if this.ids');
            this.ids = this.ids.split(',').filter(function(e){
                return e != null && e !='';
            });
        }
        console.log('ids'+this.ids);
        getMeetComps({MeetCompIds: this.ids}).
        then(response =>{
            console.log('Response:'+JSON.stringify(response));
            if(response){
                console.log('there are unqualified meet comps');
                this.errors = 'You cannot update the termination date for records that have already terminated or records that are in Awaiting Approval.';
                console.log('errors--->',this.errors);
                //this.showNotification();
            }
            else{
                this.handleDoInit();
            }
        })
        .catch(error =>{
            console.log('Error :(');
        });
       // if(getMeetComps({MeetCompIds: this.ids})){
            //console.log('there are unqualified meet comps');
            //this.errors = 'You cannot update the termination date for records that have already terminated or records that are in Awaiting Approval.';
            //this.showNotification();
            
        //}
        //else{
            //this.handleDoInit();
       // }
        
    }

    /*dateChange(event){
        console.log('inside dateChange');
        this.termDate = event.target.value;
    }*/

    showNotification() {
        /*let toastMessage = {
            title: 'Unqualified Meet Comps',
            message: 'You cannot update the termination date for records that have already terminated or records that are in Awaiting Approval.',
            variant: 'error'

        };*/
        const evt = new ShowToastEvent({
            title: 'Unqualified Meet Comps',
            message: 'You cannot update the termination date for records that have already terminated or records that are in Awaiting Approval.',
            variant: 'error'
        });
        console.log(evt);
        this.dispatchEvent(evt);
    }

    handleDoInit(){
        console.log(fetchMeetComps);
        sharedjs._servercall(
            fetchMeetComps,
            this.ids,
            this.handleSuccess.bind(this),
            this.handleError.bind(this)
        );
    }

    handleSuccess(result){
        const newProperty = 'accIconName';
        console.log('inside handleSuccess');
        console.log(result);
       /* result.forEach(element => {
            console.log(element);
            if(element.Account__c){
                console.log('inside element if-->');
                element.AccountName = element.Account__r.Name;
                //element.accIconName = 'standard:account';
                //element[newProperty] = 'standard:account';
                //console.log(element);
            }
        });*/
        this.records = result.map(row=>{
            //return{...row, AccountName: row.Account__r.Name}
            return{...row, AccountURL: '/lightning/r/Account/' +row['Account__c'] +'/view', AccountName: row.Account__r.Name, ModelURL: '/lightning/r/Meet_Comp__c/' +row['GEA_Model__c'] +'/view', GEAModel: row.GEA_Model__r.Name}
        })
        //this.records = result;
        console.log('records-->'+this.records);
        this.errors = undefined;
    }

    handleError(error){
        this.errors = error;
        this.records = undefined;
    }

    handlePartialUpdate(event){
        this.partialUpdate = event.detail;
    }

    RecordsUpdated(event){
        console.log('inside parent recordsUpdated function');
        console.log(event.detail);
        this.allRecordsUpdated = event.detail;

    }

    navigateToListView() {
        console.log('inside list view navigation');
        // Navigate to the Meet Comp object's Recent list view.
        /*this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Contact',
                actionName: 'list'
            },
            state: {
                // 'filterName' is a property on the page 'state'
                // and identifies the target list view.
                // It may also be an 18 character list view id.
                filterName: 'Recent' // or by 18 char '00BT0000002TONQMA4'
            }
        });*/
        const navigationEvent = new FlowNavigationFinishEvent();
        try {
            this.dispatchEvent(navigationEvent);
        } catch (ex) {
            console.log('Exception: ' + ex);
        }
    }

    handleRowActions(event){
        window.console.log('Row level action Handled', event.detail.actionName);
        window.console.log('Row level action Handled', JSON.stringify(event.detail.data));
    }

    handlePagination(event){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'All Records loaded',
                variant: 'success'
            })
        );

    }
   // handleAllRecordsSuccess(event){
       //this.allRecordsUpdated = event.detail.data;
        //console.log('allrecordsupdated-->'+allRecordsUpdated);
    //}

}