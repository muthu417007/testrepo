//******************************************************************************************
//Name : Mya_PersonInfoPayLoad 
//Requirement : Wrapper Class to handle getPersonInfo Data
//EPIC/US/TASK : IDMSF- 155
//******************************************************************************************
//History
//	Version				Author					Date				Detail
//  1.0					Yogesh Sharma			09/09/2022			Initial
//******************************************************************************************
//@description : Wrapper Class to handle getPersonInfo Data
global with sharing class Mya_PersonInfoPayLoad 
{
    global String firstName;
    global String lastName;
    global String global_customer_id;
    global String emailAddress;
    global List<Locations> Locations;
    global List<Phones> Phones;
    
    //@description : Location Class
    global class Locations
    {
        global String addressLine1;
        global String addressLine2;
        global String locality;
        global String region;
        global String postalCode;
        global String country;
        global String accountId;
        global String nickName;
        global String primary;
    }
    
    //@description : Phones CLass
    global class Phones
    {
        global String phone;
        global String primary;
        global String phoneTypeDescription;
        global String contactPointId;
    }
}