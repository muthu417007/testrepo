import { LightningElement, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

import netStyles from '@salesforce/resourceUrl/RG_StyleSheet';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class RG_LookingForParts extends NavigationMixin(LightningElement)
{
    isStateArea = false;
    isServiceArea = false;

    renderedCallback() {
        Promise.all([
            loadStyle(this, netStyles)
        ])
    }
    // xVar;
    // @wire(CurrentPageReference)
    // getStateParameters(currentPageReference) {
    //     this.isStateArea = false;
    //     this.isServiceArea = false;
    //     this.xVar = window.location.href;
    //     if (currentPageReference.state.servicearea) {
    //         this.isServiceArea = true;
    //         this.isStateArea = true;
    //     }
    //     if (this.xVar.includes("service-areas") && !currentPageReference.state.servicearea) {
    //         this.isServiceArea = true;
    //         this.isStateArea = false;
    //     }
    // }

}