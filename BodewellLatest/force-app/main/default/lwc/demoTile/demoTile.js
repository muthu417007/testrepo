import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath';
import getContent from '@salesforce/apex/ManagedContentController.getContent';

export default class DemoTile extends NavigationMixin(LightningElement) {
    @api contentId;
    backgroundURL;
    description;
    title;
    path1ContentKey;

    @wire(getContent, {
        contentId: '$contentId',
        page: 0,
        pageSize: 1,
        language: 'en_US',
        filterby: ''
    })
    results({ data, error }) {
        if (data) {
            console.log('contentID-->'+this.contentId+'');
            console.log(data);
            this.title = data.Title.value;
            this.description = htmlDecode(data.Tile_Description.value);
            this.backgroundURL =
                basePath + '/sfsites/c' + data.Background_Image.unauthenticatedUrl;
            this.error = undefined;
        } else if (error) {
            console.log('Error: ' + JSON.stringify(error));
        }
    }

    goToDemoDetail(){
        this[NavigationMixin.Navigate]({
            type: 'standard__managedContentPage',
            attributes :{
                'contentTypeName': 'Demo',
                'contentKey': this.contentId
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

//hack to remove html tags and get plain text from CMS.body.value
function htmlDecode(input) {
    var doc = new DOMParser().parseFromString(input, 'text/html');
    var doc2 = new DOMParser().parseFromString(doc.documentElement.textContent, 'text/html');
    let parsedstring = doc2.documentElement.textContent;

    return parsedstring;
}