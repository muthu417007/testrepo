import { LightningElement } from 'lwc';

export default class BackToTop extends LightningElement {

    scrollToTop(){
        const scrollOptions = {
            left: 0,
            top: 0,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    }
}