import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';
import basePath from '@salesforce/community/basePath';
import getContent from '@salesforce/apex/ManagedContentController.getContent';

export default class DemoBtnList extends NavigationMixin(LightningElement) {
    contentId;
    demoData;
    stepData;
    stepSubTitle;
    totalSteps
    stepDescription;
    stepBackgroundURL;
    stepArrowImgURL;
    modalOpen = false;
    stepMainImgURL;
    stepMobileImgURL
    stepArrowImgURL;
    previousContentKeyOrder = [];
    prevStepContentKey;
    currentStepContentKey;
    path;

    @wire(CurrentPageReference)
    pageReference({ attributes }) {
        if (attributes && attributes.urlAlias) {
            let aliasParts = attributes.urlAlias.split('-');
            this.contentId = aliasParts.pop();
            this.getDemoData();
        }
    }

    getDemoData() {
        getContent({
            contentId: this.contentId,
            page: 0,
            pageSize: 1,
            language: 'en_US',
            filterby: ''
        })
        .then((data) => {
            this.demoData = data;
            this.error = undefined;
        })
        .catch((error) => {
            console.log('Error: ' + JSON.stringify(error));
        });
    }

    getStep(contentKey) {
        this.currentStepContentKey = contentKey;
        getContent({
            contentId: contentKey,
            page: 0,
            pageSize: 1,
            language: 'en_US',
            filterby: ''
        })
        .then((data) => {
            this.stepData = data;
            console.log('data->'+JSON.stringify(data));
            this.stepBackgroundURL = basePath + '/sfsites/c' + data.Background_Image.unauthenticatedUrl;
            this.stepArrowImgURL = basePath + '/sfsites/c' + data.Arrow_Image?.unauthenticatedUrl;
            this.stepDescription = htmlDecode(data.Description.value);
            this.modalOpen = true;
            if(data.Main_Image!==undefined){
                this.stepMainImgURL = basePath + '/sfsites/c' + data.Main_Image.unauthenticatedUrl;
            }else{
                this.stepMainImgURL = undefined;
            }

            if(data.Mobile_Image!==undefined){
                this.stepMobileImgURL = basePath + '/sfsites/c' + data.Mobile_Image.unauthenticatedUrl;
            }else{
                this.stepMobileImgURL = undefined;
            }
            
            this.error = undefined;
        })
        .catch((error) => {
            console.log('Error: ' + JSON.stringify(error));
        });
    }

    closeModal(){
        this.modalOpen = false;
    }

    openPath1(){
        this.stepSubTitle = this.demoData.Path1_Title.value;
        this.totalSteps = this.demoData.Total_Steps.value;
        this.path = 1;
        this.getStep(this.demoData.Path1_Content_Key.value);
    }

    openPath2(){
        this.stepSubTitle = this.demoData.Path2_Title.value;
        this.totalSteps = this.demoData.Path2_Total_Steps.value;
        this.path = 2;
        this.getStep(this.demoData.Path2_Content_Key.value);
    }

    openPath3(){
        this.stepSubTitle = this.demoData.Path3_Title.value;
        this.totalSteps = this.demoData.Path3_Total_Steps.value;
        this.path = 3;
        this.getStep(this.demoData.Path3_Content_Key.value);
    }

    goToPrevStep(){
        this.getStep(this.previousContentKeyOrder.pop());
    }

    goToNextStep(){
        this.previousContentKeyOrder.push(this.currentStepContentKey);
        this.getStep(this.stepData.Next_Step_Content_Key.value);
    }

    exit(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Demos__c'
            },
        });
    }

    get dataLoaded(){
        return this.demoData !== undefined;
    }

    get hasPath2(){
        return this.demoData.Path2_Title?.value && this.demoData.Path2_Content_Key?.value
    }

    get hasPath3(){
        return this.demoData.Path3_Title?.value && this.demoData.Path3_Content_Key?.value
    }

    get style(){
        return 'background: url("'+this.stepBackgroundURL+'") no-repeat center center fixed;' + 
        '-webkit-background-size: cover;' + 
        '-moz-background-size: cover;' + 
        '-o-background-size: cover;' +
        'background-size: cover;';
    }

    get isModalOpen(){
        return this.modalOpen;
    }

    get displayRightArrow(){
        return this.stepData?.Next_Step_Content_Key?.value;
    }

    get displayLeftArrow(){
        return this.stepData?.Step_Number?.value !== '1';
    }

    get isNotSmallScreen(){
        return FORM_FACTOR !== 'Small';
    }

    get hasMainImg(){
        return this.stepMainImgURL !== undefined;
    }

    get hasMobileImg(){
        return this.stepMobileImgURL !== undefined;
    }

    get isLastStep(){
        return this.stepMainImgURL === undefined;
    }
}

//hack to remove html tags and get plain text from CMS.body.value
function htmlDecode(input) {
    var doc = new DOMParser().parseFromString(input, 'text/html');
    let parsedstring = doc.documentElement.textContent;
    return parsedstring;
}