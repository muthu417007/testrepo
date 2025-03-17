import { LightningElement, api, track } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchMeetComps from '@salesforce/apex/MeetCompsController.fetchMeetComps';

const DELAY = 300;

export default class DoPagination extends LightningElement {

    isLoading = false;
    @api records;
    @api showTable = false;
    @api columns;
    @api recordsperpage;

    termDate;

    totalRecords;
    pageNo;
    totalPages;
    startRecord;
    endRecord;
    end = false;
    pagelinks = [];
    tempArray = [];


    @track recordsToDisplay;
    @track draftValues = [];
    @track tableErrors = { rows: {}, table: {} };

    connectedCallback(){
        
        this.isLoading = true;
       // this.records.map(this.setDraftValues);
      
        this.setRecordsToDisplay();
    }

    //@api get terminationDate(){
        //return this.termDate;
    //}

    get todaysDate() {
        var today = new Date();
        var dd = String(today.getDate() +1 ).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        today = mm + '/' + dd + '/' + yyyy;
        return today
    }

    dateChange(event){
        let inputDate = this.template.querySelector(".dateCmp");
        let dateValue = inputDate.value;
        let d1 = new Date(dateValue);
        let today = new Date();
        console.log('today',today);
        if(d1 <= today)
        {
           inputDate.setCustomValidity("Date value should be greater than today");
        }
        else {
            inputDate.setCustomValidity("");
        
        console.log('dateValue',dateValue);
        this.tempArray = [];
        this.records.map(item =>{
            const newObj = {"Termination_Date__c":event.target.value,//item.Termination_Date__c,
            "Id":item.Id};
            this.tempArray.push(newObj);
            console.log('draftValues-->'+JSON.stringify(this.tempArray));
           });
           //this.draftValues.push(...this.tempArray);
           this.draftValues = this.tempArray;
           console.log(JSON.stringify(this.draftValues));
           this.tableErrors = { rows: {}, table: {} };
           console.log('after date change');
           console.log(JSON.stringify(this.tableErrors));
        }
           const hideInfoEvent = new CustomEvent("partialupdated", {
            detail: ''
          });
      
          
          this.dispatchEvent(hideInfoEvent);
    }

    /*set terminationDate(value){
        console.log('inside setter-->'+value);
        //if(value !== 'undefined'){
            this.setAttribute('terminationDate', value);
            this.termDate = value;
            //this.handleDateChange(value);
            if(value !== undefined){
               // console.log('inside handleDateChange'+value);
                this.records.map(item =>{
                    const newObj = {"Termination_Date__c":value,//item.Termination_Date__c,
                    "Id":item.Id};
                    this.tempArray.push(newObj);
                    console.log('draftValues-->'+JSON.stringify(this.tempArray));
                   });
                   this.draftValues.push(...this.tempArray);
                   this.setAttribute('draftValues', this.draftValues);
                  // eval("$A.get('e.force:refreshView').fire();");
                }
        //}
    }*/

   /* handleDateChange(value){
        if(value !== undefined){
        console.log('inside handleDateChange'+value);
        this.records.map(item =>{
            const newObj = {"Termination_Date__c":value,//item.Termination_Date__c,
            "Id":item.Id};
            this.draftValues.push(newObj);
            console.log('draftValues-->'+JSON.stringify(this.draftValues));
           });
           this.setAttribute('draftValues', this.draftValues);
        }
    }*/
    /*setDraftValues(item){
        const newObj = {"Termination_Date__c":"2022-06-07",//item.Termination_Date__c,
    				"Id":item.Id};
        this.draftValues.push(newObj);
    }*/

    setRecordsToDisplay(){
        console.log('doPagination records-->'+JSON.stringify(this.records));
        this.totalRecords = this.records.length;
        this.pageNo = 1;
        this.totalPages = Math.ceil(this.totalRecords/this.recordsperpage);
        this.preparePaginationList();

        for (let i = 1; i <= this.totalPages; i++) {
            this.pagelinks.push(i);
        }
        this.isLoading = false;
    }

    handleClick(event){
        let label = event.target.label;
        if(label === "First"){
            this.handleFirst();
        } else if (label === "Previous"){
            this.handlePrevious();
        } else if (label === "Next") {
            this.handleNext();
        } else if (label === "Last") {
            this.handleLast();
        }
    }

