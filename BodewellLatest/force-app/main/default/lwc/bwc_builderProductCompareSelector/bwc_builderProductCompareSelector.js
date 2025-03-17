import { LightningElement, track } from 'lwc';
import bwc_CommonModal from 'c/bwc_commonModal';

const MAX_COMPARED_PRODUCTS = 4;
const MIN_COMPARED_PRODUCTS = 2;

export default class bwc_builderProductCompareSelector extends LightningElement {
    skus = ['sku1','sku2','sku3','sku4','sku5'];

    @track
    selectedSkus = [];

    get skuCount() {
        return this.selectedSkus.length;
    }

    handleCompare(event) {
        console.log(`bwc_builderProductCompareSelector::handleCompare: ${JSON.stringify(event.detail, null, 2)}`);
        this.selectedSkus.push(event.detail.sku);

        if (this.skuCount > MAX_COMPARED_PRODUCTS) {
            bwc_CommonModal.open({
                label: 'You can only compare up to 4 products.',
                size: 'large'
            });
        }
    }

    handleUnCompare(event) {
        console.log(`bwc_builderProductCompareSelector::handleUnCompare: ${JSON.stringify(event.detail, null, 2)}`);
        this.selectedSkus = this.selectedSkus.filter(sku => sku !== event.detail.sku);
    }

    handleCompareNow(event) {
        console.log(`bwc_builderProductCompareSelector::handleCompareNow: ${JSON.stringify(event.detail, null, 2)}`);
        if (this.skuCount < MIN_COMPARED_PRODUCTS) {
            bwc_CommonModal.open({
                label: 'You can only compare 2 or more products.',
                size: 'large'
            });
        } else if (this.skuCount > MAX_COMPARED_PRODUCTS) {
            bwc_CommonModal.open({
                label: 'You can only compare up to 4 products.',
                size: 'large'
            });
        }
    }
}