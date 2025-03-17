import { api, LightningElement } from 'lwc';
import {
    generateButtonSizeClass,
    generateButtonStretchClass,
    generateButtonStyleClass,
    generateElementAlignmentClass,
} from 'experience/styling';

/**
 * @description a class to make it easier to create buttons
 */
export default class bwc_CommonButton extends LightningElement {
    static renderMode = 'light';
    @api
    disabled = false;

    /**
     * @description The assistive text for the button.
     * @type {?string}
     */
    @api
    assistiveText;

    /**
     * @description The button variant.
     * @type {?('primary' | 'secondary' | 'tertiary')}
     */
    @api
    variant;

    /**
     * @description The button size.
     * @type {?('small' | 'large')}
     */
    @api
    size;

    /**
     * @description The width of the button.
     * @type {?('stretch' | 'standard')}
     */
    @api
    width;

    /**
     * @description The alignment of the content inside the button.
     * @type {?('center' | 'left' | 'right')}
     */
    @api
    alignment;

    @api
    focus() {
        this.querySelector('button')?.focus();
    }
    get buttonClasses() {
        return [
            'slds-button slds-button_stretch',
            generateButtonStyleClass(this.variant ?? null),
            generateButtonSizeClass(this.size ?? null),
            generateButtonStretchClass(this.width ?? null),
            generateElementAlignmentClass(this.alignment ?? null),
        ].join(' ');
    }
}