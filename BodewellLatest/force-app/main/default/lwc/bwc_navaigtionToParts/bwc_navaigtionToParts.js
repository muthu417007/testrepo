import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation' 
import iconNavigationResource from '@salesforce/resourceUrl/BWC_PartsNavigationIcon';

export default class Bwc_navaigtionToParts extends NavigationMixin(LightningElement) {

    partsIcon = iconNavigationResource;

    connectedCallback() {
        
    }

    navigateToPartsFinder(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'parts_search__c'
            }
        })
    }
}