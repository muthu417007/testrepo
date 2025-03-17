import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import cycle from '@salesforce/apex/ConnectedAdmin.cycle';
import faultTable from '@salesforce/apex/ConnectedAdmin.faultTable';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class AssetConnectedData extends LightningElement {
    @track faultflag = false;
    sflag = 1;//@track cycleflag=0;
    cols = [];
    fault_cols = [];
    ready = true;
    columns = [];
    fault_columns = [];
    @track cyclehis = [];
    @track faultdata = [];
    @track ready = false;
    selectedvalues = [];
    @track colOptions = [];
    @track fault_colOptions = [];
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    sortedByCycle;
    @track FaultsLoading = false;
    @track CycleLoading = false;
    @track error = null;
    macaddress;
    //new columns
    @track page = 1;
    @track startingRecord = 1;
    @track endingRecord = 0;
    @track pageSize = 50;
    @track totalRecountCount = 0;
    @track totalPage = 0;
    @track items = [];
    @api recordId;
    @wire(getRecord, { recordId: '$recordId', fields: ['Asset.MACAddress__c'] }) asset;
    @wire(getRecord, { recordId: '$recordId', fields: ['Case_Asset__c.Asset__r.MACAddress__c'] }) case_asset;
    
    //connectedCallback(){this.searchItem(); };
    get inputboxval() {
        if (this.sflag) {
            this.sflag = 0;
            if(this.asset.data){
                this.macaddress=this.asset.data.fields.MACAddress__c.value;
                console.log('gea asset');
            }
            if(this.case_asset.data) {
                //this.objrec=this.case_asset.data.fields;
                this.macaddress=this.case_asset.data.fields.Asset__r.value.fields.MACAddress__c.value;
                console.log('case asset');
            }
            this.searchItem();
        }
        return this.macaddress;
    }

    searchItem() {
        //inputboxval=this.gea_asset.data.fields.MACAddress__c.value;
        
        this.fault_colOptions = [];
        this.colOptions = [];
        this.page = 1;
        this.startingRecord = 1;
        this.endingRecord = 0;
        this.totalRecountCount = 0;
        this.totalPage = 0;
        this.faultflag = false;
        this.FaultsLoading = true;
        this.CycleLoading = true;
        //console.log("id is ", this.gea_asset.data.fields.MACAddress__c.value);
        //const inputbox= this.gea_asset.data.fields.MACAddress__c.value;
        //const inputbox=this.template.querySelector("lightning-input");

        //this.isProgressing = false;D828C9122E14
        //this.toggleProgress();
        faultTable({ macAddress: this.macaddress })
            .then((response) => {
                //console.log("falutres",response);
                return JSON.parse(response);
            })
            .then((jsonResponse) => {
                this.FaultsLoading = false;
                console.log("faults are received");
                let faults = jsonResponse.items;  //old data
                this.items = jsonResponse.items;  //new data
                //console.log(this.items);
                this.totalRecountCount = this.items.length;    //new data
                //console.log(this.totalRecountCount);
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);  //new data
                //this.data = this.items.slice(0,this.pageSize); //new data
                //this.endingRecord = this.pageSize; //new data
                //console.log(this.totalRecountCount, this.totalPage);

                //this.ready = false;
                //this.faultflag=1;
                //console.log(cycles);
                if (faults.length > 0) {
                    this.faultflag = true;
                    var faultset=new Set();
                    for(var tem=0;tem<faults.length;tem++){
                        for(var k in faults[tem]){
                        faultset.add(k);
                        }  
                    }
                    //faults = faults.sort(function (a, b) { return -(Object.keys(a).length - Object.keys(b).length); });
                    //this.fault_cols = Object.keys(faults[0]);
                    this.fault_cols=Array.from(faultset.values());
                    //console.log('cols are', this.fault_cols);
                    this.faultdata = this.items.slice(0, this.pageSize); //new data
                    this.endingRecord = this.pageSize; //new data
                    //console.log(this.faultdata);
                    //this.faultdata=faults;  //old data
                    //console.log('cols are',this.cols);
                    for (let i = 0; i < this.fault_cols.length; i++) {

                        this.fault_colOptions.push({ label: this.fault_cols[i], fieldName: this.fault_cols[i], sortable: true, value: this.fault_cols[i] });
                    }
                    this.fault_columns = this.fault_colOptions;
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: 'Connected Data received for '+this.macaddress,
                        variant: 'success',
                    });
                    dispatchEvent(evt);    
                }
                else {
                    //this.fault_colOptions=[];
                    this.fault_columns = [];
                    this.faultdata = [];
                    const evt = new ShowToastEvent({
                        title: 'Not Connected',
                        message: 'No record found with the specified macaddress',
                        variant: 'error',
                    });
                    dispatchEvent(evt);    
                    //alert("the macaddress does not have any faults");
                }
            })
            .catch(error => {
                this.FaultsLoading = false;
                //this.faultflag=1;
                //this.fault_colOptions=[];
                this.fault_columns = [];
                this.faultdata = [];
                this.error = error;
                const evt = new ShowToastEvent({
                    title: 'Not Connected',
                    message: 'No record found with the specified macaddress',
                    variant: 'error',
                });
                dispatchEvent(evt);
                console.log('callout error ===> ' + JSON.stringify(error));
                //alert('Invalid macAddress.Please enter valid macAddress');
            })




        cycle({ macAddress: this.macaddress })
            .then((response) => {
                console.log("cycle json res received");
                return JSON.parse(response);
            })
            .then((jsonResponse) => {
                //this.isProgressing = true;
                //this.toggleProgress();
                this.CycleLoading = false;
                //console.log(jsonResponse.items);
                let cycles = jsonResponse.items;
                //this.cycleflag=1;
                //console.log(cycles);
                if (cycles.length > 0) {
                    var cycleset=new Set();
                    for(var tem=0;tem<cycles.length;tem++){
                        for(var k in cycles[tem]){
                        cycleset.add(k);
                        }   
                    }
                    //this.cols = Object.keys(cycles[0]);
                    this.cols=Array.from(cycleset.values());
                    this.cyclehis = cycles;
                    //console.log('cycle cols are');
                    for (let i = 0; i < this.cols.length; i++) {
                        //this.columns.push({label:this.cols[i],fieldName:this.cols[i],value:this.cols[i]});
                        this.colOptions.push({ label: this.cols[i], fieldName: this.cols[i], sortable: true, value: this.cols[i] });
                    }
                    this.columns = this.colOptions;
                }
                else {
                    this.columns = [];
                    this.cyclehis = [];
                    this.colOptions = [];
                    //alert("the macaddress does not have CycleHistory");
                }
            })
            .catch(error => {
                //this.cycleflag=1;
                //this.isProgressing = true;
                //this.toggleProgress();
                this.CycleLoading = false;
                this.columns = [];
                this.cyclehis = [];
                this.colOptions = [];
                console.log('callout error ===> ' + JSON.stringify(error));
                //alert('Invalid macAddress.Please enter valid macAddress');
            })

    }

    onHandleSort(event) {
        console.log('inside fault sort function');
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.faultdata];
        
        const numberPrimer = (value) => (('' + value).match(/^\d+(\.\d+)*$/) ? parseFloat(value) : value);
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1, numberPrimer));
        //cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.faultdata = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
        
    }
    onHandleSortCycle(event) {
        console.log('inside sort fun cycle');
        const { fieldName: sortedByCycle, sortDirection } = event.detail;
        const cloneDataCycle = [...this.cyclehis];
        const numberPrimer = (value) => (('' + value).match(/^\d+(\.\d+)*$/) ? parseFloat(value) : value);
        cloneDataCycle.sort(this.sortBy(sortedByCycle, sortDirection === 'asc' ? 1 : -1, numberPrimer));
        //cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.cyclehis = cloneDataCycle;
        this.sortDirection = sortDirection;
        this.sortedByCycle = sortedByCycle;
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                return primer(x[field]);
            }
            : function (x) {
                return x[field];
            };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    selectedcolumns() {
        this.ready = true;
        this.selectedvalues = [];
    }
    get selected() {
        //this.columns=this._selected;
        return this.selectedvalues.length ? this._selected : 'none';
    }

    handleChange(e) {
        this.selectedvalues = e.detail.value;
    }
    DisplayFaultData(){
        var arr = [];
        this.ready = false;
        for (let i = 0; i < this.selectedvalues.length; i++) {
          var xt = { label: this.selectedvalues[i], fieldName: this.selectedvalues[i], sortable: true };
          arr.push(xt);
        }
        this.fault_columns = arr;
    }
    DisplayData() {
        var arr = [];
        this.ready = false;
        //console.log('selected all vaues are these list',this.selectedvalues);
        for (let i = 0; i < this.selectedvalues.length; i++) {
            //console.log('ans is',this.selectedvalues[i]);
            var xt = { label: this.selectedvalues[i], fieldName: this.selectedvalues[i], sortable: true };
            arr.push(xt);
        }
        this.columns = arr;
        //console.log('cols are',arr);
        //console.log('col options are',this.columns);
    }
    showallcolumns() {
        this.ready = false;
        this.columns = this.colOptions;
        this.fault_columns=this.fault_colOptions;
    }

    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    //clicking on next button this method will be called
    nextHandler() {
        
        if ((this.page < this.totalPage) && this.page !== this.totalPage) {
            
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);
        }
    }


    displayRecordPerPage(page) {
        //console.log('inside displayrecordpage');
        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount)
            ? this.totalRecountCount : this.endingRecord;

        this.faultdata = this.items.slice(this.startingRecord, this.endingRecord);

        this.startingRecord = this.startingRecord + 1;
    }

}