    handleNext() {
        this.pageNo += 1;
        this.preparePaginationList();
    }

    handlePrevious() {
        this.pageNo -= 1;
        this.preparePaginationList();
    }

    handleFirst() {
        this.pageNo = 1;
        this.preparePaginationList();
    }

    handleLast() {
        this.pageNo = this.totalPages;
        this.preparePaginationList();
    }

    preparePaginationList(){
        this.isLoading = true;
        let begin = (this.pageNo - 1) * parseInt(this.recordsperpage);
        let end = parseInt(begin) + parseInt(this.recordsperpage);
        this.recordsToDisplay = this.records.slice(begin,end);

        this.startRecord = begin + parseInt(1);
        this.endRecord = end > this.totalRecords ? this.totalRecords : end;
        this.end = end > this.totalRecords ? true : false;

        const event = new CustomEvent('pagination', {
            detail: { 
                records : this.recordsToDisplay
            }
        });
        this.dispatchEvent(event);

        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            this.disableEnableActions();
        }, DELAY);
        this.isLoading = false;

    }

    disableEnableActions(){
        let buttons = this.template.querySelectorAll("lightning-button");

        buttons.forEach(bun =>{
            if(bun.label === this.pageNo){
                bun.disabled = true;
            } else {
                bun.disabled = false;
            }

            if (bun.label === "First") {
                bun.disabled = this.pageNo === 1 ? true : false;
            } else if (bun.label === "Previous") {
                bun.disabled = this.pageNo === 1 ? true : false;
            } else if (bun.label === "Next") {
                bun.disabled = this.pageNo === this.totalPages ? true : false;
            } else if (bun.label === "Last") {
                bun.disabled = this.pageNo === this.totalPages ? true : false;
            }
        });
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log('row data'+ row);
        const rowAction = new CustomEvent('actions', {
            detail: { 
                actionName : actionName,
                data : row
            }
        });
        this.dispatchEvent(rowAction);
    }

    handlePage(button){
        this.pageNo = button.target.label;
        this.preparePaginationList();
    }

    /*handleerror(recordInput){
        console.log('inputs'+JSON.stringify(recordInput));
        console.log('Id'+recordInput.fields.Id);
        updateRecord(recordInput)
        .then(() => console.log('success')
        )
        .catch(error1 => {
            console.log('error1--'+error1.Id);
            this.tableErrors.rows['1'] = { title: 'We found an error', messages: [error1.body.output.errors[0].message], fieldNames: [ 'Termination_Date__c'] };
            this.tableErrors.table = {title: 'We found error(s)',messages:['Please amend the errors!']};
            console.log(JSON.stringify(this.tableErrors));
            
           // eval("$A.get('e.force:refreshView').fire();");
        });
        

    }*/

    handleSave(event) {
        this.tableErrors = { rows: {}, table: {} };
        console.log(event.target.dataset.id);
        this.isLoading = true;
        console.log('inside handleSave');
        console.log(JSON.stringify(event.detail.draftValues));
        const recordInputs =  event.detail.draftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            console.log('fields-->'+JSON.stringify(fields));
            console.log('draft--'+draft);
            return { fields };
        });
        console.log('recordInputs-->'+JSON.stringify(recordInputs));
        //recordInputs.forEach(element => {
            //console.log(element);
            //this.handleerror(element);
        //}); 
        //this.setRecordsToDisplay();

            //recordInputs.map(handleerror);
            const promises=recordInputs.map(recordInput => updateRecord(recordInput).then(response => {
                console.log(response);
            }).catch(e => {
                //let errors = {};
                //errors.rows = {};
                console.log('inside catch block');
                console.log(e);
                console.log('recordInput'+recordInput.fields);
                console.log('recordInput.Id'+recordInput.fields.Id);
                console.log('field errors length',e.body.output.fieldErrors);
                if(e.body.output.errors.length > 0){
                    console.log('inside if of errors',e.body.output.errors.length);
                    for (let i = 0; i < e.body.output.errors.length; i++){
                        console.log('inside for loop of erros');
                        //objIndex = tableErrors.rows.findIndex((obj => obj.id == recordInput.fields.Id));
                        //console.log('objIndex-->',objIndex);
                        if(recordInput.fields.Id in this.tableErrors.rows){
                            console.log('inside nested if');
                            this.tableErrors.rows[recordInput.fields.Id].messages.push(e.body.output.errors[i].message);
                        }
                        else{
                            console.log('inside else block');
                            this.tableErrors.rows[recordInput.fields.Id] = { title: 'We found an error', messages: [e.body.output.errors[0].message], fieldNames: [ 'Termination_Date__c'] };
                        }
                        
                    }
                    console.log('outside for loop');
                }
                else if(!e.body.output.errors.length && e.body.output.fieldErrors){
                    console.log('inside field Errors');
                    console.log(Object.keys(e.body.output.fieldErrors)[0]);
                  //  error.body.output.fieldErrors[Object.keys(error.body.output.fieldErrors)[0]][0].message;
                  this.tableErrors.rows[recordInput.fields.Id] = { title: 'We found an error', messages: [e.body.output.fieldErrors[Object.keys(e.body.output.fieldErrors)[0]][0].message], fieldNames: [ 'Termination_Date__c'] };
                }
                this.tableErrors.table = {title: 'We found error(s)',messages:['Please amend the errors!']};

                //this.tableErrors = errors;
               // console.log(e);
                console.log('table errors below--');
                console.log(JSON.stringify(this.tableErrors));
                //this.isLoading = false;
            }));
        //const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        window.console.log(' Updating Records.... ');
       /* if (this.tableErrors === undefined || this.tableErrors.length == 0) {
            console.log('successfull inside if');
            this.isLoading = false;
            this.draftValues = [];
            eval("$A.get('e.force:refreshView').fire();");
            
        }*/
        Promise.all(promises).then(record => {
            this.isLoading = false;
            console.log('all records updated');
            console.log(JSON.stringify(this.tableErrors));
            console.log(Object.keys(this.tableErrors.rows));
            console.log(Object.keys(this.tableErrors.rows).length);
            this.draftValues = [];
            if(Object.keys(this.tableErrors.rows).length === 0){
                console.log('inside no errors if');
                const showSuccessEvent = new CustomEvent("recordsupdated", {
                    detail: 'allupdated'
                  });
              
                  
                  this.dispatchEvent(showSuccessEvent);
            }
            else if(Object.keys(this.tableErrors.rows).length){
                console.log('inside if');
                const remainingIds = Object.keys(this.tableErrors.rows);
                console.log('remainingIds',remainingIds);
                fetchMeetComps({MeetCompIds: remainingIds}).
                    then(response =>{
                    console.log('Response:'+JSON.stringify(response));
                    //this.records = response;
                    this.records = response.map(row=>{
                        console.log(row);
                        //return{...row, AccountName: row.Account__r.Name}
                        return{...row, AccountURL: '/lightning/r/Account/' +row['Account__c'] +'/view', AccountName: row.Account__r.Name, ModelURL: '/lightning/r/Meet_Comp__c/' +row['GEA_Model__c'] +'/view', GEAModel: row.GEA_Model__r.Name}
                    })
                    this.setRecordsToDisplay();
                    const showInfoEvent = new CustomEvent("partialupdated", {
                        detail: 'partialupdate'
                      });
                  
                      
                      this.dispatchEvent(showInfoEvent);
                    //if(response){
                        //console.log('there are unqualified meet comps');
                        //this.errors = 'You cannot update the termination date for records that have already terminated or records that are in Awaiting Approval.';
                        //console.log('errors--->',this.errors);
                        //this.showNotification();
                    //}
                    //else{
                        //this.handleDoInit();
                    //}
                })
                .catch(error =>{
                    console.log('Error :(');
                });
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'All Records updated',
                    variant: 'success'
                })
            );
            
            eval("$A.get('e.force:refreshView').fire();");
            //refreshApex(this.recordsToDisplay);
            //const selectedEvent = new CustomEvent("allrecordsupdated", {
                //detail: 'success'
            //});
          
              // Dispatches the event.
              //this.dispatchEvent(selectedEvent);
          
            }).catch(error => {
            console.log(JSON.stringify(error));
            //console.log(error.body.output.errors[0].message);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error editing record',
                    message: 'There are errors with the Termination Date entered',//error.body.output.errors[0].message,
                    variant: 'error',
                    mode: 'pester'
                })
            );
        })
        .finally(()=>{
            this.isLoading = false;
            //return refreshApex(this.recordsToDisplay);
        })
    }
}