import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getKnowledgeArticleListFAQ from '@salesforce/apex/RG_KnowledgeArticleController.getKnowledgeArticleListFAQ';
import netStyles from '@salesforce/resourceUrl/RG_StyleSheet';
import BasePath from '@salesforce/community/basePath';
import { loadStyle } from 'lightning/platformResourceLoader';
export default class RG_FAQKnowledgeArticles extends NavigationMixin(LightningElement)
{
    @api relatedResource;
    @api pageName;
    @api sectionId;
    @track articleURL;
    @track faqArticleUrl;
    @track faqUrl;
    @track knowledgeArticleListFAQ = [];
    basePath = BasePath;
    isExpand = true;

    connectedCallback() {
        this.getKnowledgeArticleList();
        // this[NavigationMixin.GenerateUrl]({
        //     type: 'standard__knowledgeArticlePage',
        //     attributes: {
        //         articleType: 'Knowledge_Article_Detail__c',
        //     }
        // }).then(url => {
        //     this.faqArticleUrl = url;
        // });

        this[NavigationMixin.GenerateUrl]({
            type: 'comm__namedPage',
            attributes: {
                name: 'FAQ__c',
            }
        }).then(url => {
            this.faqUrl = url;
        });
    }

    renderedCallback() {
        this.template.querySelector('.resource-title').setAttribute('id', this.sectionId);
        Promise.all([
            loadStyle(this, netStyles)
        ])
    }

    getKnowledgeArticleList() {
        getKnowledgeArticleListFAQ({ relatedResource: this.relatedResource })
            .then(result => {
                this.knowledgeArticleListFAQ = result.map((item, index) => {
                    debugger;
                    return {
                        id: index,
                        title: item.Title,
                        url: this.faqUrl + '/article/' + item.UrlName
                    }
                });

            })
            .catch(error => {
                console.log(error);
            });
    }

    handleArticle(event) {
        let navUrl = event.currentTarget.dataset.value;
        console.log('article nav url: ', navUrl);
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

    showAll() {
        if (this.isExpand == false) {
            this.isExpand = true;
        } else if (this.isExpand == true) {
            this.isExpand = false;
        }
    }
}