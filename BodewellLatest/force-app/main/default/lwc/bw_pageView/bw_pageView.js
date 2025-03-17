import { LightningElement, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

export default class Bw_pageView extends NavigationMixin(LightningElement)
{
    title;
    url;
    isLoaded = true;

    @wire(CurrentPageReference)
    getStateParameters(e) {
        this.url = window.location.href;
        if(e.attributes.name)
        {
            this.title = e.attributes.name;
            this.title = this.title.replaceAll('__c','');
            this.title = this.title.replaceAll('_',' ');
            if(this.isLoaded)
            {
                this.gtmPageView();
                this.isLoaded = false;
            }
        }     
        
    }

    gtmPageView() {
        let gtm__pageView = new CustomEvent(
            'gtm__pageView', {
            detail: {
                pageTitle: this.title,
                pageURL: this.url,
                userId: undefined,	
                zipCode: undefined,
                loggedIn: undefined, 
                productType: undefined,
                pageType: undefined, 
                storeType: undefined,
                storeId: undefined,
                storeName: undefined,
                bcPage: undefined
            }
        });
        document.dispatchEvent(
            gtm__pageView, {
            bubbles: true,
            composed: true
        });
    }
    
}