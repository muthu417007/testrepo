import { LightningElement, api } from 'lwc';
import netStyles from '@salesforce/resourceUrl/RG_StyleSheet';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class RG_RichTextContentCard extends LightningElement 
{
    @api contentHeading;
    @api content;
    @api sectionId;
    isExpand = true;
    renderedCallback() {
       this.template.querySelector('h2').setAttribute('id',this.sectionId);
        Promise.all([
            loadStyle(this, netStyles)
        ])
    }
    showAll() {
        if (this.isExpand == false) {
            this.isExpand = true;
        } else if (this.isExpand == true) {
            this.isExpand = false;
        }
    }
}