import { LightningElement,api,track} from 'lwc';
import logo_Img from '@salesforce/resourceUrl/logo';
import cafe_logo from '@salesforce/resourceUrl/cafeLogo320x100';
import haier_logo from '@salesforce/resourceUrl/haierLogo320x100';

import Cafe from "./mya_cafeheader.html";
import GEA from "./mya_header.html";
import Haier from "./mya_haierheader.html";


export default class HeaderComponent extends LightningElement {
    @api brand;
    logoImg1=logo_Img;
    cafelogo1=cafe_logo;
    haierlogo1=haier_logo;
    render() {
        if (this.brand == "GEA") {
            return GEA;
        }
        else if (this.brand == "Haier") {
            return Haier;
        }
        else if (this.brand == "Cafe") {
            return Cafe;
        }
    }
    //console.log('logoImg'+logoImg);
   // console.log('logoImg');
}