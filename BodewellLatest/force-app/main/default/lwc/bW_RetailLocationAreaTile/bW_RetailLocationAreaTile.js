import { LightningElement, api } from 'lwc';
import locationpin from '@salesforce/resourceUrl/svglocationpin';

export default class BW_RetailLocationAreaTile extends LightningElement {
    
    locationpinsvg = locationpin;
    retailAreaLocations = [{
        location: 'Brandon',
        index: 1,
        address: '1983 W Lumsden Rd.',
        street: 'Suite 1983',
        city: 'Brandon',
        state: 'Florida',
        zip: '33511',
        stateAbbreviation: 'FL',
        localPhone: '813-662-4367',
        url: '/retail-area/brandon',
        sideText: 'Visit Bodewell in-store for access to expert advice and appliance essentials all in one place. Need to repair? Order quality parts for in-store pick up to speed up the process. Thinking about an appliance upgrade? Consult our in-store team to compare options and make the right decision for your home. Our appliance experts are here to help you—stop by today!'
    }];

    connectedCallback() {}
}