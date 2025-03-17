import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getKnowledgeArticleListFAQ from '@salesforce/apex/RG_KnowledgeArticleController.getKnowledgeArticleListFAQ';

import rG_KnowledgeArticleListCard from './rG_KnowledgeArticleListCard.html';
import rG_KnowledgeArticleListCardFAQ from './rG_KnowledgeArticleListCardFAQ.html';

import netStyles from '@salesforce/resourceUrl/RG_StyleSheet';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class RG_KnowledgeArticleListCard extends NavigationMixin(LightningElement)
{
    @api relatedResource;
    @api pageName;
    @api sectionId;
    articleURL;
    knowledgeArticleListFAQ = [];
    isExpand = true;

    @track redirectArticleUrl;
    @track redirectFaqUrl;
    @track faqList = [];

    connectedCallback() {
        debugger;
        this.getKnowledgeArticleList();

        // this[NavigationMixin.GenerateUrl]({
        //     type: 'standard__knowledgeArticlePage',
        //     attributes: {
        //         articleType: 'Knowledge_Article_Detail__c',
        //     }
        // }).then(url => {
        //     this.redirectArticleUrl = url;
        // });

        this[NavigationMixin.GenerateUrl]({
            type: 'comm__namedPage',
            attributes: {
                name: 'FAQ__c',
            }
        }).then(url => {
            this.redirectFaqUrl = url;
        });
    }

    renderedCallback() {
        if (this.pageName == "FAQ") {
            this.template.querySelector('.resource-title').setAttribute('id', this.sectionId);
        }
        Promise.all([
            loadStyle(this, netStyles)
        ])
    }

    render() {
        if (this.pageName == "RESOURCE") {
            return rG_KnowledgeArticleListCard
        } else if (this.pageName == "FAQ") {
            return rG_KnowledgeArticleListCardFAQ
        }
    }

    getKnowledgeArticleList() {
        getKnowledgeArticleListFAQ({ relatedResource: this.relatedResource })
            .then(result => {
                this.knowledgeArticleListFAQ = result;
                this.faqList = result.map((item, index) => {
                    debugger;
                    return {
                        id: index,
                        url: this.redirectFaqUrl + '/article/' + item.UrlName,
                        title: item.Title,
                        summary: item.Summary
                    }
                });
                console.log('this.knowledgeArticleListFAQ: ', this.knowledgeArticleListFAQ);
            })
            .catch(error => {
                console.log(error);
            });
    }

    handleArticle(event) {
        event.preventDefault();
        let navUrl = event.currentTarget.dataset.value;
        // this[NavigationMixin.GenerateUrl]({
        //     type: 'comm__namedPage',
        //     attributes: {
        //         name: 'FAQ_Article__c',
        //     },
        //     state: {
        //         article: this.articleURL
        //     }
        // }).then(url => {
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
        // });
    }
    handleFAQ(event) {
        event.preventDefault();
        let reloadEvent = new CustomEvent(
            "rg_redirection", {
            detail: {
                url: this.redirectFaqUrl
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