import { api, LightningElement } from 'lwc';
import { previousImageButtonAlternativeText, nextImageButtonAlternativeText } from './labels';
import { createImageDataMap } from 'experience/picture';

const IMAGE_SIZES = {
    mobile: 40,
    tablet: 60,
    desktop: 60,
};

/**
 * @description An image carousel supporting horizontal and vertical orientation.
 *
 * @fires Carousel#selectionchanged
 * @fires Carousel#carouseldisplayed
 */
export default class bwc_carousel extends LightningElement {
    static renderMode = 'light';
    /**
     * @description An event fired when the user selects a new image.
     *
     * Properties:
     *   - Bubbles: false
     *   - Cancelable: false
     *   - Composed: false
     *
     * @event Carousel#selectionchanged
     * @type {CustomEvent}
     *
     * @export
     */

    /**
     * @description An event fired when the carousel is rendered
     *
     * Properties:
     *   - Bubbles: false
     *   - Cancelable: false
     *   - Composed: false
     *
     * @event Carousel#carouseldisplayed
     * @type {CustomEvent}
     *
     * @export
     */

    /**
     * @description Gets or sets the sequence of images displayed.
     * @type {ThumbnailImage[]}
     */
    @api
    images;

    /**
     * @description The orientation of the carousel.
     * Accepted values are: "horizontal" and "vertical"
     *
     * If no value is provided or an invalid value is specified, the default orientation is "horizontal".
     *
     * @type {string}
     */
    @api
    orientation; // 'horizontal' | 'vertical';

    /**
     * @description Gets or sets the number of images displayed at a time (i.e. per page) when pagination is enabled.
     * @type {number}
     */
    @api
    pageSize = 1;

    /**
     * @description Gets or sets whether pagination is enabled.
     *
     * When enabled, a fixed number of images (controlled by the pageSize property) is displayed at a given time with "next" and "previous" pagination controls displayed.
     * When disabled, all images are displayed and no pagination controls are present.
     *
     * @memberof Carousel
     */
    @api
    paginate = false;

    /**
     * @description Private storage for the (0-based) index of the image that appears selected.
     *
     * @type {number | undefined}
     */
    _selectedIndex;

    /**
     * @description Gets or sets the index (0-based) of the image that appears selected.
     *
     * The value of this property differ from an assigned value as it is updated
     * to reflect the index of the image selected via user interaction.
     *
     * @type {number}
     */
    @api
    get selectedIndex() {
        return this._selectedIndex;
    }

    set selectedIndex(newIndex) {
        this._selectedIndex = newIndex;
    }

    /**
     * @description Whether to focus on the "next" button when the component DOM is next updated.
     *
     * @type {boolean}
     * @private
     */
    _focusOnNextButton = false;

    /**
     * @description Whether to focus on the "previous" button when the component DOM is next updated.
     *
     * @type {boolean}
     * @private
     */
    _focusOnPreviousButton = false;

    /**
     * @description LWC property change callback.
     */
    renderedCallback() {
        const selectedCarouselImage = this.querySelectorAll('button')[this._selectedIndex || 0];
        const selectedImageId = selectedCarouselImage ? selectedCarouselImage.getAttribute('id') : '';
        // A bit of accessibility juggling to move focus to the "next" or "previous" buttons after changing pages,
        // which causes us to update the "disabled" state of those buttons.
        if (this._focusOnNextButton) {
            this._focusOnNextButton = false;
            this.querySelector('lightning-button-icon:last-child').focus();
        }

        if (this._focusOnPreviousButton) {
            this._focusOnPreviousButton = false;
            this.querySelector('lightning-button-icon:first-child').focus();
        }

        // Fire the 'carouseldisplayed' event with the currently selected image's id
        // This is useful to set accessibilty related attributes on sibling components
        // which may depend on the id of the currently selected image
        this.dispatchEvent(
            new CustomEvent('carouseldisplayed', {
                bubbles: false,
                cancelable: false,
                composed: false,
                detail: { selectedImageId },
            })
        );
    }

    /**
     * @description Gets whether the carousel is oriented vertically.
     *
     * @type {boolean}
     * @readonly
     * @private
     */
    get isVerticalOrientation() {
        return this.orientation === 'vertical';
    }

