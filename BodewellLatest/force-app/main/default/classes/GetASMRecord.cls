public Without sharing class GetASMRecord {
	@AuraEnabled
    public static User getASMRecordDetails(Id userId) {
        User[] u=[select contact.account.asm_name__r.id from User where id=:userId];
        if(u.size()>0){
            User[] uc=[ select id,firstname,lastname,name,phone,email from User where id= :u[0].contact.account.asm_name__r.id];
            if(uc.size()>0){
                return uc[0];
            }
            //system.debug('asmuser'+uc.name+uc.profile.name);
            return null;
		}
       return null;
    }
    
    @AuraEnabled
    public static String getAccountAndContactData(Id userId){
        //contact uc=[select contact.id from user where id=:userId];
        User[] userContact=[select contact.Id,contact.Name,contact.Title, contact.Phone, contact.Email from User where id=:userId];
        Contact[] userAccount=[select account.Id,account.Commercial__c,account.Residential_Replacement__c,account.Residential_New_Construction__c,account.MF_New_Construction__c,account.MF_Replacement__c,account.Distributor_Branch_Location__c,account.License_for_area_HVAC_plumbing_etc__c,account.zip_codes_they_service__c,account.Areas_of_focus__c,account.Public_Name__c,
                               account.Phone,account.Email__c,
                               account.Parts_of_program_you_are_interested_in__c,account.Other_details_about_your_Business__c,account.NumberOfEmployees,
                               account.Website,account.Will_GEA_be_replacing_with_any_Brand__c,
                               account.Doing_Business_As_DBA__c,account.Other_Brands_Currently_Selling__c,
                               account.Dealer_ID__c,account.Name,account.BillingStreet,account.BillingCity,
                               account.BillingCountry,account.BillingState,account.BillingPostalCode,
                               account.ShippingStreet,account.ShippingCity,account.ShippingState,
                               account.ShippingPostalcode,account.ShippingCountry,account.Estimated_Annual_Dealer_Volume__c,
                               account.BrandsCurrentlySellingmultipicklist__c,account.Products_Offered_Check_all_that_apply__c,
                               account.Dealer_Status__c from contact where id=:userContact[0].contact.Id];
        Map<Object, Object> userRecord = new Map<Object, Object>();
        if(userContact.size()>0){
            userRecord.put('contactTitle',userContact[0].contact.Title);
            userRecord.put('contactName',userContact[0].contact.Name);
            userRecord.put('contactEmail',userContact[0].contact.Email);
            userRecord.put('contactPhone',userContact[0].contact.Phone);        
        }
        if(userAccount.size()>0){
            userRecord.put('dealerVolume',userAccount[0].account.Estimated_Annual_Dealer_Volume__c);
            userRecord.put('shippingStreet',userAccount[0].account.shippingStreet);
            userRecord.put('shippingCity',userAccount[0].account.shippingCity);
            userRecord.put('shippingState',userAccount[0].account.shippingState);
            userRecord.put('shippingZipcode',userAccount[0].account.shippingPostalcode);
            userRecord.put('shippingCountry',userAccount[0].account.shippingCountry);
            userRecord.put('brands',userAccount[0].account.BrandsCurrentlySellingmultipicklist__c);
            userRecord.put('productsOffered',userAccount[0].account.Products_Offered_Check_all_that_apply__c);
            userRecord.put('billingStreet',userAccount[0].account.billingStreet);
            userRecord.put('billingCity',userAccount[0].account.billingCity);
            userRecord.put('billingState',userAccount[0].account.billingState);
        	userRecord.put('billingZipcode',userAccount[0].account.billingPostalCode);
            userRecord.put('billingCountry',userAccount[0].account.billingCountry);
            userRecord.put('accountName',userAccount[0].account.Name);
        	userRecord.put('accountDealerStatus',userAccount[0].account.Dealer_Status__c);
            userRecord.put('dealerId',userAccount[0].account.Dealer_ID__c);
            userRecord.put('otherBrands',userAccount[0].account.Other_Brands_Currently_Selling__c);
            userRecord.put('dealerName',userAccount[0].account.Doing_Business_As_DBA__c);
            userRecord.put('anyBrandsReplace',userAccount[0].account.Will_GEA_be_replacing_with_any_Brand__c);
            userRecord.put('website',userAccount[0].account.Website);
            userRecord.put('employees',userAccount[0].account.NumberOfEmployees);
            userRecord.put('otherDetails',userAccount[0].account.Other_details_about_your_Business__c);
            userRecord.put('partsofProgram',userAccount[0].account.Parts_of_program_you_are_interested_in__c);
            userRecord.put('companyName',userAccount[0].account.Public_Name__c);
            userRecord.put('areaoffocus',userAccount[0].account.Areas_of_focus__c);
            userRecord.put('zipCode',userAccount[0].account.zip_codes_they_service__c);
            userRecord.put('Licenses',userAccount[0].account.License_for_area_HVAC_plumbing_etc__c);
            userRecord.put('branchLocation',userAccount[0].account.Distributor_Branch_Location__c);
            userRecord.put('mfReplacement',userAccount[0].account.MF_Replacement__c);
            userRecord.put('mfNewConstruction',userAccount[0].account.MF_New_Construction__c);
            userRecord.put('residentialNewConstruction',userAccount[0].account.Residential_New_Construction__c);
            userRecord.put('residentialReplacement',userAccount[0].account.Residential_Replacement__c);
            userRecord.put('commercial',userAccount[0].account.Commercial__c);
            userRecord.put('phone',userAccount[0].account.Phone);
            userRecord.put('email',userAccount[0].account.Email__c);
            
        }
        //{'contactTitle'=>userContact[0].contact.Title,'dealerVolume'=>userAccount[0].account.Estimated_Annual_Dealer_Volume__c,
        //'shippingStreet'=>userAccount[0].account.shippingStreet,'shippingCity'=>userAccount[0].account.shippingCity,
        //'shippingState'=>userAccount[0].account.shippingState,'shippingZipcode'=>userAccount[0].account.shippingPostalcode,
        //'shippingCountry'=>userAccount[0].account.shippingCountry,'brands'=>userAccount[0].account.Brands_Currently_Selling__c,
        //'productsOffered'=>userAccount[0].account.Products_Offered_Check_all_that_apply__c,'billingStreet'=>userAccount[0].account.billingStreet,
        //'billingCity'=>userAccount[0].account.billingCity,'billingState'=>userAccount[0].account.billingState,
        //'billingZipcode'=>userAccount[0].account.billingPostalCode,'billingCountry'=>userAccount[0].account.billingCountry,
        //'accountName'=>userAccount[0].account.Name,'accountDealerStatus'=>userAccount[0].account.Dealer_Status__c,'contactName' =>userContact[0].contact.Name ,'contactEmail'=>userContact[0].contact.Email, 'contactPhone' => userContact[0].contact.Phone};
        String userData = JSON.serialize(userRecord);
		    
        //System.debug('user contact '+userContact);
        //System.debug('user account '+userAccount[0].account.Name+userAccount[0].account.Dealer_Status__c);
        
        return userData;
    }
}