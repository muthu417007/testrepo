import { LightningElement,api, wire } from 'lwc';
import BasePath from '@salesforce/community/basePath';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubsub';

export default class RG_MediaWhyChooseUs extends NavigationMixin(LightningElement)
{
    @api heading1 = 'WHY CHOOSE US';
    @api content1 = 'At GE Appliances Factory Service, we know GE Appliances inside and out.';
    @api heading2 = 'GENUINE PARTS';
    @api content2 = 'We only use genuine GE Appliances parts';
    @api heading3 = 'All Appliances Repaired';
    @api content3= 'We fix all GE Appliances brands: GE, Profile, Café, Monogram, Hotpoint, Haier, and Adora';
    @api heading4 = 'Reliable Service';
    @api content4= 'Fast, reliable repairs at an affordable price';
    @api heading5 = 'COMPREHENSIVE CARE';
    @api content5 = 'Fully stocked repair vans so most repairs are completed same day*';
    @api bottommessage = '* GE Appliances technicians carry an extensive parts inventory on their service trucks. In the event a part is not available on the service truck, a follow-up service call may be required.';
    @api icon1;
    @api icon2;
    @api icon3;
    @api icon4;
    @api buttonLabel = 'Learn More';
    @api redirectionLink;
    icon1Id;
    icon2Id;
    icon3Id;
    icon4Id;  
    @wire(CurrentPageReference) pageRef;
    isValidPage = false;
    connected = false;

    connectedCallback(){
        if(this.icon1){
           this.icon1Id = BasePath + '/sfsites/c/cms/delivery/media/' + this.icon1;
        }
        if(this.icon2){
           this.icon2Id = BasePath + '/sfsites/c/cms/delivery/media/' + this.icon2;
        }
        if(this.icon3){
            this.icon3Id = BasePath + '/sfsites/c/cms/delivery/media/' + this.icon3;
         }
         if(this.icon4){
            this.icon4Id = BasePath + '/sfsites/c/cms/delivery/media/' + this.icon4;
         }
        registerListener('mediaContentEnabled', this.handleEvent, this);
        if (!this.connected) {
            fireEvent(this.pageRef, 'mediaContentEnabledCallBack', true);
        }
        this.connected = true;
     }

    handleEvent(inpVal) {
        this.isValidPage = inpVal;
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }
}