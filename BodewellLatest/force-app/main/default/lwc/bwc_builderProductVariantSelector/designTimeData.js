/**
 * @typedef {{[key: string]: *}} JsonData
 */

/**
 * @returns {JsonData} Example variation information
 */
export function variationInfo() {
    return {
        variationAttributeInfo: {
            Size__c: {
                allowableValues: ['XL', 'L', 'M', 'S', 'XS'],
                apiName: 'Size__c',
                availableValues: ['L', 'S'],
                fieldEnumOrId: '00NR0000001qPsS',
                label: 'Example Size',
                objectName: 'ProductAttribute',
                sequence: 1,
            },
            Color__c: {
                allowableValues: [],
                apiName: 'Color__c',
                availableValues: null,
                fieldEnumOrId: '00NR0000001qPsY',
                label: 'Example Color',
                objectName: 'ProductAttribute',
                sequence: 2,
            },
        },
    };
}