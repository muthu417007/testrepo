/**
 * @description Display a list of color swatches and raise change event when color swatch is clicked
 */

import { LightningElement, api } from 'lwc';

export default class bwc_swatchSelector extends LightningElement {
    _items;
    _value;
    _isCentered = false;
    _numSwatches = 6;

    /**
     * @description Controls whether the swatches are centered or left-aligned
     * The swatches are centered for PLP but left-aligned on PDP
     * @type {boolean}
     */
    @api
    get isCentered() {
        return this._isCentered;
    }
    set isCentered(val) {
        this._isCentered = val;
    }

    /**
     * @description Returns the CSS that controls how many swatches
     * will be rendered on a line before wrapping
     * @type {string}
     * @readonly
     */
    get gridCss() {
        let css = 'slds-grid slds-wrap';
        if (this._isCentered) {
            css += ' slds-grid_align-center';
        }
        return css;
    }

    /**
     * @description Controls how many swatches to render on a line
     * before wrapping to the next line
     * @type {integer}
     * @example 6
     */
    @api
    get numSwatches() {
        return this._numSwatches;
    }
    set numSwatches(val) {
        this._numSwatches = val;
    }

    /**
     * @description Returns the CSS string to use for swatch alignment
     * @type {string}
     * @readonly
     */
    get numSwatchesCss() {
        return 'slds-col slds-size_1-of-' + this._numSwatches;
        // return 'slds-col';
    }

    /**
     * @description Get/Set the list of swatches
     * @type {string}
     * @example
     * [
     *   {label: 'green', value: 'green', selected: false, disabled: false, url: 'swatch image url'},
     *   {label: 'blue', value: 'blue', selected: false, disabled: false, url: 'swatch image url'}
     * ]
     */
    @api
    get items() {
        return this._items;
    }

    set items(val) {
        this._items = val;
    }

    /**
     * @description Get/Set the currently selected swatch
     * @type {string}
     * @example "Stainless Steel"
     */
    @api
    get value() {
        return this._value;
    }

    set value(val) {
        this.selectSwatch(this.template.querySelector("input[data-key='" + val + "']"));
    }

    /**
     * @description Handles swatch click
     * @param {Event} e
     */
    handleOnClick(e) {
        e.preventDefault();
        const key = e.target?.dataset?.key;
        if (key) {
            this.selectSwatch(e.target);
            this.dispatchEvent(new CustomEvent('change', {detail: key}));
        }
    }

    /**
     * @description De-select any swatches that are already selected and show the
     * currently selected swatch color with a border and raise the "change" event.
     *
     * Swatch to select
     * @param {HTMLElement} swatchElement
     * @private
     */
    selectSwatch(swatchElement) {
        if (swatchElement) {
            this._value = swatchElement.dataset.key;
            this.template.querySelectorAll('input[type=image]').forEach(node => node.classList.remove('selected'));
            swatchElement.classList.add('selected');
        }
    }
}