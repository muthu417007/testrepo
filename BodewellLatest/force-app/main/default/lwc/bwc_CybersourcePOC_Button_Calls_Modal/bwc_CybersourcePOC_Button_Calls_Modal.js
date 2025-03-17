import { LightningElement } from 'lwc';

import cybersourceModal from 'c/bwc_CybersourcePOC_Modal';

export default class bwc_CybersourcePOC_Button_Calls_Modal extends LightningElement {

    handleClick(event) {
        const myPromise = cybersourceModal.open({
            label:'Launch Cybersource Page',
            size: 'full'
        });

        console.log(`bwc_CybersourcePOC_Button_Calls_Modal::myPromise = ${myPromise}`);
    }
}