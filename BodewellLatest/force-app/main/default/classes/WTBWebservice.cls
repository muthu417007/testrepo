/**
 * @author         Niku Singh
 * @company        GEA
 * @created        03/01/2022
 * @description    Class used to send Where to Buy store details
 */
@RestResource(urlMapping='/getSiteRecords/*')
global with sharing class WTBWebservice {
   public static List<PS_AccountBrand__mdt> availableBrands = [SELECT Label FROM PS_AccountBrand__mdt];
    global class siteDetailswithUrl{
        List<sideDetailsWrapper> siteWrapper = new List<sideDetailsWrapper> {};
        Integer totalRecords=0;
        Integer recordsRetrieved=0;
        String nextRecordsUrl;
        String nextStartId;
    }
    
    global class sideDetailsWrapper{
        String SellerLogo, SellerName, SellerId, StoreName, StoreId, Address, city, state, zipcode, Country, StoreType, Phone, SfdcId, SellerURL;
        String[] ProductGroup = new String[] {};
        List<badgeDetails> bd = new List<badgeDetails> {};
       
    }
    //Wrapper class for holding badge details for each store
    global class badgeDetails{
        String PreferredPartner, BadgeName, BadgeIcon, DestinationURL, HoverText, AriaLabel;
    }
    @HttpGet
    global static siteDetailswithUrl siteDetailsList() {
        RestRequest request = RestContext.request;
        system.debug('request>>>'+request);
        String recordsFetched = request.params.get('recordsRetrieved');
        String nextStartId = request.params.get('nextStartId');
        system.debug('nextStartId>>>>'+nextStartId);
        system.debug('recordsFetched>>>>'+recordsFetched);
        Id siteRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        List<Account> accList = new List<Account>();
        Integer totalSites = [SELECT Id FROM Account where Status__c='A' and parent.Status__c='A' and Purpose__c like '%WHERE TO BUY%' and ShippingCountry='US' and recordtypeId = :siteRecordTypeId].size();
        //condition for returning first 2000 or less records
        if(String.isBlank(nextStartId))
            accList = [SELECT Id, Name, parent.Seller_Logo__c, parent.Phone, recordtype.name, parent.parent.Party_Registry_ID__c,parent.parent.id,parent.parent.Party_Name__c,parent.Doing_Business_As_DBA__c, Oracle_Site_Reference_Id__c, ShippingAddress,ShippingStreet,ShippingState,ShippingPostalCode,ShippingCity,ShippingCountry, Channel__c,parent.Channel__c, parent.recordtype.name,parent.recordtype.developername, parent.Oracle_Account_Number__c, parent.Website, parent.Brands_Allowed__c, Brands_Not_Allowed__c, ( SELECT phone from contacts where Business_Purpose__c = 'MAIN' and oracle_contact_type__c='GEN' order by createddate desc) FROM Account where Status__c='A' and parent.Status__c='A' and Purpose__c like '%WHERE TO BUY%' and ShippingCountry='US' and recordtypeId = :siteRecordTypeId  Order By Id limit 2000];
        //condition for returning subsequent 2000 records
        else
            accList = [SELECT Id, Name, parent.Seller_Logo__c, parent.Phone, recordtype.name, parent.parent.Party_Registry_ID__c,parent.parent.id,parent.parent.Party_Name__c,parent.Doing_Business_As_DBA__c, Oracle_Site_Reference_Id__c, ShippingAddress,ShippingStreet,ShippingState,ShippingPostalCode,ShippingCity,ShippingCountry, Channel__c,parent.Channel__c, parent.recordtype.name,parent.recordtype.developername, parent.Oracle_Account_Number__c, parent.Website, parent.Brands_Allowed__c,Brands_Not_Allowed__c, ( SELECT phone from contacts where Business_Purpose__c = 'MAIN' and oracle_contact_type__c='GEN' order by createddate desc) FROM Account where ID >:nextStartId and Status__c='A' and parent.Status__c='A' and Purpose__c like '%WHERE TO BUY%' and ShippingCountry='US' and recordtypeId = :siteRecordTypeId Order By Id limit 2000];
        Id lastId = accList!=null ? accList[accList.size()-1].Id : Null;
        Preferred_Partner_Mapping_WTB__mdt[] pfpa = [Select Aria_Label__c,Badge_Icon__c,Badge_Name__c,Destination_URL__c,Hover_Text__c,MasterLabel, Brands_Allowed__c, Party_Relationship_Type__c from Preferred_Partner_Mapping_WTB__mdt];
        Product_Group_Mapping_WTB__mdt[] prgp = [Select MasterLabel,DeveloperName, Brands_Allowed__c, Relationship_Type__c from Product_Group_Mapping_WTB__mdt];
        Map<String,Preferred_Partner_Mapping_WTB__mdt> badgeMapping = new Map<String,Preferred_Partner_Mapping_WTB__mdt>();
        Map<Id,Id> sitePartyIdMap = new Map<Id,Id>();
        Map<String,String> brndRelatnMap = new Map<String,String>();
        Map<String,String> prfrdPrtnrMap = new Map<String,String>();
        for(Account sites:accList){
            sitePartyIdMap.put(sites.Id, sites.parent.parent.Id);
        }
        System.debug('sitePartyIdMap>>>>>'+sitePartyIdMap);
        List<Party_Relationship__c> partyRel = [Select Id, Party__c, Relationship_Type__c, Status__c from Party_Relationship__c where Party__c in :sitePartyIdMap.values() and Status__c='A'];
        System.debug('partyRel>>>>'+partyRel);
        Map<Id,List<String>> partyRelatnMap = new Map<Id,List<String>>();
        for(Party_Relationship__c pr:partyRel){
            if(partyRelatnMap.containskey(pr.Party__c)){
                partyRelatnMap.get(pr.Party__c).add(pr.Relationship_Type__c);
            }
            else{
                partyRelatnMap.put(pr.Party__c,new List<String>{pr.Relationship_Type__c});
            }
        }
        System.debug('partyRelatnMap>>>>'+partyRelatnMap);
        for(Product_Group_Mapping_WTB__mdt prodgroup:prgp){
            if(prodgroup.Relationship_Type__c!=null && prodgroup.Relationship_Type__c!=''){
                system.debug('inside if prodgroup>>>'+prodgroup.Relationship_Type__c);
                if(prodgroup.Relationship_Type__c.contains(',')){
                    system.debug('inside if prodgroup>Relationship_type');
                    for(String reltns:prodgroup.Relationship_Type__c.split(',')){
                        brndRelatnMap.put((prodgroup.Brands_Allowed__c).toLowerCase()+','+reltns.toLowerCase(),prodgroup.MasterLabel);
                     }
                }
                else{
                    brndRelatnMap.put((prodgroup.Brands_Allowed__c).toLowerCase()+','+(prodgroup.Relationship_Type__c).toLowerCase(),prodgroup.MasterLabel);
                }
            }
            else{
                brndRelatnMap.put((prodgroup.Brands_Allowed__c).toLowerCase()+',No Relationship',prodgroup.MasterLabel);
            }
        }
        System.debug('brndRelatnMap>>>>'+brndRelatnMap);
        for(Preferred_Partner_Mapping_WTB__mdt ppm: pfpa){
            badgeMapping.put(ppm.MasterLabel,ppm);
            //if(ppm.Party_Relationship_Type__c!=null && ppm.Party_Relationship_Type__c!=''){
                if(ppm.Party_Relationship_Type__c.contains(',')){
                    for(String prelatns:ppm.Party_Relationship_Type__c.split(',')){
                        prfrdPrtnrMap.put((ppm.Brands_Allowed__c).toLowerCase()+','+prelatns.toLowerCase(),ppm.MasterLabel);
                     }
                }
                else{
                    prfrdPrtnrMap.put((ppm.Brands_Allowed__c).toLowerCase()+','+(ppm.Party_Relationship_Type__c).toLowerCase(),ppm.MasterLabel);
                }
            //}
            //else{
                //prfrdPrtnrMap.put((ppm.Brands_Allowed__c).toLowerCase()+',No Relationship',ppm.MasterLabel);
            //}
        }
        system.debug('badgeMapping>>>'+badgeMapping);
        system.debug('prfrdPrtnrMap>>>'+prfrdPrtnrMap);
        siteDetailswithUrl sitesWithNextUrl = new siteDetailswithUrl();
        sideDetailsWrapper[] siteDetails = new sideDetailsWrapper[] {};
            for(Account siteAcc:accList){
                Map<String,badgeDetails> prfrdptnr = new Map<String,badgeDetails>();
                sideDetailsWrapper site = new sideDetailsWrapper();
                site.SellerLogo = siteAcc.parent.Seller_Logo__c;
                site.SellerName = siteAcc.parent.parent.Party_Name__c;
                site.SellerId = siteAcc.parent.parent.Party_Registry_ID__c; 
                site.StoreName = siteAcc.parent.Doing_Business_As_DBA__c; 
                site.StoreId = siteAcc.Oracle_Site_Reference_Id__c; 
                site.Address = siteAcc.ShippingStreet;
                site.city = siteAcc.ShippingCity;
                site.state = siteAcc.ShippingState;
                site.zipcode = siteAcc.ShippingPostalCode;
                site.Country = siteAcc.ShippingCountry;
                site.StoreType = WTB_Store_Type_Mapping__mdt.getInstance(siteAcc.parent.recordtype.developername).Store_Type__c;
                if(siteAcc.Contacts!=null && siteAcc.Contacts.size() > 0){
                    site.Phone = siteAcc.Contacts[0].Phone;
                    system.debug('siteAcc.Contacts[0]>>>'+siteAcc.Contacts[0].Phone);
                }
                //site.Phone = siteAcc.Contacts[0].Phone;
                site.SfdcId = siteAcc.parent.Oracle_Account_Number__c;
                site.SellerURL = siteAcc.parent.Website;
                system.debug('siteAcc.parent.Brands_Allowed__c>>>>'+siteAcc.parent.Brands_Allowed__c);
                if(siteAcc.parent.Brands_Allowed__c!=null && siteAcc.parent.Brands_Allowed__c!=''){
                    List<String> brands = getSiteBrandsAllowedList(siteAcc.Brands_Not_Allowed__c);
                    for(String brandallowed:brands){
                        System.debug('partyRelatnMap.get(sitePartyIdMap.get(siteAcc.Id))>>>'+partyRelatnMap.get(sitePartyIdMap.get(siteAcc.Id)));
                        site.ProductGroup.add(brndRelatnMap.get(brandallowed.toLowerCase()+',No Relationship'));
                        if(sitePartyIdMap.get(siteAcc.Id)!=null){
                            if(partyRelatnMap.get(sitePartyIdMap.get(siteAcc.Id))!=null && partyRelatnMap.get(sitePartyIdMap.get(siteAcc.Id)).size()>0){
                                for(String prl:partyRelatnMap.get(siteAcc.parent.parent.Id)){
                                    
                                    badgeDetails bdgeDtls = new badgeDetails();
                                   // site.ProductGroup.add(brandRelatnMap.get(brandallowed));
                                   system.debug('brandallowed.toLowerCase(),prl.toLowerCase()'+brandallowed.toLowerCase()+','+prl.toLowerCase());
                                   if(brndRelatnMap.get(brandallowed.toLowerCase()+','+prl.toLowerCase())!=null)
                                      site.ProductGroup.add(brndRelatnMap.get(brandallowed.toLowerCase()+','+prl.toLowerCase()));
                                    system.debug('ProductGroup>>>'+site.ProductGroup);
                                    //if(prfrdPrtnrMap.get(brandallowed.toLowerCase()+','+prl.toLowerCase()) == 'GE Preferred'){
                                        //site.bd.PreferredPartner='GE Preferred';
                                    if(prfrdPrtnrMap.get(brandallowed.toLowerCase()+','+prl.toLowerCase())!=null){
                                        system.debug('prfrdPrtnrMap>>>'+prfrdPrtnrMap.get(brandallowed.toLowerCase()+','+prl.toLowerCase()));
                                        if(badgeMapping.get(prfrdPrtnrMap.get(brandallowed.toLowerCase()+','+prl.toLowerCase()))!=Null){
                                            if(!prfrdptnr.containsKey(badgeMapping.get(prfrdPrtnrMap.get(brandallowed.toLowerCase()+','+prl.toLowerCase())).MasterLabel)){
                                                bdgeDtls.PreferredPartner=badgeMapping.get(prfrdPrtnrMap.get(brandallowed.toLowerCase()+','+prl.toLowerCase())).MasterLabel;
                                                bdgeDtls.BadgeName=badgeMapping.get(prfrdPrtnrMap.get(brandallowed.toLowerCase()+','+prl.toLowerCase())).Badge_Name__c;
                                                bdgeDtls.BadgeIcon=badgeMapping.get(prfrdPrtnrMap.get(brandallowed.toLowerCase()+','+prl.toLowerCase())).Badge_Icon__c;
                                                bdgeDtls.DestinationURL=badgeMapping.get(prfrdPrtnrMap.get(brandallowed.toLowerCase()+','+prl.toLowerCase())).Destination_URL__c;
                                                bdgeDtls.HoverText=badgeMapping.get(prfrdPrtnrMap.get(brandallowed.toLowerCase()+','+prl.toLowerCase())).Hover_Text__c;
                                                bdgeDtls.AriaLabel=badgeMapping.get(prfrdPrtnrMap.get(brandallowed.toLowerCase()+','+prl.toLowerCase())).Aria_Label__c;
                                                prfrdptnr.put(badgeMapping.get(prfrdPrtnrMap.get(brandallowed.toLowerCase()+','+prl.toLowerCase())).MasterLabel,bdgeDtls);
                                                /*prfrdptnr.put(badgeMapping.get(prfrdPrtnrMap.get(brandallowed.toLowerCase()+','+prl.toLowerCase())).MasterLabel,new badgeDetails(PreferredPartner=badgeMapping.get(prfrdPrtnrMap.get(brandallowed.toLowerCase()+','+prl.toLowerCase())).MasterLabel,
                                                    BadgeName=badgeMapping.get(prfrdPrtnrMap.get(brandallowed.toLowerCase()+','+prl.toLowerCase())).Badge_Name__c,
                                                    BadgeIcon=badgeMapping.get(prfrdPrtnrMap.get(brandallowed.toLowerCase()+','+prl.toLowerCase())).Badge_Icon__c,
                                                    DestinationURL=badgeMapping.get(prfrdPrtnrMap.get(brandallowed.toLowerCase()+','+prl.toLowerCase())).Destination_URL__c,
                                                    HoverText=badgeMapping.get(prfrdPrtnrMap.get(brandallowed.toLowerCase()+','+prl.toLowerCase())).Hover_Text__c,
                                                    AriaLabel=badgeMapping.get(prfrdPrtnrMap.get(brandallowed.toLowerCase()+','+prl.toLowerCase())).Aria_Label__c));*/
                                                system.debug('bdgeDtls'+bdgeDtls);
                                                site.bd.add(bdgeDtls);
                                            }
                                        }
                                        system.debug('site.bd>>>'+site.bd);
                                    }
                                }
                            }
                           // else{
                                //site.ProductGroup.add(brndRelatnMap.get(brandallowed.toLowerCase()+',No Relationship'));
                            //}
                        }
                        
                    }
                }
                siteDetails.add(site);
            }
            sitesWithNextUrl.siteWrapper = siteDetails;
            sitesWithNextUrl.totalRecords = totalSites;
            //sitesWithNextUrl.recordsRetrieved = recordsFetched == '' ? (accList.size()<=2000 ? accList.size() : 2000) : Integer.valueOf(recordsFetched)+accList.size();   
        if(recordsFetched=='\'\'' || String.isBlank(recordsFetched)){
            if(accList.size()<=2000){
                sitesWithNextUrl.recordsRetrieved=accList.size();
            }
            else
                sitesWithNextUrl.recordsRetrieved=2000;
            
        }
        else
            sitesWithNextUrl.recordsRetrieved=Integer.valueOf(recordsFetched)+accList.size();
        //sitesWithNextUrl.recordsRemaining = totalSites-sitesWithNextUrl.recordsRetrieved;
        Integer dataRemaining = totalSites-sitesWithNextUrl.recordsRetrieved;
        sitesWithNextUrl.nextStartId = dataRemaining!=0 ? lastId : null;
        //nextStartId = lastId;
            //sitesWithNextUrl.nextRecordsUrl = dataRemaining!=0 ? URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/getSiteRecords1?nextStartId='+lastId+'&recordsRetrieved='+sitesWithNextUrl.recordsRetrieved : null;
        sitesWithNextUrl.nextRecordsUrl = dataRemaining!=0 ? '/services/apexrest/getSiteRecords?nextStartId='+lastId+'&recordsRetrieved='+sitesWithNextUrl.recordsRetrieved : null;
        return sitesWithNextUrl;
    }
    @testVisible
    private static List<String> getSiteBrandsAllowedList(String brandsNotAllowed)
    {
        List<String> BrandsAllowed= new List<String>(); 
        if(String.isBlank(brandsNotAllowed)){
              for (PS_AccountBrand__mdt brand : availableBrands) {
                  BrandsAllowed.add(brand.Label);
              }
        }
        else
        {
            Set<String> l_brandsNotAllowed = new Set<String>();
            for (String l_brand : brandsNotAllowed.split(',')) {
                    l_brandsNotAllowed.add(l_brand.trim());
                }
        	for (PS_AccountBrand__mdt brand : availableBrands) {
                	if (!l_brandsNotAllowed.contains(brand.Label)) {
                   		BrandsAllowed.add(brand.Label);
                	}
            	}
        }
        return BrandsAllowed;
    }

}