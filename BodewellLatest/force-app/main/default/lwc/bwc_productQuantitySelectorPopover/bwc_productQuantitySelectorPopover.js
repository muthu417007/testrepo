import { LightningElement, api } from 'lwc';
import { closeButtonText, quantityHelpLabel } from './labels';

/**
 * @param {string} [text] The text/value to check
 * @returns {boolean} Whether the given text is neither `undefined`, `null`, nor empty.
 */
function isNotBlank(text) {
    return typeof text === 'string' && text.trim().length > 0;
}
/**
 * Displays quantity messaging when mouse is over quantity icon
 */
export default class bwc_ProductQuantitySelectorPopover extends LightningElement {
    static renderMode = 'light';

    /**
     * @description Gets or sets the Minimum Text
     * @type {string}
     */
    @api
    minimumText;

    /**
     * @description Gets or sets the Maximum Text
     * @type {string}
     */
    @api
    maximumText;

    /**
     * @description Gets or sets the Increment Text
     * @type {string}
     */
    @api
    incrementText;

    /**
     * @description Shows/opens the popup.
     * @private
     */
    openPopup() {
        this.popup?.open({
            alignment: 'top',
            autoFlip: true,
            size: 'small',
        });
    }

    /**
     * @description Closes/hides the popup.
     * @private
     */
    closePopup() {
        this.popup?.close();
    }

    /**
     * @description Gets the popup-source
     * @returns {?HTMLElement} The popup source element
     * @readonly
     * @private
     */
    get popup() {
        return this.querySelector('experience-popup-source');
    }

    /**
     * @description Whether to display the increment text.
     * @type {boolean}
     * @readonly
     * @private
     */
    get showIncrementText() {
        return isNotBlank(this.incrementText);
    }

    /**
     * @description Whether to display the maximum text.
     * @type {boolean}
     * @readonly
     * @private
     */
    get showMaxText() {
        return isNotBlank(this.maximumText);
    }

    /**
     * @description Whether to display the minimum text.
     * @type {boolean}
     * @readonly
     * @private
     */
    get showMinText() {
        return isNotBlank(this.minimumText);
    }

    /**
     * @description Gets the i18n labels to display in the template
     * @type {object}
     * @readonly
     * @private
     */
    get i18n() {
        return {
            closeButtonText,
            quantityHelpLabel,
        };
    }
}