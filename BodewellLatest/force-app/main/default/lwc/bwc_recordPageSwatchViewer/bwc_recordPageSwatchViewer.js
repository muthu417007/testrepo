import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
const fields = [
    'Product2.bwc_SwatchConfig__c',
    'Product2.bwc_CustomHardwareConfig__c'
];
/**
 * @description Component that can be used to display the Swatch Colors and Custom Hardware
 * colors on a product page in the Commerce App.
 */
export default class bwc_recordPageSwatchViewer extends LightningElement {
    @api
    recordId;

    swatchConfig;
    customHardwareConfig;

    selectedColorValue;
    selectedHardwareValue;

    @wire(getRecord, {
        recordId: '$recordId',
        fields
    })
    wiredGetRecord({ error, data }) {
        if (data) {
            try {
                if (data.fields.bwc_SwatchConfig__c.value) {
                    this.swatchConfig = JSON.parse(data.fields.bwc_SwatchConfig__c.value);
                    this.selectedColorValue = Object.keys(this.swatchConfig.color)[1];
                }
                if (data.fields.bwc_CustomHardwareConfig__c.value) {
                    let hardwareConfig = JSON.parse(data.fields.bwc_CustomHardwareConfig__c.value);
                    this.customHardwareConfig = hardwareConfig['Custom Hardware'];
                    this.selectedHardwareValue = Object.keys(this.customHardwareConfig)[1];
                }
            } catch(e) {
                console.log(`error: ${e}`);
            }
        } else if (error) {
            console.log(`bwc_recordPageSwatchViewer::wiredGetRecord::error: ${error}`);
        }
    }

    get hasSwatchConfig() {
        return !!this.swatchConfig;
    }

    get hasCustomHardwareConfig() {
        return !!this.customHardwareConfig;
    }

    get hasNeitherSwatchConfigNorCustomHardware() {
        return !this.hasSwatchConfig && !this.hasCustomHardwareConfig;
    }

    get numSwatches() {
        return 6;
    }

    get colorOptions() {
        try {
            if (this.hasSwatchConfig) {
                return Object.keys(this.swatchConfig.color)
                    .filter(color => color != 'sku')
                    .map(colorName => {
                        return {
                            label: colorName,
                            value: colorName,
                            selected: false,
                            disabled: false,
                            url: this.swatchConfig.color[colorName]
                        }
                    });
            }
            return [];
        } catch(e) {
            console.log(`bwc_recordPageSwatchViewer::colorOptions::error =${e}`);
        }
    }

    get customHardwareOptions() {
        try {
            if (this.hasCustomHardwareConfig && this.customHardwareConfig && this.selectedColorValue) {
                return Object.keys(this.customHardwareConfig)
                    .filter(color => color != 'sku')
                    .map(colorName => {
                        return {
                            label: colorName,
                            value: colorName,
                            selected: false,
                            disabled: false,
                            url: this.customHardwareConfig[colorName].swatchImageUrl
                        }
                    });
            }
            return [];
        } catch(e) {
            console.log(`bwc_recordPageSwatchViewer::customHardwareOptions::error = ${e}`);
        }
    }

    handleChange(e) {
        this.selectedColorValue = e.detail;
    }

    handleHardwareChange(e) {
        this.selectedHardwareValue = e.detail;
    }
}