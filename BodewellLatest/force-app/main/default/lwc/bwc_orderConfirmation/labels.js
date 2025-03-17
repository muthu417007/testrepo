import orderMessageText from '@salesforce/label/c.BWC_OrderConfirmation_OrderMessageText';
import emailMessageText from '@salesforce/label/c.BWC_OrderConfirmation_EmailMessageText';

/**
 * Internationalization labels.
 */
export const Labels = {
    /**
     * A label of the form "Your order {{orderNumber}} has been placed.".
     * @type {string}
     */
    orderMessageText: x => orderMessageText.replace('{{orderNumber}}', x),
    /**
     * A label of the form "We sent an email to {{email}} containing information about your order".
     * @type {string}
     */
    emailMessageText: x => emailMessageText.replace('{{email}}', x)
};