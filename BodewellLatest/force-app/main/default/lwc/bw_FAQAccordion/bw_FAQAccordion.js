import { LightningElement, api, track, wire } from 'lwc';
import getContent from '@salesforce/apex/BDW_Knowledge_Articles.getKnowledgeArticleURL';
import basepath from '@salesforce/community/basePath';

export default class Bw_FAQAccordion extends LightningElement 
{
    @api ResourceName;
    @track isExpand = true;
    redirectURL;
    BasePath;
    URLs = [];

    connectedCallback() {
        this.BasePath = basepath;
        if(this.ResourceName != 'Resource Name')
        {
            this.getKnowlegeContent();
        }
    }

    getKnowlegeContent() {
        getContent({ resourceName: this.ResourceName })
            .then(result => {
                this.URLs = result;
                console.log(this.URLs);
            })
            .catch(error => {
                console.log(error);
            });
    }

    showAll()
    {
        if(this.isExpand == false)
        {
            this.isExpand = true;
        }
        else if(this.isExpand == true)
        {
            this.isExpand = false;
        }        
    }

    pgName
    handleNavigation(e)
    {
        this.pgName = e.currentTarget.dataset.value;
        //this.gtmEventArticleView();
        this.redirectURL = this.BasePath + '/article/' + this.pgName;
    }
    artName;
    // gtmEventArticleView() {
    //     this.URLs.forEach((item, index) => {
    //         if (item.UrlName == this.pgName) {
    //             this.artName = item.Title;
    //         }
    //     });

    //     let gtmEventArticleView = new CustomEvent(
    //         'gtm__articleView', {
    //         detail: {
    //             articleName: this.pgName,
    //             articleType: "FAQ",
    //             articleCategory: this.artName
    //         }
    //     });
    //     document.dispatchEvent(
    //         gtmEventArticleView, {
    //         bubbles: true,
    //         composed: true
    //     });
    // }
}