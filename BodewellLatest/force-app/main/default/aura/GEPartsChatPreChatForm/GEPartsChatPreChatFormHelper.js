({
	

	/**
	 * Event which fires the function to start a chat request (by accessing the chat API component)
	 *
	 * @param cmp - The component for this state.
	 */
	onStartButtonClick: function(component, event, helper) {
	
        console.log("HERE2");
        // Make an array of field objects for the library
        var fields = this.createFieldsArray(component); //build array custom instead
        console.log("HERE3");
        // If the pre-chat fields pass validation, start a chat
       if(component.find("prechatAPI").validateFields(fields).valid) {
        console.log("HERE4");
            component.find("prechatAPI").startChat(fields);
        console.log("HERE5");
       } else {
           console.warn("Prechat fields did not pass validation!");
       } 
	},

	/**
	 * Create an array of field objects to start a chat from an array of pre-chat fields
	 * 
	 * @param fields - 
	 * @returns An array of field objects.
	    <aura:attribute name="FirstNameAttr" type="String" description=""/> 
		<aura:attribute name="LastNameAttr" type="String" description=""/> 
		<aura:attribute name="EmailAddressAttr" type="String" description=""/> 
		<aura:attribute name="QuestionAttr" type="String" description=""/> 
	 */
	createFieldsArray: function(component) {
        console.log("HERE2222");
		var fields = [{"type":"inputSplitName","name":"FirstName","label":"First Name","required":true,"readOnly":false,"className":"FirstName slds-style-inputtext","maxLength":121, "value":component.get('v.FirstNameAttr')},
		{"type":"inputSplitName","name":"LastName","label":"Last Name","required":true,"readOnly":false,"className":"LastName slds-style-inputtext","maxLength":121, "value":component.get('v.LastNameAttr')},
		{"type":"inputEmail","name":"Email","label":"Email","required":true,"readOnly":false,"className":"Email slds-style-inputtext","maxLength":80, "value":component.get('v.EmailAddressAttr')},
		{"type":"inputText","name":"Subject","label":"Subject","required":true,"readOnly":false,"className":"Subject slds-style-inputtext","maxLength":255, "value":component.get('v.QuestionAttr')}]

		/*
		{"type":"inputText","name":"Model_Number__c","label":"Model Number","required":false,"readOnly":false,"className":"Model_Number__c slds-style-inputtext","maxLength":60, "value":""},
		{"type":"inputText","name":"Serial_Number__c","label":"Serial Number","required":false,"readOnly":false,"className":"Serial_Number__c slds-style-inputtext","maxLength":60, "value":""},
		{"type":"inputText","name":"First_Name__c","label":"First Name","required":false,"readOnly":false,"className":"First_Name__c slds-style-inputtext","maxLength":255, "value":component.get('v.FirstNameAttr')},
		{"type":"inputText","name":"Last_Name__c","label":"Last Name","required":false,"readOnly":false,"className":"Last_Name__c slds-style-inputtext","maxLength":255, "value":component.get('v.LastNameAttr')},*/

        console.log("HERE2222");
		console.log("fields - " + JSON.stringify(fields));
		return fields;
	},
})