/**
 * Transforms the Media Group Contents ( Standard Media Items ) into
 *
 * @param {ProductMediaGroupData[]} mediaGroups The specified product data (media groups)
 * @return {ProductImage[]} transformed media contents
 * @example
 * [
 *      {
 *       "alternativeText": 'xyz',
 *       "id": "2pmxx0000000001AAA",
 *       "fullUrl": "https://c.na139.content.force.com/servlet/servlet.ImageServer?id=0154W00000CxsIM&oid=00D4W0000054JBn",
 *       "smallUrl": "https://c.na139.content.force.com/servlet/servlet.ImageServer?id=0154W00000CxsIM&oid=00D4W0000054JBn"
 *      } 
 * ]
 */
export function transformMediaContents( mediaGroups ) {
    let transformedMediaGroups = [];
    // Transforms the API MediaGroup image listing into an
    // array of images for display in the image carousel
    if (mediaGroups && mediaGroups.length > 0) {
        // Filter the Standard Media Group Contents.
        const standardMediaGroupItems = mediaGroups.filter(function (group) {
            return group.usageType === 'Standard';
        });

        if (standardMediaGroupItems.length > 0) {
            // Transform the Standard Media Group contents data model, resolving the image URLs in case they're from CMS.
            transformedMediaGroups =
                standardMediaGroupItems[0].mediaItems?.map(function (item) {
                    return {
                        alternativeText: item.alternateText || item.title,
                        id: item.id,
                        fullUrl: item.url,
                        smallUrl: item.thumbnailUrl || item.url,
                    };
                }) || [];
        }
    }
    return transformedMediaGroups;
}

export function transformMediaContentsTEMP( media ) {
    let transformedMedia = [];
    
    if (media.length > 0) {
        transformedMedia =
            media.map(function (item) {
                // Update the PDP Salsify image size. The images loaded on the Product are 2000px or 3000px big
                // Updating the intrinisic size with string replace and adding width & height
                let full = '--/w_500,h_500/';
                // for alternate thumbs
                let small = '--/w_75,h_75/';
                let fullFormat = item.replace('--/', full);
                let smallFormat = item.replace('--/', small);

                return {
                    alternativeText: '',
                    id: '',
                    fullUrl: fullFormat,
                    smallUrl: smallFormat,
                };
            }) || [];
    }
    return transformedMedia;
}


/**
 * whether the image gallery is expandable (i.e. enables the lightbox).
 *
 * @type {boolean}
 * @readonly
 */
export function areExpandable(images) {
    // The images are expandable in the gallery as long as we don't have only the default image,
    // which has no ID property.
    return images != null && images.length > 0 && !(images.length === 1 && images[0].id === null);
}