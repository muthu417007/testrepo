import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import getContent from '@salesforce/apex/BDW_Knowledge_Articles.getKnowledgeArticle'
import getContentMobile from '@salesforce/apex/BDW_Knowledge_Articles.getKnowledgeArticleMobile'

export default class Bw_knowledgeArticle extends NavigationMixin(LightningElement)
{
    content = '';
    mobileContent = [];
    urlName;
    overview = [];
    sectionId;
    @track isExpand = true;
    @track mobileArticles = [];
    isLoaded = true;
    url;
    

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlName = currentPageReference.attributes.urlName;
            this.url = window.location.href;
            this.getKnowlegeContent();
            this.getKnowlegeContentMobile();
            
        }
    }

    getKnowlegeContent() {
        getContent({ urlname: this.urlName })
            .then(result => {
                this.content = result;
                
                if(this.isLoaded && this.content)
                {
                    this.gtmPageView();
                    this.gtmEventArticleView();
                    this.isLoaded = false;
                }
                this.overview = result.Overview__c.split(";");
                console.log(this.overview);
                console.log(this.content);
            })
            .catch(error => {
                console.log(error);
            });
    }

    getKnowlegeContentMobile() {
        getContentMobile({ urlname: this.urlName })
            .then(result => {
                this.mobileArticles.isOpen = false;
                this.mobileArticles.heading = result.heading;
                this.mobileArticles.subItemList = [];
                result.subItemList.forEach((item, index) => 
                {
                    this.mobileArticles.subItemList.push({});
                    this.mobileArticles.subItemList[index].subItemContent = item.subItemContent;
                    this.mobileArticles.subItemList[index].subItemHeading = item.subItemHeading;
                });
            })
            .catch(error => {
                console.log(error);
            });
    }

    gtmPageView() {
        let gtm__pageView = new CustomEvent(
            'gtm__pageView', {
            detail: {
                pageTitle: this.content.Title + ' | FAQ | Bodewell',
                pageURL: this.url
            }
        });
        document.dispatchEvent(
            gtm__pageView, {
            bubbles: true,
            composed: true
        });
    }

    handleScroll(e) {
        var ind = parseInt(e.target.dataset.value) + 1;
        this.sectionId = '#section' + ind;
    }

    showAll(e)
    {
        this.mobileArticles.subItemList[e.currentTarget.dataset.id].isOpen = true;
    }
    hideAll(e)
    {
        this.mobileArticles.subItemList[e.currentTarget.dataset.id].isOpen = false; 
    }

    gtmEventArticleView() {
        let gtmEventArticleView = new CustomEvent(
            'gtm__articleView', {
            detail: {
                articleName: this.content.Title,
                articleType: "FAQ",
                articleCategory: this.content.Related_Resource__c
            }
        });
        document.dispatchEvent(
            gtmEventArticleView, {
            bubbles: true,
            composed: true
        });
    }
}