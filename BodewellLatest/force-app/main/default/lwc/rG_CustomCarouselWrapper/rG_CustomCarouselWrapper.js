import { LightningElement, wire, track } from 'lwc';
import CAROUSEL_IMAGES from '@salesforce/resourceUrl/RG_Carousel';
import getCarouselSlides from '@salesforce/apex/RG_CarouselSlideDataController.getCarouselSlides';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

export default class RG_CustomCarouselWrapper extends NavigationMixin(LightningElement)
{
    @track slides=[];
    isloaded = false;
    showCarousel = true;
    isOnlyServiceArea = false;
    isServiceArea = false;
    isStateArea = false;

    @wire(getCarouselSlides)
    wiredCrouselSlides({ error, data }) {
        if (data) {
            this.slides = data;
            this.isloaded = true;
        } else if (error) {
            window.console.log(error);
        }
    }

    @wire(CurrentPageReference)
    getStateParameters(CurrentPageReference) {
        if (CurrentPageReference.attributes.name == 'Service_Areas__c' &&
            !CurrentPageReference.state.servicearea) {
            this.isOnlyServiceArea = true;
            this.isServiceArea = true;
        }
        else if (CurrentPageReference.attributes.name == 'Service_Areas__c' &&
            CurrentPageReference.state.servicearea) {
            this.isServiceArea = true;
            this.isStateArea = true;
        }
    }
}