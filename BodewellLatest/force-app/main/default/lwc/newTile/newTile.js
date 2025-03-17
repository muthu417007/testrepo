import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath';
import getContent from '@salesforce/apex/ManagedContentController.getContent';

export default class DemoTile extends NavigationMixin(LightningElement) {
    @api contentId;
    pageName;
    backgroundURL;
    title;

    @wire(getContent, {
        contentId: '$contentId',
        page: 0,
        pageSize: 1,
        language: 'en_US',
        filterby: ''
    })
    results({ data, error }) {
        if (data) {
            console.log(data);
            console.log(JSON.stringify(data));
            this.backgroundURL = basePath + '/sfsites/c' + data.Image.unauthenticatedUrl;
            this.title = data.Title.value;
            this.pageName = data.Page.value;
            this.error = undefined;
        } else if (error) {
            console.log('Error: ' + JSON.stringify(error));
        }
    }

    navToPage(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
    attributes: {
        name: this.pageName
    }
   
        });
    }

    get styling(){
        return "background: url('" + this.backgroundURL + "') no-repeat top center;" +
        "-webkit-background-size: cover;" +
        "-moz-background-size: cover;" +
        "-o-background-size: cover;" +
        "background-size: cover;";
    }

}