    /**
     * @description The classes for the slideshow position.
     *
     * @type {string}
     * @private
     */
    get orientationClass() {
        const classes = ['carousel'];
        if (this.isVerticalOrientation) {
            classes.push('thumbnail-left');
        }
        return classes.join(' ');
    }

    /**
     * @description The direction of the chevron that appears first in the carousel.
     *
     * @type {string}
     * @private
     */
    get prevChevronDirection() {
        return !this.isVerticalOrientation ? 'utility:chevronleft' : 'utility:chevronup';
    }

    /**
     * @description The direction of the chevron that appears last in the carousel.
     *
     * @type {string}
     * @private
     */
    get nextChevronDirection() {
        return !this.isVerticalOrientation ? 'utility:chevronright' : 'utility:chevrondown';
    }

    /**
     * @description Gets or sets the first displayed image index
     * based of 'firstDisplayedImageIndex' configuration
     * @type {number}
     * @private
     */
    firstDisplayedImageIndex = 0;

    /**
     * @description Gets whether the image carousel should display the content
     * based of 'thumbnailImages' configuration
     * @type {ThumbnailImage[]}
     */
    get displayedThumbnailImages() {
        return (this.images || []).reduce(
            (
                acc,
                image,
                index
            ) => {
                if (
                    !this.paginate ||
                    (index >= this.firstDisplayedImageIndex && index < this.firstDisplayedImageIndex + this.pageSize)
                ) {
                    acc.push({
                        id: null,
                        alternativeText: image.alternativeText,
                        index,
                        isSelected: index === this._selectedIndex ? 'true' : 'false',
                        url: image.url,
                        images: image.url ? createImageDataMap(image.url, IMAGE_SIZES, [1, 2]) : [],
                    });
                }
                return acc;
            },
            []
        );
    }

    /**
     * @description Gets whether to disable the previous button
     * @type {Boolean}
     * @readonly
     * @private
     */
    get disablePrevButton() {
        return this.firstDisplayedImageIndex < this.pageSize;
    }

    /**
     * @description Gets whether to disable the next button
     * @type {Boolean}
     * @readonly
     * @private
     */
    get disableNextButton() {
        const displayedthumbnailImages = this.images || [];
        return displayedthumbnailImages.length <= this.firstDisplayedImageIndex + this.pageSize;
    }

    /**
     * @description Gets the alternative text for the previous button.
     * @type {string}
     * @readonly
     * @private
     */
    get prevButtonAltText() {
        return previousImageButtonAlternativeText;
    }

    /**
     * @description Gets the alternative text for the next button.
     * @type {string}
     * @readonly
     * @private
     */
    get nextButtonAltText() {
        return nextImageButtonAlternativeText;
    }

    /**
     * @description Handles a click of a next button,
     * which should show the next set of media thumbnailImages.
     * @private
     */
    handleNextButtonClick() {
        const newIndex = this.firstDisplayedImageIndex + this.pageSize;
        const resolvedIndex = Math.min(Math.max(0, newIndex), (this.images).length - 1);
        this.firstDisplayedImageIndex = resolvedIndex;

        // Focus on the previous button since we're moving to the next page.
        this._focusOnPreviousButton = true;
    }

    /**
     * @description Handles a click of a previous button,
     * which should show the previous set of media thumbnailImages.
     * @private
     */
    handlePrevButtonClick() {
        const newIndex = this.firstDisplayedImageIndex - this.pageSize;
        const resolvedIndex = Math.min(Math.max(0, newIndex), (this.images).length - 1);
        this.firstDisplayedImageIndex = resolvedIndex;

        // Focus on the next button since we moved to the previous page.
        this._focusOnNextButton = true;
    }

    /**
     * @description Handles user selection of an image.
     *
     * @private
     * @fires Carousel#selectionchanged
     */
    handleImageSelected(event) {
        const newIndex = parseInt((event?.currentTarget)?.dataset?.index, 10);
        const hasChanged = this._selectedIndex !== newIndex;
        // If the selection has changed, update our state and fire the change event.
        if (hasChanged) {
            this._selectedIndex = newIndex;
            this.dispatchEvent(
                new CustomEvent('selectionchanged', {
                    bubbles: false,
                    cancelable: false,
                    composed: false,
                })
            );
        }
    }
}