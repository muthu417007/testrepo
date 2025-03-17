import { LightningElement,wire, api } from 'lwc';
import { fireEvent,registerListener } from 'c/supubsub'; 
import { CurrentPageReference } from 'lightning/navigation'; 
export default class SU_SortBySection extends LightningElement {
    @api eventCode;
    @wire(CurrentPageReference) pageRef; 
    @api translationObject;
    // sortByCheck = '_score';
    @api sortByCheck;
    @api DataLoaded = false;
    get options() {
        return [
            { label: this.translationObject.Sort_by_Relevance , value: '_score' },
            { label: this.translationObject.Sort_by_Created_Date, value: 'post_time' },
        ];
    }

    connectedCallback() {
        registerListener('sendsortdata'+this.eventCode, this.sendSortData, this);
        this.DataLoaded = true;
    }

    sendSortData(data) {
        const startSelect = this.template.querySelector('.select-sort');
        if(startSelect) {
            startSelect.value = data.sortby;
        }
    }

    handleChange(event) {
        let typeValue = event.target.value;
        fireEvent(this.pageRef,'checkType'+this.eventCode,typeValue);
        
    }
}