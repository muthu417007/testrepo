import { LightningElement, api } from 'lwc';
import { resolve } from 'experience/resourceResolver';
import { createImageDataMap } from 'experience/picture';

/**
 * @description A showcased gallery image that supports optional user selection.
 *
 * @fires GalleryImage#selected
 */
export default class bwc_galleryImage extends LightningElement {
    static renderMode = 'light';
    /**
     * @description An event fired when an image is selected by the user.
     *
     * Properties:
     *   - Bubbles: false
     *   - Cancelable: false
     *   - Composed: false
     *
     * @event GalleryImage#selected
     * @type {CustomEvent}
     *
     * @export
     */

    /**
     * @description Gets or sets whether the image is selectable by the user.
     *
     * A selectable image will emit the {@see GalleryImage#selected} event when the user selects it,
     * e.g. via keyboard (enter) or mouse (click) interaction.
     *
     * @type {Boolean}
     */
    @api
    selectable = false;

    /**
     * @description Gets or sets the URL of the displayed image.
     *
     * @type {string}
     */
    @api
    url;

    /**
     * @description Gets or sets the alternative text of the displayed image.
     *
     * @type {string}
     */
    @api
    alternativeText;

    @api
    imageSizes;

    @api
    loading; // 'lazy' | 'eager';

    /**
     * @description Sets the 'aria-labelledby' attribute on the figure element with the provided id
     *
     * @type {string}
     */
    @api
    setAriaLabelledByOnFigureElement(idValue) {
        this.figureElement?.setAttribute('aria-labelledby', idValue);
    }

    /**
     * @description Sets the 'role' attribute on the figure element with the provided role value
     *
     * @type {string}
     */
    @api
    setRoleOnFigureElement(roleValue) {
        if (!this.figureElement?.hasAttribute('role')) {
            this.figureElement?.setAttribute('role', roleValue);
        }
    }

    /**
     * @description Get a reference to the 'figure' element of the component
     *
     * @type {object}
     */
    get figureElement() {
        return this.querySelector('figure');
    }

    get images() {
        return this.imageSizes && this.resolvedUrl ? createImageDataMap(this.resolvedUrl, this.imageSizes, [1, 2]) : [];
    }

    /**
     * @description Gets the resolved image URL.
     *
     * @type {string}
     * @readonly
     * @private
     */
    get resolvedUrl() {
        return this.url ? resolve(this.url) : '';
    }

    /**
     * @description Fires an event to update the standard image
     *
     * @private
     * @fires GalleryImage#selected
     */
    handleImageClicked() {
        // Bubble up the event to the parent.
        const event = new CustomEvent('selected', {
            bubbles: false,
            cancelable: false,
            composed: false,
        });
        this.dispatchEvent(event);
    }
}