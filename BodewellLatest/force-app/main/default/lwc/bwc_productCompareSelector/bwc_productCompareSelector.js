import { LightningElement, wire, api} from 'lwc';
import { EVENT } from './constants';
import { PRODUCT_COMPARE_LABELS } from './labels';

export default class bwc_productCompareSelector extends LightningElement {
    @api
    sku;

    @api
    isCompared;

    get compareText() {
        if (this.isCompared) {
            return PRODUCT_COMPARE_LABELS.COMPARE_NOW;
        }
        return PRODUCT_COMPARE_LABELS.ADD_TO_COMPARE;
    }

    handleCompare(event) {
        event.preventDefault();
        event.stopPropagation();
        if (event.target.checked) {
            this.dispatchEvent(new CustomEvent(EVENT.COMPARE, {
                bubbles: true,
                detail: {
                    sku: this.sku
                }
            }));

        } else {
            this.dispatchEvent(new CustomEvent(EVENT.UN_COMPARE, {
                bubbles: true,
                detail: {
                    sku: this.sku
                }
            }));
        }
        event.target.checked = false;
    }

    handleCompareNow(event) {
        event.preventDefault();
        event.stopPropagation();
        this.dispatchEvent(new CustomEvent(EVENT.COMPARE_NOW, {
            bubbles: true
        }));
    }
}