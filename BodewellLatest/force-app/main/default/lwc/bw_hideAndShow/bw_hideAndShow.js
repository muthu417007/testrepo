import { LightningElement, track, api } from 'lwc';

import checksvg from '@salesforce/resourceUrl/check';

export default class Bw_hideAndShow extends LightningElement {
    @track isExpand = true;
    @api Heading1;
    @api Heading2;
    @api Content;
    check = checksvg;
    showAll() {
        if (this.isExpand == false) {
            this.isExpand = true;
        } else if (this.isExpand == true) {
            this.isExpand = false;
        }
    }
}