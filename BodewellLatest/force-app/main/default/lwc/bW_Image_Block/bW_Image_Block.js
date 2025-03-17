//Purpose: Bodewell Image Block Section
//Created By :- Kanishtika Gupta
import { LightningElement,api } from 'lwc';
import Path from '@salesforce/community/basePath';
export default class BW_Image_Block extends LightningElement {
    @api contentId;
    @api imagealign = 'Right';
    @api imagewidth;
    imgUrl;
    connectedCallback() {
        this.BasePath = Path;
        if (this.contentId) {
           this.imgUrl = this.BasePath + '/sfsites/c/cms/delivery/media/' + this.contentId;
        }
     }
     get imagePosition() {
      return 'text-align:' + this.imagealign;
    }
    renderedCallback(){
        if(this.imagewidth){
           this.template.querySelector('.image-block').style.width = this.imagewidth + 'px';
        }
    }
}