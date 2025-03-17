// purpose:- Using on About Us Page Of Repair GE
// Author:- Kanishtika Gupta
// Created By:- Kanishtika Gupta
import { LightningElement,api } from 'lwc';
import netStyles from '@salesforce/resourceUrl/RG_StyleSheet';
import { loadStyle } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation'
import BASE_PATH from '@salesforce/community/basePath'
export default class RG_About_service_Overview extends LightningElement {
    @api contentHeading;
    @api content;
    @api sectionId = 'Service Overview';
    @api baseUrl = BASE_PATH
    @api Head = "Services available"
    isExpand = true;
    pageLinks = [{
        pageLabel: 'Refrigerator',
        pageApiName: 'Refrigerator_Resources__c'
    },
    {
        pageLabel: 'Oven/Range',
        pageApiName: 'Oven_Range_Resources__c'
    },
    {
        pageLabel: 'Dishwasher',
        pageApiName: 'Dishwasher_Resources__c'
    },
    {
        pageLabel: 'Dryer',
        pageApiName: 'Dryer_Resources__c'
    },
    {
        pageLabel: 'Washing Machine',
        pageApiName: 'Washing_Machine_Resources__c'
    },
    {
        pageLabel: 'Freezer',
        pageApiName: 'Freezer__c'
    }
]
    renderedCallback() {
       this.template.querySelector('h2').setAttribute('id',this.sectionId);
        Promise.all([
            loadStyle(this, netStyles)
        ])
    }
    showAll(){
        if (this.isExpand == false) {
            this.isExpand = true;
        } else if (this.isExpand == true) {
            this.isExpand = false;
        }
    }
}