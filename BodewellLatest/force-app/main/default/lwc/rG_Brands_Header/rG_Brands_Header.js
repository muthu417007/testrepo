import { LightningElement,api } from 'lwc';
import netStyles from '@salesforce/resourceUrl/RG_StyleSheet';
import { loadStyle } from 'lightning/platformResourceLoader';
import BasePath from '@salesforce/community/basePath';
export default class RG_Brands_Header extends LightningElement {
    basePath = BasePath;
    imageicon;        
    @api imageiconid;
    renderedCallback() {
        Promise.all([
            loadStyle(this, netStyles)
        ])
        if (this.imageiconid) {
            this.imageicon = this.basePath + '/sfsites/c/cms/delivery/media/' + this.imageiconid;
        }
    }
    // scrollFunction(e) {
    //    const brandsheader = this.template.querySelector('.brands-header');   //To hide the element.
    //    brandsheader.style.display = 'none';
    // }
}