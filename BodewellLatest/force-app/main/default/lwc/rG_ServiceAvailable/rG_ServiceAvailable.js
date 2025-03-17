import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'
import BASE_PATH from '@salesforce/community/basePath'
export default class RG_ServiceAvailable extends NavigationMixin(LightningElement) {

    @api baseUrl = BASE_PATH;
    @api Head = "Services available";
    @track pageList = [];

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
            pageApiName: 'Freezer_Resources__c'
        }
    ];

    connectedCallback() {
        this.pageLinks.forEach((item, index) => {
            this[NavigationMixin.GenerateUrl]({
                type: 'comm__namedPage',
                attributes: {
                    name: item.pageApiName 
                },
            }).then((url) => {                
                this.pageList.push({
                    pageLabel: item.pageLabel,
                    pageApiName: item.pageApiName,
                    pageUrl: url
                });                
                console.log('this.pageList: ', JSON.stringify(this.pageList));
            });
        });    
    }

    handleNavigation(event) {
        event.preventDefault();
        var navUrl = event.currentTarget.dataset.value;
        let reloadEvent = new CustomEvent(
            "rg_redirection", {
            detail: {
                url: navUrl
            }
        });
        document.dispatchEvent(reloadEvent, {
            bubbles: true,
            composed: true
        });
    }
}