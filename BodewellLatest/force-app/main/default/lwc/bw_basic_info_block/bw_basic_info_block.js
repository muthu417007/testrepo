import { LightningElement,wire,api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import concierge from '@salesforce/resourceUrl/svgconcierge';
import getContent from '@salesforce/apex/BDW_CMSController.getContent';
import basePath from '@salesforce/community/basePath';
export default class BDW_Basic_Info_Block extends NavigationMixin(LightningElement) {
    @api contentId;
    @api richtext;
    @api buttontext;
    @api ButtonWidth = '16';
    @api showImg;
    @api showHeading;
    @api RedirectionLink;
    @api Heading;
    @api imgUrl;
    heading = 'tetsze';
    redirectURL;
    banner;
    conciergesvg = concierge;
    BasePath;
    get buttonwidth() {
        return 'width:' + this.ButtonWidth + 'rem';
    }
    @wire(getContent, { contentId: '$contentId', page: 0, pageSize: 1, language: 'en_US', filterby: '' })
    getInfo({ error, data }) {
        if (data) {
            this.banner = data.source ? basePath + '/sfsites/c' + data.source.unauthenticatedUrl : this.imgUrl;;
            console.log();
            const imageSource = this.template.querySelector('.basic-img');
            if(this.showImg == true){
            //imageSource.setAttribute('src',this.banner);
            const heading = this.template.querySelector('.cta-link-block');
            heading.style.height = '430px';
            const content = this.template.querySelector('.inner-content');
            content.style.padding = '0 20%';
            }
        } else if (error) {
            console.log('error: ', error);
        }
    }

    connectedCallback() {
        this.heading = this.Heading;
    }

    handleClick(){
        this.BasePath = basePath;
        this.redirectURL = this.BasePath + this.RedirectionLink;
    }
}