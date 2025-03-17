/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        17.05.2021
 * @description    Class with reusable methods to help with common tasks
 * @testClass      CX_UtilsTest
 */
public with sharing class CX_Utils {

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        19.05.2021
     * @description    Overload with 2 parameters for the handleExceptionMessage method
     * @param          Exception - An Exception
     * @param          String - A default message in case no treatment works
     * @return         String - A treated error message
     */
    public static String handleExceptionMessage(Exception ex, String defaultMessage) {
        return handleExceptionMessage(ex, defaultMessage, false);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        19.05.2021
     * @description    Handles a exception and returns a treated error message, can log the error
     * @param          Exception - An Exception
     * @param          String - A default message in case no treatment works
     * @param          Boolean - Should the error be logged?
     * @return         String - A treated error message
     */
    public static String handleExceptionMessage(Exception ex, String defaultMessage, Boolean shouldLog) {
		defaultMessage = String.isNotBlank(defaultMessage) ? defaultMessage : 'An error ocurred, try again or contact your administrator!';

		String message = ex.getMessage();

		if (message.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
			String treatedMessage = message.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': [');
			message = treatedMessage == null ? defaultMessage : treatedMessage;
		} else if(message.contains('CUSTOM_ERROR')) {
            String treatedMessage = message.substringAfter('CUSTOM_ERROR: ');
			message = treatedMessage == null ? defaultMessage : treatedMessage;
        } else {
			message = defaultMessage;
		}

		System.debug('message: ' + ex.getMessage());
		System.debug('Stacktrace: ' + ex.getStackTraceString());

        if(shouldLog) {
            CX_Logger logger = new CX_Logger(CX_Logger.LogMode.MODE_PLATFORM_EVENT);
            logger.logError(ex, 'CX_Utils', 'handleExceptionMessage');
        }

		return message;
	}

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        19.05.2021
     * @description    Transforms an Exception in an AuraHandledException and throws it (intended for Aura or LWC components)
     * @param          Exception - An Exception
     * @param          String - A default message in case no treatment works
     */
    public static void throwHandledException(Exception ex, String defaultMessage) {
        String message = handleExceptionMessage(ex, defaultMessage, true);
        AuraHandledException auraException = new AuraHandledException(message);
		auraException.setMessage(message);
		throw auraException;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        26.05.2021
     * @description    Removes everything that is not a number
     * @param          Set<String> - A set of formatted strings
     * @return         Set<String> - A set of number only strings
     */
    public static Set<String> removeNumberFormatting(Set<String> values) {
        Set<String> numberValues = new Set<String>();

		for(String value : values) {
            numberValues.add(removeNumberFormatting(value));
        }

        return numberValues;
	}

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        25.05.2021
     * @description    Removes everything that is not a number
     * @param          String - Formatted number
     * @return          String - A number only string
     */
    public static String removeNumberFormatting(String value){
		return value?.replaceAll('[^0-9]', '');
	}

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        31.05.2021
     * @description    Check if current environment is a sandbox
     * @return         Boolean - is the org a sandbox?
     */
    public static Boolean isSandbox() {
		return [SELECT IsSandbox FROM Organization LIMIT 1].isSandbox;
	}

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        11.06.2021
     * @description    Check if a field changed (also true if it's a new record)
     * @param          SObject - The record
     * @param          Schema.SObjectField - The field to be checked
     * @return         Boolean - was the field updated?
     */
    public static Boolean isChanged(SObject record, Schema.SObjectField field) {
		return (Trigger.isInsert || record.get(field) != Trigger.OldMap.get(record.Id).get(field));
	}

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        22.06.2021
     * @description    Returns an string in which the first letter of each word is capitalized
     * @param          String - The string
     * @return         String - The formatted string
     */
    public static String capitalizeInitialLetter(String inputString) {
        List<String> strings = inputString.split(' ');

        String response = '';

        for (String word : strings) {
            response += word.substring(0,1).toUpperCase() + word.substring(1,word.length()) + ' ';
        }

        return response.trim();
    }
}