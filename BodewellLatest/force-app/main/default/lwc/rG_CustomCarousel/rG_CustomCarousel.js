import { LightningElement, api, wire } from 'lwc';
import RG_Disclaimer_Text from '@salesforce/label/c.RG_Disclaimer_Text';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubsub';
import netStyles from '@salesforce/resourceUrl/RG_StyleSheet';
import { loadStyle } from 'lightning/platformResourceLoader';
import RG_Schedule_Call from '@salesforce/label/c.RG_Schedule_Call';
import { CurrentPageReference } from 'lightning/navigation';
const CARD_VISIBLE_CLASS = 'slds-show';
const CARD_HIDDEN_CLASS = 'slds-hide';
const DOT_VISIBLE_CLASS = 'dot active';
const DOT_HIDDEN_CLASS = 'dot';

export default class RG_CustomCarousel extends LightningElement {
    slides = [];
    slidesStatic = [];
    slideIndex = 1;
    @api RG_Disclaimer_Text = RG_Disclaimer_Text;
    tollfreenumber = RG_Schedule_Call;
    tollfreenumberlink;
    pageRef;
    @wire(CurrentPageReference) pageRef;
    
    connectedCallback() {
        //registerListener('localCityTollFreeNo', this.handleEvent, this);
        if (sessionStorage.getItem('serviceAreaPageHeader') == 'true') {
            fireEvent(this.pageRef, 'scheduleServiceCallback', 'true');
        }
        if (this.tollfreenumber) {
            this.tollfreenumberlink = 'tel:' + this.tollfreenumber;
        }
        registerListener('tollFreeNoEvent', this.handleEvent, this);
        if(sessionStorage.getItem('dni_value') != 'true') {
            fireEvent(this.pageRef, 'tollefreeEventCallBack', 'true');
        }
    }
    renderedCallback() {
        Promise.all([
            loadStyle(this, netStyles)
        ])
    }

    handleEvent(inpVal) {
        this.tollfreenumber = inpVal;
        this.tollfreenumberlink = 'tel:' + this.tollfreenumber;
    }
    disconnectedCallback() {
        unregisterAllListeners(this);
    }
    @api
    get slidesData() {
        return this.slides;
    }
    set slidesData(data) {
        this.slides = data.map((item, index) => {
            return index === 0 ?
                {
                    ...item,
                    slideIndex: index + 1,
                    cardClasses: CARD_VISIBLE_CLASS,
                    dotClasses: DOT_VISIBLE_CLASS
                } :
                {
                    ...item,
                    slideIndex: index + 1,
                    cardClasses: CARD_HIDDEN_CLASS,
                    dotClasses: DOT_HIDDEN_CLASS
                }
        })
    }
    handlePrev() {
        let slideIndex = this.slideIndex - 1;
        this.slideSelectionHandler(slideIndex);
    }
    handleNext() {
        let slideIndex = this.slideIndex + 1;
        this.slideSelectionHandler(slideIndex);
    }
    slideSelectionHandler(id) {
        if (id > this.slides.length) {
            this.slideIndex = 1;
        }
        else if (id < 1) {
            this.slideIndex = this.slides.length;
        }
        else {
            this.slideIndex = id;
        }
        this.slides = this.slides.map((item) => {
            return this.slideIndex === item.slideIndex ?
                {
                    ...item,
                    cardClasses: CARD_VISIBLE_CLASS,
                    dotClasses: DOT_VISIBLE_CLASS
                } :
                {
                    ...item,
                    cardClasses: CARD_HIDDEN_CLASS,
                    dotClasses: DOT_HIDDEN_CLASS
                }
        })
    }
    currentSlide(event) {
        let slideIndex = Number(event.target.dataset.id);
        this.slideSelectionHandler(slideIndex);
    }
    handleCall() {

        let contactUsCallEvent = new CustomEvent(
            "gtm__contactUsCall", {
            detail: {
                contact: this.tollfreenumber,
                contactClickLocation: 'body'
            }
        });
        document.dispatchEvent(contactUsCallEvent, {
            bubbles: true,
            composed: true
        });
    }
}