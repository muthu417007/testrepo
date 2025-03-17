import { LightningElement, api } from 'lwc';

/**
 * @description A generic display of dot indicators that provides a visual indication of a position within a sequence.
 */
export default class bwc_dotIndicators extends LightningElement {
    static renderMode = 'light';
    /**
     * @description Gets or sets the integral number of indicators to display.
     * @type {number}
     */
    @api count = 0;

    /**
     * @description Gets or sets the 0-based index of the indicator that appears selected.
     *
     * @type {number}
     */
    @api selectedIndex = 0;

    /**
     * @description Gets the sequence of indicators to display.
     *
     * @type { ImageIndicator[] }
     * @private
     */
    get displayedImageIndicators() {
        const count = this.count !== undefined ? Math.max(this.count, 0) : 0;
        return [...Array(count).keys()].map((id) => ({
            id: String(id),
            classes:
                id === this.selectedIndex
                    ? 'slds-carousel__indicator-action slds-is-active'
                    : 'slds-carousel__indicator-action',
        }));
    }
}