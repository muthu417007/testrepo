import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import BasePath from '@salesforce/community/basePath';
import getBreadCrumbs from '@salesforce/apex/RG_BreadCrumbController.getBreadCrumbs';

export default class RG_Breadcrumb extends NavigationMixin(LightningElement) {

    @track myBreadcrumbs = [];
    connected = false;
    currentUrl;
    currentPageRef;
    urlChanged = false;
    refChanged = false;
    isRecursive = false;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        this.currentPageRef = currentPageReference;
        let attribute;
        if (this.currentPageRef && this.currentPageRef.attributes && this.currentPageRef.attributes.name) {
            attribute = this.currentPageRef.attributes.name;
        }
        window.scrollTo(0, 0);
        if (sessionStorage.getItem('myBreadcrumbs')) {
            this.setBreadCrumb(JSON.parse(sessionStorage.getItem('myBreadcrumbs'), attribute));
        }
    }

    @wire(getBreadCrumbs)
    wiredMenuItems({ error, data }) {
        if (data && data.success) {
            let attribute;
            if (this.currentPageRef && this.currentPageRef.attributes && this.currentPageRef.attributes.name) {
                attribute = this.currentPageRef.attributes.name;
            }
            this.setBreadCrumb(data.result, attribute);
            sessionStorage.setItem('myBreadcrumbs', JSON.stringify(data.result));
        } else if (data && !data.success) {
        } else if (error) {
            this.error = error;
            this.success = 'Failed';
        }
    }

    setBreadCrumb(input, name) {
        let node = input.filter(el => el.Page_API_Name__c == name)[0];
        if (node && !this.isRecursive) {
            if (this.currentPageRef.state && this.currentPageRef.state.servicearea && this.currentPageRef.state.localarea) {
                this.myBreadcrumbs.push({ label: this.titleCase(this.currentPageRef.state.localarea), id: this.currentPageRef.state.localarea, url: BasePath + node.Url__c + '?servicearea=' + this.currentPageRef.state.servicearea + '&localarea=' + this.currentPageRef.state.localarea, isActive: false });
            }
            if (this.currentPageRef.state && this.currentPageRef.state.servicearea) {
                this.myBreadcrumbs.push({ label: this.titleCase(this.currentPageRef.state.servicearea), id: this.currentPageRef.state.servicearea, url: BasePath + node.Url__c + '?servicearea=' + this.currentPageRef.state.servicearea, isActive: false });
            }
            if (this.currentPageRef.state && this.currentPageRef.state.article) {
                this.myBreadcrumbs.push({ label: this.titleCaseForArticle(this.currentPageRef.state.article), id: this.currentPageRef.state.article, url: BasePath + node.Url__c + '?article=' + this.currentPageRef.state.article, isActive: false });
            }
        }
        if (node && node.IsLabelVisible__c) {
            this.myBreadcrumbs.push({ label: node.Label, id: node.Page_API_Name__c, url: BasePath + node.Url__c, isActive: false });
        }
        if (node && node.Parent__c) {
            this.isRecursive = true;
            this.setBreadCrumb(input, node.Parent__c);
        }
        if (node && !node.Parent__c) {
            this.myBreadcrumbs.reverse();
            console.log('this.myBreadcrumbs:', this.myBreadcrumbs[this.myBreadcrumbs.length - 1]);
            this.myBreadcrumbs[this.myBreadcrumbs.length - 1].isActive = true;
        }
    }

    setQueryParamsLink() {
        if (this.currentPageRef.state && this.currentPageRef.state.servicearea && this.currentPageRef.state.localarea) {
            this.myBreadcrumbs.push({ label: this.titleCase(this.currentPageRef.state.localarea), id: this.currentPageRef.state.localarea, url: BasePath + node.Url__c + '?servicearea=' + this.currentPageRef.state.servicearea + '&localarea=' + this.currentPageRef.state.localarea, isActive: false });
        }
        if (this.currentPageRef.state && this.currentPageRef.state.servicearea) {
            this.myBreadcrumbs.push({ label: this.titleCase(this.currentPageRef.state.servicearea), id: this.currentPageRef.state.servicearea, url: BasePath + node.Url__c + '?servicearea=' + this.currentPageRef.state.servicearea, isActive: false });
        }
        if (this.currentPageRef.state && this.currentPageRef.state.article) {
            this.myBreadcrumbs.push({ label: this.titleCaseForArticle(this.currentPageRef.state.article), id: this.currentPageRef.state.article, url: BasePath + node.Url__c + '?article=' + this.currentPageRef.state.article, isActive: false });
        }
    }


    connectedCallback() {
        this.connected = true;
    }

    titleCase(str) {
        str = str.toLowerCase();
        str = str.split(' ');
        for (var i = 0; i < str.length; i++) {
            str[i] = str[i].charAt(0).toUpperCase() + str[i].slice(1);
        }
        return str.join(' ');
    }

    titleCaseForArticle(str) {
        str = str.toLowerCase();
        str = str.split('-');
        for (var i = 0; i < str.length; i++) {
            str[i] = str[i].charAt(0).toUpperCase() + str[i].slice(1);
        }
        return str.join(' ');
    }

    disableLink(event) {
        event.preventDefault();
    }

}