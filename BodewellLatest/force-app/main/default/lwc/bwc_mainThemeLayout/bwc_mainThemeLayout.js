import { LightningElement, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';


/**
 * @slot bwc_header
 * @slot bwc_footer
 * @slot bwc_copy
 */

export default class Bwc_mainThemeLayout extends LightningElement {
    
    @api displayStickyHeader;

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        // PDP uses a differnt sticky nav so hiding the main header nav for PDP pages
        if (currentPageReference.attributes.objectApiName == 'Product2') {
            this.displayStickyHeader = false;
        } else {
            this.displayStickyHeader = true;
        }
    }

}