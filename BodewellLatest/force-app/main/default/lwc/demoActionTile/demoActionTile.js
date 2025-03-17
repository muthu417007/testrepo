import { LightningElement, api, wire } from 'lwc';
import basePath from '@salesforce/community/basePath';
import getContent from '@salesforce/apex/ManagedContentController.getContent';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class DemoTile extends LightningElement {
    @api contentId;
    modalOpen = false;
    backgroundURL;
    error;
    resourceURL; 
    description;
    title;
    type;

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
            this.title = data.Title.value;
            this.type = data.Type.value;
            this.backgroundURL =
                basePath + '/sfsites/c' + data.Background_Image.unauthenticatedUrl;
            this.resourceURL = data.Resource_URL.value;
            this.error = undefined;
        } else if (error) {
            console.log('Error: ' + JSON.stringify(error));
        }
    }

    openModal(){
        this.modalOpen = true;
    }

    closeModal(){
        this.modalOpen = false;
    }
    get isPDF(){
        return this.type === 'PDF';
    }

    get styling(){
        return "background: url('" + this.backgroundURL + "') no-repeat top center;" +
        "-webkit-background-size: cover;" +
        "-moz-background-size: cover;" +
        "-o-background-size: cover;" +
        "background-size: cover;";
    }

    get isModalOpen(){
        return this.modalOpen;
    }

    get isPhonePDF(){
        return this.type === 'PDF' && FORM_FACTOR === 'Small';
    }
}