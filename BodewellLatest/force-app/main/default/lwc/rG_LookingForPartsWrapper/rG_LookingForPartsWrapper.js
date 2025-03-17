import { LightningElement, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

import netStyles from '@salesforce/resourceUrl/RG_StyleSheet';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class RG_LookingForPartsWrapper extends NavigationMixin(LightningElement)
{
    isStateArea = false;
    isOnlyServiceArea = false;

    renderedCallback() {
        Promise.all([
            loadStyle(this, netStyles)
        ])
    }

    @wire(CurrentPageReference)
    getStateParameters(CurrentPageReference) {
        if (CurrentPageReference.attributes.name == 'Service_Areas__c' &&
            !CurrentPageReference.state.servicearea) {
            this.isOnlyServiceArea = true;
            this.isStateArea = false;
        }
        else if (CurrentPageReference.attributes.name == 'Service_Areas__c' &&
            CurrentPageReference.state.servicearea) {
            this.isOnlyServiceArea = true;
            this.isStateArea = true;
        }
    }
}