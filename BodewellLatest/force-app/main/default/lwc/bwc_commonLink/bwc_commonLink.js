import { api, LightningElement } from 'lwc';
import {
    generateButtonSizeClass,
    generateButtonStretchClass,
    generateButtonStyleClass,
    generateElementAlignmentClass,
} from 'experience/styling';
/**
 * @description a class to make it easier to create links
 */
export default class bwc_CommonLink extends LightningElement {
    static renderMode = 'light';
    @api
    disabled = false;

    /**
     * @description Hyperlink URL.
     * @type {?string}
     */
    @api
    href;

    /**
     * @description The assistive text for the anchor element (or button element in disabled state).
     * @type {?string}
     */
    @api
    assistiveText;

    /**
     * @description The anchor/button variant.
     * @type {?('primary' | 'secondary' | 'tertiary')}
     */
    @api
    variant;

    /**
     * @description The anchor/button size.
     * @type {?('small' | 'large')}
     */
    @api
    size;

    /**
     * @description The anchor/button width.
     * @type {?('stretch' | 'standard')}
     */
    @api
    width;

    /**
     * @description The alignment of the content inside the anchor/button.
     * @type {?('center' | 'left' | 'right')}
     */
    @api
    alignment;

    @api
    focus() {
        this.querySelector('a')?.focus();
    }
    get anchorClasses() {
        return [
            'slds-button slds-button_stretch',
            generateButtonStyleClass(this.variant ?? null),
            generateButtonSizeClass(this.size ?? null),
            generateButtonStretchClass(this.width ?? null),
            generateElementAlignmentClass(this.alignment ?? null),
        ].join(' ');
    }

    /**
     * @description Makes sure that {@link Event.prototype.preventDefault} gets called when
     * the `href` attribute is either `undefined` or blank.
     * @param {Event} event The caught event
     */
    handleClick(event) {
        if (typeof this.href !== 'string' || this.href.trim().length === 0) {
            event.preventDefault();
        }
    }
}