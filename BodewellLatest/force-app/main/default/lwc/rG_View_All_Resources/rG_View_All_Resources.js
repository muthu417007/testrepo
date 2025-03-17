import { LightningElement, wire, track, api } from 'lwc';
import BasePath from '@salesforce/community/basePath';
import getallresources from '@salesforce/apex/RG_ViewAllResources.getAllResources';

export default class RG_View_All_Resources extends LightningElement {

    @api sectionheading = 'WHICH APPLIANCE DO YOU NEED HELP WITH?';
    @api subheading = 'SELECT AN APPLIANCE';
    @api resources = [];
    @track resourceList = [];

    isloaded = false;
    redirectURL;

    @wire(getallresources)
    wiredAllResources({ error, data }) {
        if (data) {
            this.resources = data;
            this.resourceList = data.map((item, index) => {
                return {
                    id: index,
                    redirectURL: BasePath + item.Redirection_Link__c,
                    imageurl: item.Resource_Image__c,
                    name: item.Resource_Name__c
                }
            });
            this.isloaded = true;
            //console.log(`resourceList List: ${JSON.stringify(this.resourceList)}`);
        } else if (error) {
            window.console.log(error);
        }
    }

    connectedCallback() {
        this.basePath = BasePath;
    }

    handleRedirection(event) {        
        event.preventDefault();
        let dataLink = event.currentTarget.dataset.value;
        let reloadEvent = new CustomEvent(
            "rg_redirection", {
            detail: {
                url: dataLink
            }
        });
        document.dispatchEvent(reloadEvent, {
            bubbles: true,
            composed: true
        });
    }
}