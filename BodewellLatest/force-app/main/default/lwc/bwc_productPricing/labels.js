import strikethroughAssistiveText from '@salesforce/label/c.BWC_Product_Pricing_strikethroughAssistiveText';
import negotiatedStandardHardwarePriceText from '@salesforce/label/c.BWC_Product_Pricing_negotiatedStandardHardwarePriceText';
import negotiatedCustomHardwarePriceText from '@salesforce/label/c.BWC_Product_Pricing_negotiatedCustomHardwarePriceText';

export const Labels = {
    /**
     * @description Assistive text, required because screenreaders do not read out strikethrough styling - reads "(crossed out)"
     * @type {string}
     */
    strikethroughAssistiveText,
    /**
     * @description used for products with custom hardware
    */
    negotiatedCustomHardwarePriceText,
    negotiatedStandardHardwarePriceText
};