({
    doInit : function(component, event, helper) 
    {
        if(component.get("v.contactId")!=null && component.get("v.contactId")!='')
        {
			helper.getContact(component, event, helper);
        }
    },
    
	handlesubmitClick : function(component, event, helper) 
    {   
        //helper.secureacceptanceSign(component, event, helper);
        helper.postRequest(component, event, helper);
        //var url = 'https://secureacceptance.cybersource.com/pay';
        
        /*var urlParams = encodeURIComponent('bill_to_forename') + '=' + encodeURIComponent(component.get("v.firstName"));
        // TODO: AccessKey and profileId will need to be stored in custom settings or custom metadata
        urlParams += '&' + encodeURIComponent('access_key') + '=' + encodeURIComponent('5fbd0821869a3384982a47c45c1ce8a3');
        urlParams += '&' + encodeURIComponent('profile_id') + '=' + encodeURIComponent('1691B5CA-B0A1-4C96-AD77-457F4B7F5F05');
        urlParams += '&' + encodeURIComponent('bill_to_surname') + '=' + encodeURIComponent(component.get("v.lastName"));
        // Replace space with +
        // + in the value indicates space 
        var streetForURL = component.get("v.street");
        if(component.get("v.street")!=null && component.get("v.street")!='')
        {
            streetForURL = component.get("v.street").replace(" ", "+");
        }
        urlParams += '&' + encodeURIComponent('bill_to_address_line1') + '=' + encodeURIComponent(streetForURL);
        urlParams += '&' + encodeURIComponent('bill_to_address_city') + '=' + encodeURIComponent(component.get("v.city"));
        urlParams += '&' + encodeURIComponent('bill_to_address_state') + '=' + encodeURIComponent(component.get("v.state"));
        urlParams += '&' + encodeURIComponent('bill_to_address_postal_code') + '=' + encodeURIComponent(component.get("v.zipcode"));
        urlParams += '&' + encodeURIComponent('bill_to_address_country') + '=' + encodeURIComponent('US');
        urlParams += '&' + encodeURIComponent('amount') + '=' + encodeURIComponent(component.get("v.paymentAmount"));
        urlParams += '&' + encodeURIComponent('currency') + '=' + encodeURIComponent('USD');
        urlParams += '&' + encodeURIComponent('locale') + '=' + encodeURIComponent('en');
        urlParams += '&' + encodeURIComponent('transaction_type') + '=' + encodeURIComponent('sale,create_payment_token');
        //urlParams += '&override_custom_receipt_page=https://geappliances.custhelp.com/app/Cybersource_Response';
        urlParams += '&' + encodeURIComponent('signed_field_names') + '=' + encodeURIComponent('bill_to_forename,access_key,profile_id,bill_to_surname,bill_to_address_line1,bill_to_address_city,bill_to_address_state,bill_to_address_postal_code,bill_to_address_country,amount,currency,locale,transaction_type');
        */
        
        /*var urlParams = 'bill_to_forename=' + component.get("v.firstName");
        // TODO: AccessKey and profileId will need to be stored in custom settings or custom metadata
        urlParams += '&access_key=5fbd0821869a3384982a47c45c1ce8a3';
        urlParams += '&profile_id=1691B5CA-B0A1-4C96-AD77-457F4B7F5F05';
        urlParams += '&bill_to_surname=' + component.get("v.lastName");
        // Replace space with +
        // + in the value indicates space 
        var streetForURL = component.get("v.street");
        if(component.get("v.street")!=null && component.get("v.street")!='')
        {
            streetForURL = component.get("v.street").replace(" ", "+");
        }
        urlParams += '&bill_to_address_line1=' + streetForURL;
        urlParams += '&bill_to_address_city='+encodeURIComponent(component.get("v.city"));
        urlParams += '&bill_to_address_state='+encodeURIComponent(component.get("v.state"));
        urlParams += '&bill_to_address_postal_code='+encodeURIComponent(component.get("v.zipcode"));
        urlParams += '&bill_to_address_country='+encodeURIComponent('US');
        urlParams += '&amount='+encodeURIComponent(component.get("v.paymentAmount"));
        urlParams += '&currency='+encodeURIComponent('USD');
        urlParams += '&locale='+encodeURIComponent('en');
        urlParams += '&transaction_type='+encodeURIComponent('sale,create_payment_token');
        //urlParams += '&override_custom_receipt_page=https://geappliances.custhelp.com/app/Cybersource_Response';
        urlParams += '&signed_field_names='+encodeURIComponent('bill_to_forename,access_key,profile_id,bill_to_surname,bill_to_address_line1,bill_to_address_city,bill_to_address_state,bill_to_address_postal_code,bill_to_address_country,amount,currency,locale,transaction_type');
        */
        
        /*var xhr = new XMLHttpRequest();
		xhr.open("POST", url, true);
		xhr.setRequestHeader('Content-Type', 'application/json');
		xhr.send(JSON.stringify({
    		bill_to_forename : component.get("v.firstName")
		}));*/
        
        //var urlParamsEncoded = encodeURI(urlParams);
        //url += urlParamsEncoded;
        //url += urlParams;
        //console.log(url);
        //window.open(url,'_top');
    }
})