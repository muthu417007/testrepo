import { api, track, LightningElement, wire } from 'lwc';
import { resolve } from 'experience/resourceResolver';
import { lightBoxImageNoAssistiveText, lightBoxImageAssistiveText } from './labels';
import { MEDIA_QUERIES } from 'experience/picture';

import productImageGalleryModal from 'c/bwc_productImageGalleryModal';

import { subscribe, unsubscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import HARDWARE_SELECTED_CHANNEL from '@salesforce/messageChannel/BWC_HardwareSelected__c';

const defaultEmptyObject = Object.create(null);

// Vertical carousel position values.
const verticalCarouselPositions = new Set(['after', 'before']);

// Valid carousel position settings.
const validCarouselPositions = new Set(['above', 'after', 'before', 'below']);

const IMAGE_SIZE_HORIZONTAL_SCROLLER = {
    mobile: 200,
    tablet: 100,
    desktop: 100,
};
const IMAGE_SIZE_GALLERY = {
    mobile: 200,
    tablet: 400,
    desktop: 400,
};

/**
 * @description A responsive image gallery designed for product images, showcasing a selected image accompanied by additional thumbnail images.
 *
 * This component automatically changes its representation and functionality depending upon the form factor in which it's displayed.
 * In the narrow form factor, thumbnail images are replaced by generic dots.
 */
export default class bwc_productImageGallery extends LightningElement {
    static renderMode = 'light';

    showModal() {
        productImageGalleryModal.open({
            label: '',
            url: this.url,
            size: 'small',
            isMobile: this.isMobile,
            thumbnailImages: this.thumbnailImages,
            carouselOrientation: this.carouselOrientation,
            carouselPageSize: this.carouselPageSize,
            selectedImageIndex: this.selectedImageIndex,
            showCarouselMobile: this.showCarouselMobile,
            showCarouselDesktop: this.showCarouselDesktop,
            images: this.images,
            imageResolvedAlternativeText: this.imageResolvedAlternativeText
        })
    }

    // Private storage for carouselImages.
    @track
    _images;

    /**
     * @description Gets or sets the 0-based index of the displayed image.
     *
     * @type {number | undefined}
     * @private
     */
    selectedImageIndex;

    /**
     * @description Gets or sets the no. of images to display in the carousel
     *
     * @type {number}
     */
    @api
    carouselPageSize = 1;

    /**
     * @description The position of the image carousel - when shown - in relation to the showcased image.
     * Accepted values are:
     *  - "above": the carousel appears before the showcased image, as defined by the normal column flow direction of the user (e.g. top).
     *  - "after": the carousel appears after the showcased image, as defined by the normal flow direction of the user (e.g. right).
     *  - "before": the carousel appears before the showcased image, as defined by the normal flow direction of the user (e.g. left).
     *  - "below": the carousel appears after the showcased image, as defined by the normal column flow direction of the user (e.g. under).
     *
     * If no value is specified or an invalid option is provided, the default position of "below" is used.
     *
     * @type {string}
     */
    @api
    carouselPosition;

    /**
     * @description Whether to show an expanded version of the featured image (e.g. in a lightbox) when it is selected.
     *
     * @type {Boolean}
     */
    @api
    expandable = false;

    /**
     * @description Whether to show the image carousel
     *
     * @type {Boolean}
     */
    @api
    showCarousel = false;

    /**
     * @description Gets the orientation for the carousel.
     *
     * @type {string}
     * @readonly
     * @private
     */
    get carouselOrientation() {
        return verticalCarouselPositions.has(this.carouselPosition) ? 'vertical' : 'horizontal';
    }

    /**
     * @description The classes for the carousel position.
     *
     * @type {string}
     * @private
     */
    get carouselPositionClasses() {
        const carouselPosition = validCarouselPositions.has(this.carouselPosition)
            ? this.carouselPosition
            : 'below';
        return `images carousel-${carouselPosition}`;
    }

    /**
     * @description Gets or sets the images to display in the gallery.
     *
     * @type {ProductImage[]}
     */
    @api
    get images() {
        return this._images;
    }

    set images(images) {
        // Store the images and set the first image - if any - as displayed.
        this._images = images;
        this.selectedImageIndex = Array.isArray(images) && images.length > 0 ? 0 : undefined;
    }

    /**
     * @description Gets the normalized sequence of images.
     *
     * @type {ProductImage[]}
     * @readonly
     * @private
     */
    get normalizedImages() {
        return this.images || [];
    }

    /**
     * @description Gets the image selected for display, if any.
     *
     * @type {ProductImage}
     * @private
     */
    get selectedImage() {
        return this.normalizedImages[this.selectedImageIndex || 0];
    }

    /**
     * @description Gets whether there are multiple images to display.
     *
     * @type {boolean}
     * @readonly
     * @private
     */
    get hasMultipleImages() {
        return this.normalizedImages.length > 1;
    }

    /**
     * @description Gets the URI of the displayed image.
     *
     * @type {string}
     *
     * @readonly
     * @private
     */
    get url() {
        if (this._url && this.selectedImageIndex === 0) {
            return this._url;
        }
        return this.selectedImage?.fullUrl ?? undefined;
    }

    /**
     * @description Gets the url of the displayed image
     *
     * This URL is the full-size image, without any scaling parameters
     *
     * @type {string}
     *
     * @readonly
     * @private
     */
    get imageUrl() {
        return this.url ? resolve(this.url) : undefined;
    }

    get galleryImageSizes() {
        return IMAGE_SIZE_GALLERY;
    }

    get horizontalScrollerImageSizes() {
        return IMAGE_SIZE_HORIZONTAL_SCROLLER;
    }

    get isMobile() {
        return !!window?.matchMedia(MEDIA_QUERIES.mobile).matches;
    }

    get showCarouselMobile() {
        return this.showCarousel && this.isMobile;
    }

    get showCarouselDesktop() {
        return this.showCarousel && !this.isMobile;
    }

    /**
     * @description Gets the alternative text to apply to the product image.
     *
     * @type {string}
     *
     * @readonly
     * @private
     */
    get imageResolvedAlternativeText() {
        // If the expandable / lightbox support is disabled, simply show the normal alternative text.
        // Otherwise, the alternative text needs to indicate it's clickable.
        const selectedImage = this.selectedImage || defaultEmptyObject;
        if (!this.expandable) {
            return selectedImage.alternativeText || '';
        }

        // Default to the "no assistive text provided" assistive text.
        const alternativeText = lightBoxImageNoAssistiveText;
        const imageAlternativeText = selectedImage.alternativeText || '';

        // If the selected image has alternative text, use that (with our "Click to Expand" bit added).
        if (imageAlternativeText.length > 0) {
            return lightBoxImageAssistiveText.replace('{0}', imageAlternativeText);
        }
        return alternativeText;
    }

    /**
     * @description Gets the alternative text to apply to the lightbox product image.
     *
     * @type {string}
     *
     * @readonly
     * @private
     */
    get lightboxImageAlternativeText() {
        // For the lightbox, we display the unaltered alternative text.
        return this.selectedImage?.alternativeText || '';
    }

    /**
     * @description Gets the thumbnail images information to apply to the desktop image carousel control.
     *
     * @type {ThumbnailImage}
     *
     * @readonly
     * @private
     */
    get thumbnailImages() {
        return this.normalizedImages.map((item) => {
            return {
                alternativeText: item.alternativeText
                    ? lightBoxImageAssistiveText.replace('{0}', item.alternativeText)
                    : lightBoxImageNoAssistiveText,
                id: item.id,
                url: item.smallUrl,
            };
        });
    }

    /**
     * @description Gets the number of images available for display.
     *
     * @returns {number}
     *
     * @readonly
     * @private
     */
    get numberOfImages() {
        return this.normalizedImages.length;
    }

    @wire(MessageContext)
    messageContext;

    subscription;

    connectedCallback() {
        this.subscription =
            subscribe(
                this.messageContext,
                HARDWARE_SELECTED_CHANNEL,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
    }

    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    _url;

    handleMessage(data) {
        this._url = data.imageUrl;
        this.selectedImageIndex = 0;
    }

    /**
     * @description Handles a click of a product image, which should show a larger version in a lightbox.
     *
     * @private
     */
    handleImageClicked() {
        // let modal = this.querySelector('#productImageModal');
        // let span = this.querySelector("span.close");
        // modal.style.display = "block";
        // span.onclick = () => {modal.style.display = 'none'};
        // window.onclick = (e) => {
        //     if (e.target === modal) {
        //         modal.style.display = 'none';
        //     }
        // };

        this.isShowLightbox = true;
    }

    /**
     * @description Handles a click of a thumbnail image,
     * which should show a larger version of the product image.
     *
     * @private
     */
    handleThumbnailImageSelected(event) {
        // Update the selected image ID using the new selected image index.
        this.selectedImageIndex = event.target.selectedIndex;
    }

    /**
     * @description Displays the next image in the collection.
     *
     * @private
     */
    showNextImage() {
        this.selectedImageIndex = (Number(this.selectedImageIndex) + 1) % this.normalizedImages.length;
    }

    /**
     * @description Displays the previous image in the collection.
     *
     * @private
     */
    showPreviousImage() {
        const nextIndex = Number(this.selectedImageIndex) - 1;
        this.selectedImageIndex = nextIndex < 0 ? this.normalizedImages.length - 1 : nextIndex;
    }

    /**
     * @description Whenever a carousel is associated with the gallery, we need to set a couple of attributes
     * on the gallery-image component.
     *  1. role="tabpanel"
     *  2. aria-labelledby="id-of-the-currently-selected-image"
     *
     * @private
     */
    handleCarouselDisplayed(event) {
        const { selectedImageId } = event.detail;
        const galleryImage = this.querySelector('c-bwc_gallery-image');
        galleryImage?.setAriaLabelledByOnFigureElement(selectedImageId);
        galleryImage?.setRoleOnFigureElement('tabpanel');
    }
}