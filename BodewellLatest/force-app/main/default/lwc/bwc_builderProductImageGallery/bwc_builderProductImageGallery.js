import { api, LightningElement } from 'lwc';
import { transformMediaContents, transformMediaContentsTEMP, areExpandable } from './productGalleryUtils';

/**
 * @description This component is exposed to the Experience Builder and delegates to bwc_productImageGallery
 * for its functionality.  This component passes along all properties that are needed by bwc_productImageGallery.
 */
export default class  bwc_builderProductImageGallery extends LightningElement {
    static renderMode = 'light';

    /**
     * @description Gets or sets the number of images displayed at a time (i.e. per page) when pagination is enabled.
     *
     * @type {number}
     */
    @api
    carouselPageSize;

    /**
     * @description Gets or sets the image border color for product gallery component.
     * @type {string}
     */
    @api imageBorderColor;

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
     * @description Whether or not to show the image carousel
     *
     * @type {Boolean}
     */
    @api
    showCarousel = false;

    /**
     * @description Sets the custom background color and custom CSS properties for the product gallery component.
     * @returns {string}
     * The css style overwrites for the product gallery component component.
     */
    get productGalleryCustomStyles() {
        return `--com-carousel-image-border-color: ${this.imageBorderColor || 'initial'};`;
    }

    /**
     * @description Gets or sets the images to display in the gallery.
     *
     * @type {Image[]}
     */
    get images() {
        const prodUrls = this.product.fields.BWC_Product_Detail_Images__c;
        const media = prodUrls.split("~");
        return transformMediaContentsTEMP(media);
        // const mediaGroups = this.product?.mediaGroups;
        // return transformMediaContents(mediaGroups);
    }


    get isImageGalleryExpandable() {
        return areExpandable(this.images);
    }

    @api
    product;

    /**
     * Should render gallery component only if mediaGroups is available.
     *
     * @returns { boolean }
     */
    get displayGallery() {
        return !!this.product?.mediaGroups && this.product?.mediaGroups.length > 0;
    }

    renderedCallback() {
        this.classList.toggle('slds-hide', !this.displayGallery);
    }
}