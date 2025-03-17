import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/**
 * A method dispatches a show toast event
 * @param {component} component - An instance of the component that should show the toast
 * @param {string} title - Toast's title
 * @param {string} message - Toast's title
 * @param {string} variant - Which type of toast to be shown (success, warning, error, etc.)
 * @param {string} mode - An optional toast's behavior (sticky, pester or dismissable)
 */
export const showToast = (component, title, message, variant, mode = 'dismissable') => {
	const evt = new ShowToastEvent({
        title: title,
        message: message,
		variant: variant,
		mode: mode
    });
    component.dispatchEvent(evt);
}

/**
 * A method that handles an error and calls the showToast method with a user friendly message
 * @param {component} component - An instance of the component that should show the toast
 * @param {object|array|string} error - The exception object, array or string
 */
export const handleError = (component, error, mode = 'dismissable') => {
    let errorMessage = typeof error === "string" ? error : error.message;
    
    if(!errorMessage) {
        errorMessage = error.body != null ? error.body.message : 'An error occurred, try again or contact your administrator!';
    }

    if(Array.isArray(errorMessage) && errorMessage[0].message) {
        errorMessage = errorMessage[0].message;
    }

	showToast(component, 'Error', errorMessage, 'error', mode);
	console.log('Error: ' + errorMessage);
}

/**
 * A method that gets a Date instance and returns it as a string that SF recognizes
 * @param {Date} date - A date instance
 * @return {string} - A date string in the "YYYY-MM-DD" format (Salesforce Date type)
 */
export const formatDateToSalesforce = (date) => {
    return `${date.getFullYear()}-${date.getMonth()+1}-${date.getDate()}`;
}