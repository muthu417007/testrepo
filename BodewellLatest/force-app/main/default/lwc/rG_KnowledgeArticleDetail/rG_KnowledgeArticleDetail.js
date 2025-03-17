import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import getKnowledgeArticleDetail from '@salesforce/apex/RG_KnowledgeArticleController.getKnowledgeArticle';
import getKnowledgeArticleMobile from '@salesforce/apex/RG_KnowledgeArticleController.getKnowledgeArticleMobile';
import RG_FaqDetailsPageTitle from '@salesforce/label/c.RG_Faq_Details_Page_Title';

export default class RG_KnowledgeArticleDetail extends LightningElement {
    content = '';
    articleURL;
    urlName;
    overview = [];
    @track mobileArticles = [];
    isLoaded = false;
    isMobileLoaded = false;

    myBreadcrumbs = [
        {
            id: 'Home',
            label: 'Home',
            url: '/regea',
            isActive: false
        },
        {
            id: 'Resource_Hub',
            label: 'Resource Hub',
            url: '/regea/resources',
            isActive: false
        },
        {
            id: 'FAQ',
            label: 'FAQ',
            url: '/regea/resources/faq',
            isActive: false
        }
    ];

    breadcrumbs = [];

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference && !this.articleURL) {
            this.articleURL = currentPageReference.attributes.urlName;
            this.myBreadcrumbs.push({
                id: 'Article',
                label: this.articleURL,
                isActive: true
            });
            this.breadcrumbs = this.myBreadcrumbs;
            this.getKnowledgeArticle();
            this.getKnowlegeContentMobile();
        }
    }

    getKnowledgeArticle() {
        getKnowledgeArticleDetail({ articleURL: this.articleURL })
            .then(result => {
                this.content = result;
                this.isLoaded = true;
                this.handlePageView(this.articleURL);               
            })
            .catch(error => {
                console.log(error);
            });
    }

    showAll(e) {
        this.mobileArticles.subItemList[e.currentTarget.dataset.id].isOpen = true;
    }

    hideAll(e) {
        this.mobileArticles.subItemList[e.currentTarget.dataset.id].isOpen = false;
    }

    getKnowlegeContentMobile() {
        getKnowledgeArticleMobile({ articleURL: this.articleURL })
            .then(result => {
                this.isMobileLoaded = true;
                this.mobileArticles.isOpen = false;
                this.mobileArticles.startText = result.startText;
                if (result.startText.length > 0) {
                    this.mobileArticles.hasStartText = true;
                }
                this.mobileArticles.subItemList = [];
                result.subItem.forEach((item, index) => {
                    this.mobileArticles.subItemList.push({});
                    this.mobileArticles.subItemList[index].subItemContent = item.subItemContent;
                    this.mobileArticles.subItemList[index].subItemHeading = item.subItemHeading;
                });
            })
            .catch(error => {
                console.log(error);
            });
    }

    handlePageView(data) {
        // let titleLabel = RG_FaqDetailsPageTitle.split('{}');
        // let text = this.capFormat(data);
        // document.title = text + '?' + titleLabel[1];
        this.pageViewEvent();
    }

    capFormat(data) {
        let asd = data.split('-');
        let res = '';
        asd.forEach((item) => {
            let itemLower = item.toLowerCase();
            res = (res.length == 0) ? res : res + ' ';
            res = res + itemLower[0].toUpperCase() + itemLower.substring(1);
        });
        return res;
    }

    pageViewEvent() {
        if(!this.eventFired) {
            let pageViewEvent = new CustomEvent("gtm__pageView");
            document.dispatchEvent(pageViewEvent, {
                bubbles: true,
                composed: true
            });      
            this.eventFired = true;
        }  
    }

    disableLink(event) {
        event.preventDefault();
    }
}