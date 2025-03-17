import { api } from 'lwc';
import LightningModal from 'lightning/modal';

/**
 * @description provides a modal window for the productImageGallery feature
 */
export default class bwc_productImageGalleryModal extends LightningModal {

    @api url;
    @api imageResolvedAlternativeText;
    @api thumbnailImages;
    @api carouselOrientation;
    @api carouselPageSize;
    @api selectedImageIndex;
    @api showCarouselMobile;
    @api showCarouselDesktop;
    @api images;

    handleThumbnailImageSelected(event) {
        this.url = this.images[event.target.selectedIndex].fullUrl;
    }
}