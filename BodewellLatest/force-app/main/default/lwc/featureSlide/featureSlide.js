import { LightningElement, api } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class FeatureSlide extends LightningElement {

    @api slide;
    @api isFront;

    flipSlide(){
        this.dispatchEvent(new CustomEvent('flip'));
    }

    get isVideo(){
        return this.slide.type === 'Video';
    }

    get isSmallScreen(){
        return FORM_FACTOR === 'Small';
    }
}