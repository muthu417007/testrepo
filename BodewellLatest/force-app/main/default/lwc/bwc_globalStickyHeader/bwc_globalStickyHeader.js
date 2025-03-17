import { LightningElement } from 'lwc';
import BWC_UI from '@salesforce/resourceUrl/BodewellTheme';
import basePath from '@salesforce/community/basePath';

/**
 * @slot stickyNav
 */

export default class Bwc_globalStickyHeader extends LightningElement {

    BODEWELL_LOGO = BWC_UI + '/img/Bodewell-logo-emblem.svg'

    get homeUrl() {
        return basePath;
    }

    connectedCallback(){
        let _this = this;
        window.onscroll = function() {
            _this.transitionHeader();
        };
    }

    // Transition the header background-color for the Homepage
    transitionHeader() {
        let header = this.template.querySelector('.global-header--sticky');
        if (document.body.scrollTop > 100 || document.documentElement.scrollTop > 100) {
            header.classList.add('is-active');
        } else {
            header.classList.remove('is-active');
        }
    }
}