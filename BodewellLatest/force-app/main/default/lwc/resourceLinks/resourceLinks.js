import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getContentList from '@salesforce/apex/ManagedContentController.getContentList';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class ResourceLinks extends NavigationMixin(LightningElement) {
    @api label;
    @track links =[];
    pdfURL;
    modalOpen = false;
    
    connectedCallback() {
        this.getLinks();
    }

    getLinks(){
        getContentList({
            page: 0,
            pageSize: '100',
            language: 'en_US',
            filterby: 'Resource_Link'
        })
        .then((links) => {
            links.forEach(link => {
                if(this.label===link.contentNodes.Type.value)
                this.links.push({
                    key: link.contentKey,
                    title: link.contentNodes.Title.value,
                    URL: link.contentNodes.URL.value
                });
            });
        })
        .catch((error) => {
            console.log('Error: ' + JSON.stringify(error));
        });
    }

    openModal(event){
        let key = event.currentTarget.dataset.id;
        this.links.forEach(link => {
            if(link.key===key){
                this.pdfURL = link.URL;
            }
        });
        this.modalOpen = true;
    }

    closeModal(){
        this.modalOpen = false;
    }

    get openInWindow(){
        if((this.label === 'Quick Sheets' && FORM_FACTOR === 'Small') || this.label === 'Quick Links'){
            return true;
        }
        return false;
    }
}