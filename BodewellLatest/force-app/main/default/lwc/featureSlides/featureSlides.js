import { api, LightningElement, wire, track} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';
import basePath from '@salesforce/community/basePath';
import getContentList from '@salesforce/apex/ManagedContentController.getContentList';

export default class FeatureSlides extends LightningElement {

    @api recordId;
    @track slides = [];
    @track displaySlides = [];
    mainTileSize = 'full';
    isFront = true;
    contentId;
    
    @wire(CurrentPageReference)
    pageReference({ attributes }) {
        if (attributes && attributes.urlAlias) {
            let aliasParts = attributes.urlAlias.split('-');
            this.contentId = aliasParts.pop();
            this.setMainTileSize();
            this.getSlides();
        }
    }

    getSlides(){
        getContentList({
            page: 0,
            pageSize: '100',
            language: 'en_US',
            filterby: 'Feature_Slide'
        })
        .then((data) => {
            let indexOfSlidesToRender = this.mainTileSize === 'full' ? 0 : 2;
            let mainSlide = this.mainTileSize === 'full' ? indexOfSlidesToRender : 1;
            let records = [...data]; //Object.assign({}, data);
            records.sort(function (a, b) {
                const nameA = a.contentNodes.Display_Order.value;
                const nameB = b.contentNodes.Display_Order.value;
                if (nameA < nameB) {
                    return -1;
                }
                if (nameA > nameB) {
                    return 1;
                }

                // names must be equal
                return 0;
            });
            let j = 0;
            for(let i = 0; i<records.length; i++){
                if(records[i].contentNodes.Parent_Content_Key.value===this.contentId){
                    this.slides.push({
                        index: j,
                        key: records[i].contentKey,
                        title: records[i].contentNodes.Title.value,
                        primaryImageUrl: `${basePath}/sfsites/c${records[i].contentNodes.Primary_Image?.unauthenticatedUrl}`,
                        secondaryImageUrl: `${basePath}/sfsites/c${records[i].contentNodes.Secondary_Image?.unauthenticatedUrl}`,
                        tileBackgroundImageUrl: `${basePath}/sfsites/c${records[i].contentNodes.Tile_Background_Image?.unauthenticatedUrl}`,
                        description: htmlDecode(records[i].contentNodes.Description?.value),
                        videoURL: records[i].contentNodes.Video_URL?.value,
                        type: records[i].contentNodes.Type.value,
                        render: j <= indexOfSlidesToRender,
                        isMain:  j === mainSlide
                    });
                    if(this.slides[j].render){
                        this.displaySlides.push(this.slides[j]);
                    }
                    j++;
                }
            }
        })
        .catch((error) => {
            console.log('Error: ' + JSON.stringify(error));
        });
    }
     
    next(){
        let startIndex = this.displaySlides[0].index+1;
        let maxsteps = FORM_FACTOR === 'Small' ? 1 : 3;
        this.displaySlides = [];
        for(let i = 0; i<this.slides.length*2; i++){
            let slide = i >= this.slides.length ? i - this.slides.length : i;
            this.slides[slide].isMain = false;
            this.slides[slide].render = false;
            if(i >= startIndex && i < startIndex + maxsteps){
                this.slides[slide].render = true;
                if(FORM_FACTOR === 'Small'){
                    this.slides[slide].isMain = true;
                }else if(i==startIndex+1){
                    this.slides[slide].isMain = true;
                }
                this.displaySlides.push(this.slides[slide]); 
            }else if(i >= startIndex){
                break;
            }
            
        }
    }

    prev(){
        let startIndex = this.mainTileSize === 'full' ? this.displaySlides[0].index + this.slides.length - 1 : this.displaySlides[2].index + this.slides.length - 1;
        let maxsteps = this.mainTileSize === 'full' ? 1 : 3;
        this.displaySlides = [];
        for(let i = this.slides.length*2-1; i>0; i--){
            let slide = i >= this.slides.length ? i - this.slides.length : i;
            this.slides[slide].isMain = false;
            this.slides[slide].render = false;
            if(i <= startIndex && i > startIndex - maxsteps){
                this.slides[slide].render = true;
                if(this.mainTileSize === 'full'){
                    this.slides[slide].isMain = true;
                }else if(i==startIndex-1){
                    this.slides[slide].isMain = true;
                }
                this.displaySlides.unshift(this.slides[slide]); 
            }else if(i <= startIndex){
                break;
            }
            
        }
    }

    setMainTileSize(){
        this.mainTileSize = FORM_FACTOR === 'Small' ? 'full' : 'partial';
    }

    flipSlide(){
        this.isFront = !this.isFront;
        if(this.isFront){
            this.setMainTileSize();
        }else{
            this.mainTileSize = 'full';
        }
    }

    get mainSize(){
        return this.mainTileSize === 'full' ? 10 : 4;
    }

    get sideSize(){
        return this.mainTileSize === 'full' ? 0 : 3;
    }

    get showSideSlides(){
        return this.mainTileSize !== 'full';
    }
}

//hack to remove html tags and get plain text from CMS.body.value
function htmlDecode(input) {
    var doc = new DOMParser().parseFromString(input, 'text/html');
    let parsedstring = doc.documentElement.textContent;
    return parsedstring;
}