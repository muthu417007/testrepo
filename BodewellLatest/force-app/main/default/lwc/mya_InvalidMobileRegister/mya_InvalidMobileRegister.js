import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import mya_GEATeamplate from './mya_InvalidMobileRegister_GEA.html';
import mya_CafeTeamplate from './mya_InvalidMobileRegister_Cafe.html';
import mya_HaierTeamplate from './mya_InvalidMobileRegister_Haier.html';

import FLAG_CANADA from '@salesforce/resourceUrl/flagcanada';
import logo_Img from '@salesforce/resourceUrl/logo';
import cafe_logo from '@salesforce/resourceUrl/cafeLogo320x100';
import haier_logo from '@salesforce/resourceUrl/haierLogo320x100';

export default class Mya_InvalidMobileRegister extends LightningElement {
    @api brand = "GEA";
    K = '';
    M = '';
    S = '';
    L = '';
    D = '';
    P = '';
    reference = false;

    flagcanada = FLAG_CANADA;
    logoImg1 = logo_Img;
    logoImg2 = cafe_logo;
    logoImg3 = haier_logo;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            debugger;
            this.reference = true;
            this.K = currentPageReference.state.K ? currentPageReference.state.K : '';
            this.M = currentPageReference.state.M ? currentPageReference.state.M : '';
            this.S = currentPageReference.state.S ? currentPageReference.state.S : '';
            this.L = currentPageReference.state.L ? currentPageReference.state.L : '';
            this.D = currentPageReference.state.D ? currentPageReference.state.D : '';
            this.P = currentPageReference.state.P ? currentPageReference.state.P : '';
        }
    }

    render() {
        if (this.brand == "GEA") {
            return mya_GEATeamplate;
        } else if (this.brand == "Haier") {
            return mya_HaierTeamplate;
        } else if (this.brand == "Cafe") {
            return mya_CafeTeamplate;
        }
    }
    handleFeedGEA() {
        KAMPYLE_ONSITE_SDK.showForm(11777);
    }
    handleFeedCafe() {
        KAMPYLE_ONSITE_SDK.showForm(17731);
    }
    handleFeedHaier() {
        KAMPYLE_ONSITE_SDK.showForm(11313);
    }
}