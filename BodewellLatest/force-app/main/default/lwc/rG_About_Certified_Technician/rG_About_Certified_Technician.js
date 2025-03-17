import { LightningElement ,api ,wire} from 'lwc';
import netStyles from '@salesforce/resourceUrl/RG_StyleSheet';
import { loadStyle } from 'lightning/platformResourceLoader';
import basePath from '@salesforce/community/basePath';
export default class RG_About_Certified_Technician extends LightningElement {
    @api contentHeading;
    @api technicianimageid;
    @api content;
    @api sectionId;
    @api content2;
    @api buttonlabel;
    @api navigationtype = 'External Link';
    @api redirectionlink;
    @api componentArea;
    redirectURL;
    technicianimg;
    isExpand = true;

    connectedCallback(){
        debugger;
        if(!this.redirectionlink) {
          this.redirectionlink = RG_ScheduleServiceLink;
        }
        if (this.navigationtype == 'Site Page') {
          this.redirectURL = basePath + this.redirectionlink;
        }
        else if (this.navigationtype == 'External Link') {
          this.redirectURL = this.redirectionlink;
        }
    }

    renderedCallback() {
       this.template.querySelector('h2').setAttribute('id',this.sectionId);
        Promise.all([
            loadStyle(this, netStyles)
        ])
        if (this.technicianimageid) {
            this.technicianimg = basePath + '/sfsites/c/cms/delivery/media/' + this.technicianimageid;
         }
    }

    showAll(){
        if (this.isExpand == false) {
            this.isExpand = true;
        } else if (this.isExpand == true) {
            this.isExpand = false;
        }
    }
}