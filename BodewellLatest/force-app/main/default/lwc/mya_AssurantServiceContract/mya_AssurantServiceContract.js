import { LightningElement, api } from 'lwc';
//import ShieldIcon from '@salesforce/resourceUrl/aiz_shield_icon';
import ShieldIcon from '@salesforce/resourceUrl/bodewell_Image';
import CheckIcon from '@salesforce/resourceUrl/Check_Icon';
import MYAGEACSS from '@salesforce/resourceUrl/MYAGEACSS';
import MYACAFECSS from '@salesforce/resourceUrl/MYACAFECSS';
import MYAHAIERCSS from '@salesforce/resourceUrl/MYAHAIERCSS';

export default class Mya_AssurantServiceContract extends LightningElement {

    @api seeMyPriceLink;
    @api brand;
    isHaier;
    isCafe;
    isGEA;
    isBodewell;
    shieldIcon = ShieldIcon;
    checkIcon = CheckIcon;


    renderedCallback() {
        if (this.brand == "GEA") {
            this.isGEA = true;
        } else if (this.brand == "Haier") {
            this.isHaier = true;
        } else if (this.brand == "Cafe") {
            this.isCafe = true;
        } else if (this.brand == "Bodewell") {
            this.isBodewell = true;
        }
    }
}