import { LightningElement } from 'lwc';
import BWC_UI from '@salesforce/resourceUrl/BodewellTheme';
import BRAND_LABELS from './labels';


export default class Bwc_shopByBrandNav extends LightningElement {

    MONOGRAM_LOGO = BWC_UI + '/img/monogram-logo.png'
    CAFE_LOGO = BWC_UI + '/img/cafe-logo.png'
    PROFILE_LOGO = BWC_UI + '/img/profile-logo.png'
    GE_LOGO = BWC_UI + '/img/ge-logo.png'
    HAIER_LOGO = BWC_UI + '/img/haier-logo.png'
    HOTPOINT_LOGO = BWC_UI + '/img/hotpoint-logo.png'


    // NEED TO DEFINE THE URLS - Not sure which pages these will link to yet
    // Possibly landing pages?
    get options() {
        let _labels = BRAND_LABELS.BRAND_LABELS;
        return [
            { 
                label: _labels.monogram, 
                title: 'Monogram',
                img: this.MONOGRAM_LOGO,
                url: '#',
                value: 0
            },
            { 
                label: _labels.cafe, 
                title: 'Cafe',
                img: this.CAFE_LOGO,
                url: '#',
                value: 1
            },
            { 
                label: _labels.profile, 
                title: 'Profile',
                img: this.PROFILE_LOGO,
                url: '#',
                value: 2
            },
            { 
                label: _labels.ge, 
                title: 'GE',
                img: this.GE_LOGO,
                url: '#',
                value: 3
            },
            { 
                label: _labels.haier, 
                title: 'Haier',
                img: this.HAIER_LOGO,
                url: '#',
                value: 4
            },
            { 
                label: _labels.hotpoint, 
                title: 'Hotpoint',
                img: this.HOTPOINT_LOGO,
                url: '#',
                value: 5
            }

        ];
    }
  
}