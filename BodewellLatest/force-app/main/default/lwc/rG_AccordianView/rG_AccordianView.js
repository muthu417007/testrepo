import { LightningElement, api } from 'lwc';

export default class RG_AccordianView extends LightningElement {
    isExpand = true;
    @api contentHeading;
    @api content;
    
    connectedCallback(){
        //alert('Hai');
    }

    showAll(){
        if (this.isExpand == false) {
            this.isExpand = true;
        } else {
            this.isExpand = false;
        }
    }
}