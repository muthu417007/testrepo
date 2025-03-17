import { LightningElement, track, wire, api } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';

import certified from '@salesforce/resourceUrl/svgcertified';
import service from '@salesforce/resourceUrl/svgservice';
import genuine from '@salesforce/resourceUrl/svggenuine';
import appliances from '@salesforce/resourceUrl/svgappliances';

export default class Bw_WhyChooseUS extends NavigationMixin(LightningElement) 
{
    certifiedsvg = certified;
    servicesvg = service;
    genuinesvg = genuine;
    appliancessvg = appliances;

    handleNavigation()
    {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'About_Us__c'
            },
            state: {}
        });
    }
}