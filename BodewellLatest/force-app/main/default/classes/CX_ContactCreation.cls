/**
* @author         Matheus Lopes
* @company        PolSource
* @created        22.06.2021
* @description    Class that handles the Contact creation logic
* @testClass      CX_ContactCreationTest
*/
public without sharing class CX_ContactCreation {
    private static final CX_ContactCreation INSTANCE = new CX_ContactCreation();
    private final CX_Logger logger = new CX_Logger(CX_Logger.LogMode.MODE_PLATFORM_EVENT);
    
    /**
* @author         Matheus Lopes
* @company        PolSource
* @created        22.06.2021
* @description    Returns the singleton instance
* @return         CX_ContactCreation - a CX_ContactCreation singleton instance
*/
    public static CX_ContactCreation getInstance() {
        return INSTANCE;
    }
    
    /**
* @author         Matheus Lopes
* @company        PolSource
* @created        22.06.2021
* @description    Method that handles the whole Contact creation logic and returns the Assets for the Case and Contact
* @param          CX_ContactCreationWrapper - The contact creation wrapper
* @param          Case - The current case to which the Contact will be assigned
* @param          Boolean - Do we have the customer address?
*/
  
    public Contact createContact(CX_ContactCreationWrapper wrapper, Case currentCase) {
        Savepoint sp;
   
        try {
            if(wrapper.unknownAddress) {
                sp = Database.setSavepoint();
                return createUnknownAddressContact(wrapper, currentCase);
            }
            
            if(wrapper.country=='canada'){
                 sp = Database.setSavepoint();
                 return createCanadaContact(wrapper, currentCase);
            }
            
            User currentUser = [SELECT ID, Business_Team__c, Team_Persona__c, SSO_ID__c FROM User WHERE Id = :UserInfo.getUserId()];
            validateValues(wrapper, currentUser);

            Account location = processLocations(wrapper);            

            Account newPersonAccount = new Account(
	                     FirstName = wrapper.firstName,
	                     LastName = wrapper.lastName,
	                     Phone = wrapper.phone,
	                     PersonEmail = wrapper.email,
                         BillingCountry = wrapper.country,
	                     RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
             );
           
            CN1Response cn1Response = CX_CN1Service.getInstance().getCN1CustomerNumber(newPersonAccount, location, currentUser);

            sp = Database.setSavepoint();
            
            processNewRecords(currentCase, location, newPersonAccount, wrapper, cn1Response);
            
            Contact newPersonContact = [SELECT Id,FirstName,LastName,phone,email FROM Contact WHERE AccountId = : newPersonAccount.id];
           
            if(currentCase != null) {
                currentCase.ContactID = newPersonAccount.Id;
                
            }

            return newPersonContact;
        } catch(CalloutException ex) {
            rollback(sp);
            throw ex;
        } catch(CX_ContactCreationException ex) {
            rollback(sp);
            throw ex;
        } catch(Exception ex) {
            rollback(sp);
            logger.logError(ex, 'CX_ContactCreation', 'createContact');
            throw ex;
        }
    }
    
    /**
* @author         Matheus Lopes
* @company        PolSource
* @created        24.06.2021
* @description    Method that handles the Contact creation logic when there is no address
* @param          CX_ContactCreationWrapper - The contact creation wrapper
* @param          Case - The current case to which the Contact will be assigned
* @return         Contact - The created contact
*/
   private Contact createUnknownAddressContact(CX_ContactCreationWrapper wrapper, Case currentCase) {
        system.debug('in createUnknownAddressContact' +wrapper.country);
        Account newLocationAccount = new Account(
            Name = 'NoAddress City ST 00000',
            BillingStreet = wrapper.street,
            BillingCity = 'City',
            BillingState = 'ST',
            BillingPostalCode = wrapper.zip,
            RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Location').getRecordTypeId()
        );
        insert newLocationAccount;
        
        Account newPersonAccount = new Account(
	            PersonEmail = wrapper.email,
	            Phone = wrapper.phone,
	            FirstName = wrapper.firstName,
	            LastName = wrapper.lastName,
                BillingCountry = wrapper.country,
	            RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
	     );
        insert newPersonAccount;
        
        Contact newContact = [SELECT Id,FirstName,LastName,phone,email FROM Contact WHERE AccountId = : newPersonAccount.id];

        GEA_AccountContactRelation__c relation = new GEA_AccountContactRelation__c(
            Contact__c = newContact.Id,
            Account__c = newLocationAccount.Id
        );

        List<SObject> dmlObjects = new List<SObject>();
        dmlObjects.add(relation);

        if(currentCase != null) {
            Case caseUpdate = new Case(
                Id = currentCase.Id,
                ContactID = newContact.Id
               
            );

            currentCase.ContactID = newContact.Id;
            dmlObjects.add(caseUpdate);
        }

        upsert dmlObjects;

        return newContact;
    }
    /**
* @author         Neha Chowdhury
* @company        Ge-Appliances
* @created        07.01.2022
* @description    Method that handles the Contact creation logic when the country is Canada
* @param          CX_ContactCreationWrapper - The contact creation wrapper
* @param          Case - The current case to which the Contact will be assigned
* @return         Contact - The created contact
*/
    private Contact createCanadaContact(CX_ContactCreationWrapper wrapper, Case currentCase) {
              Account newLocationAccount = new Account(
                   Name = wrapper.street + ' ' + wrapper.city +' '+wrapper.state+ ' ' + wrapper.country+ ' ' +wrapper.zip,
                   BillingStreet = wrapper.street,
                   BillingCity = wrapper.city,
                   BillingState = wrapper.state,
                   BillingPostalCode = wrapper.zip,
                   BillingCountry = wrapper.country,
                   RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Location').getRecordTypeId()
               );
               
        	   insert newLocationAccount;
               
               Account newPersonAccount = new Account(
	                   PersonEmail = wrapper.email,
	                   Phone = wrapper.phone,
	                   FirstName = wrapper.firstName,
	                   LastName = wrapper.lastName,
                       BillingCountry = wrapper.country,
	                   RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
	           );
        	   insert newPersonAccount;
               
               Contact newContact = [SELECT Id,FirstName,LastName,phone,email FROM Contact WHERE AccountId = : newPersonAccount.id];
       
               GEA_AccountContactRelation__c relation = new GEA_AccountContactRelation__c(
                   Contact__c = newContact.Id,
                   Account__c = newLocationAccount.Id
               );
       
               List<SObject> dmlObjects = new List<SObject>();
               dmlObjects.add(relation);
       
               if(currentCase != null) {
                   Case caseUpdate = new Case(
                       Id = currentCase.Id,
                       ContactID = newContact.Id
                   );
       
                   currentCase.ContactID = newContact.Id;
                   dmlObjects.add(caseUpdate);
               }
       
               upsert dmlObjects;
       
               return newContact;
    }
    
    /**
* @author         Matheus Lopes
* @company        PolSource
* @created        24.06.2021
* @description    Method that handles the wrapper validation
* @param          CX_ContactCreationWrapper - The contact creation wrapper
* @param          User - The current user
*/
    private void validateValues(CX_ContactCreationWrapper wrapper, User currentUser) {
        if(String.isBlank(wrapper.street)) {
            throw new CX_ContactCreationException('Street Required.');            
        } else if(String.isBlank(wrapper.phone) && currentUser.Business_Team__c != 'TAG' && wrapper.usePhoneField) {
            throw new CX_ContactCreationException('Phone Required.');            
        } else if(String.isBlank(wrapper.zip)) {
            throw new CX_ContactCreationException('Zip Required.');            
        } else if(String.isBlank(wrapper.firstName)) {
            throw new CX_ContactCreationException('First Name Required.');            
        } else if(String.isBlank(wrapper.lastName)) {
            throw new CX_ContactCreationException('Last Name Required.');            
        }
    }
    
    /**
* @author         Matheus Lopes
* @company        PolSource
* @created        24.06.2021
* @description    Method that handles the location logic
* @param          CX_ContactCreationWrapper - The contact creation wrapper
* @return         Account - The location to use (can be new or an existing one)
*/
    private Account processLocations(CX_ContactCreationWrapper wrapper) {
        List<Account> locations = CX_AccountDAO.getInstance().getLocationsByZipCodeAndStreet(wrapper.zip, wrapper.street);
        Account location;
        
        if(locations.size() != 1) {
            locations = wrapper.usePhoneField ? CX_AccountDAO.getInstance().getLocationsByPhone(wrapper.phone) : new List<Account>();
            
            if(locations.size() != 1) {
                location = processNewLocation(wrapper);
            } else {
                location = locations[0];
            }
        } else {
            location = locations[0];
        }

        return location;
    }
    
    /**
* @author         Matheus Lopes  -->( Gunhan Gultekin: Method changed to public to access from the CX_FLowLocationComponentController)
* @company        PolSource
* @created        24.06.2021
* @description    Method that handles the new location logic
* @param          CX_ContactCreationWrapper - The contact creation wrapper
* @return         Account - The new location to use
*/
    public Account processNewLocation(CX_ContactCreationWrapper wrapper) {
        ZoneDetailsResponse response = CX_UpdateLocationQueueable.verifyAddress(wrapper.zip);
        
        if(response == null) {
            throw new CalloutException('Error while retrieving location info!');
        }
        
        return new Account(
            Name = wrapper.street.trim() + ' ' + CX_Utils.capitalizeInitialLetter(response.CityName.toLowerCase()).trim() + ' ' + response.StateCode.trim() + ' ' + wrapper.zip.trim(),
            BillingStreet = wrapper.street.trim(),
            BillingCity = CX_Utils.capitalizeInitialLetter(response.CityName.toLowerCase()).trim(),
            BillingState = response.StateCode.trim(),
            BillingPostalCode = wrapper.zip.trim(),
            Region__c = Integer.valueOf(response.RegionNo),
            Zone__c = String.valueOf(response.ZoneCode),
            Service_Region_Zone__c = response.ZoneCode != null && response.ZoneCode == '09' ? 'Customer Care' : 'Factory Service',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Location').getRecordTypeId()
            
        );
    }
    
    /**
* @author         Matheus Lopes
* @company        PolSource
* @created        24.06.2021
* @description    Method that handles the new record creation logic
* @param          Case - The current case
* @param          Account - The location to relate to records
* @param          Contact - The new contact record
* @param          CX_ContactCreationWrapper - The contact creation wrapper
* @param          CN1Response - The contact creation in CN1 response
*/
    private void processNewRecords(Case currentCase, Account location, Account newAccount, CX_ContactCreationWrapper wrapper, CN1Response cn1Response) {
        if(String.isBlank(location?.Id)) {
            insert location;
        }
        
        fillNewContact(newAccount, wrapper, location);
        insert newAccount;
        Contact newContact = [SELECT Id,FirstName,LastName,phone,email FROM Contact WHERE AccountId = : newAccount.id];
        Contact_Information__c  contactInformation = new Contact_Information__c (
            ID_Type__c = 'GE Consumer Number',
            Contact__c = newContact.id,
            Identifier__c = cn1Response.ConsumerNo
        );
        
        GEA_AccountContactRelation__c relation = new GEA_AccountContactRelation__c(
            Contact__c = newContact.id,
            Account__c = location.Id
        );
        
        List<SObject> dmlObjects = new List<SObject>();
        dmlObjects.add(contactInformation);
        dmlObjects.add(relation);
        
        if(currentCase != null) {
            Case caseUpdate = new Case (
                Id = currentCase.Id,
                ContactID = newContact.id,
                AccountId = location.Id
            );
            
            dmlObjects.add(caseUpdate);
        }
     
        upsert dmlObjects;
    }
    
    /**
* @author         Matheus Lopes
* @company        PolSource
* @created        24.06.2021
* @description    Method that fills the new contact information 
* @param          Contact - The new contact record
* @param          CX_ContactCreationWrapper - The contact creation wrapper
* @param          Account - The location to relate to the contact
*/
    private void fillNewContact(Account newContact, CX_ContactCreationWrapper wrapper, Account location) {
        newContact.FirstName = wrapper.firstName;
        newContact.LastName = wrapper.lastName;
        newContact.PersonEmail = wrapper.email;
        newContact.Phone = wrapper.phone;
    }
    
    /**
* @author         Matheus Lopes
* @company        PolSource
* @created        23.06.2021
* @description    Method that rollback all transactions if a savepoint is not null
* @param          Savepoint - a savepoint
*/
    private void rollback(Savepoint sp) {
        if(sp != null) {
            Database.rollback(sp);
        }
    }
    
    public class CX_ContactCreationException extends Exception {}
}