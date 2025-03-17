import { LightningElement } from 'lwc';
import BWC_UI from '@salesforce/resourceUrl/BodewellTheme';
import basePath from '@salesforce/community/basePath';

export default class Bwc_minimalThemeLayout extends LightningElement {

    BODEWELL_LOGO = BWC_UI + '/img/Bodewell-logo.png'

    get homeUrl() {
        return basePath;
    }

}