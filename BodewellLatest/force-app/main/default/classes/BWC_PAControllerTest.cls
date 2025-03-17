@isTest
public class BWC_PAControllerTest {
    
    @isTest
    public static void updatePAMembershipDetailsTest()
    {  
        Id p = [select id from profile where name='Bodewell Commerce D2C Login User'].id;
        
        Account ac = new Account(name ='Grazitti') ;
        insert ac; 
        BuyerAccount buyerAccount = new BuyerAccount();
        buyerAccount.BuyerId = ac.Id;
        buyerAccount.Name = 'Test Buyer Account (BA-AJ)';
        buyerAccount.IsActive = true;
        insert buyerAccount;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;  
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        BuyerGroup bg=new BuyerGroup();
        bg.Name='Test BuyerGroup';
        insert bg;
        
        BuyerGroupMember member = new BuyerGroupMember();
        member.buyerId = ac.Id; //Person Account ID
        member.BuyerGroupId = bg.Id; //Member Buyer Group Id
        
        Account ac1 = new Account(name ='Test Account') ;
        insert ac1;
        insert member;
        //  system.runas(user)
        //   {
        Test.startTest(); 
        BuyerGroupMember memberCreated= BWC_PAController.updatePAMembershipDetails(ac.Id); 
        BuyerGroupMember memberCreated1= BWC_PAController.updatePAMembershipDetails(ac1.Id); 
        
        Test.stopTest();
        // }
        
        
        
        
    }
    
    @isTest
    public static void revertMembershipTest()
    {  
        Id p = [select id from profile where name='Bodewell Commerce D2C Login User'].id;
        
        Account ac = new Account(name ='Test Account') ;
        insert ac; 
        BuyerAccount buyerAccount = new BuyerAccount();
        buyerAccount.BuyerId = ac.Id;
        buyerAccount.Name = 'Test Buyer Accoun';
        buyerAccount.IsActive = true;
        insert buyerAccount;
        Contact con = new Contact(LastName ='testCon1',AccountId = ac.Id);
        insert con;  
        
        User user = new User(alias = 'test9', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='tester34@noemail.com');
        
        insert user;
        BuyerGroup bg=new BuyerGroup();
        bg.Name='Test BuyerGroup3';
        insert bg;
        BuyerGroup bg1=new BuyerGroup();
        bg1.Name='Test BuyerGroup4';
        insert bg1;
        
        BuyerGroupMember member = new BuyerGroupMember();
        member.buyerId = ac.Id; //Person Account ID
        member.BuyerGroupId = bg1.Id; //Member Buyer Group Id
        //  member.OwnerId=accId;
        ac.BWC_Previous_Buyer_Group__c=bg.id;
        update ac;
        insert member;
        Account ac1 = new Account(name ='Test Account') ;
        insert ac1;
        //  system.runas(user)
        // {
        Test.startTest(); 
        BuyerGroupMember memberCreated= BWC_PAController.revertMembership(ac.Id);
        BuyerGroupMember memberCreated1= BWC_PAController.revertMembership(ac1.Id); 
        
        Test.stopTest();
        // }
        
        
        
        
    }
    
    
    
    @isTest
    public static void changeMembershipAfterPreservationTest()
    {  
        Id p = [select id from profile where name='Bodewell Commerce D2C Login User'].id;
        
        Account ac = new Account(name ='Test Account') ;
        insert ac; 
        BuyerAccount buyerAccount = new BuyerAccount();
        buyerAccount.BuyerId = ac.Id;
        buyerAccount.Name = 'Test Buyer Accoun';
        buyerAccount.IsActive = true;
        insert buyerAccount;
        Contact con = new Contact(LastName ='testCon1',AccountId = ac.Id);
        insert con;  
        
        User user = new User(alias = 'test9', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='tester34@noemail.com');
        
        insert user;
        BuyerGroup bg=new BuyerGroup();
        bg.Name='Test BuyerGroup1';
        insert bg;
        BuyerGroup bg1=new BuyerGroup();
        bg1.Name='Test BuyerGroup2';
        insert bg1;
        
        BuyerGroupMember member = new BuyerGroupMember();
        member.buyerId = ac.Id; //Person Account ID
        member.BuyerGroupId = bg1.Id; //Member Buyer Group Id
        //  member.OwnerId=accId;
        ac.BWC_Previous_Buyer_Group__c=bg.id;
        update ac;
        insert member;
        
        Product2 productRecord=new Product2();
        productRecord.StockKeepingUnit='ABCSE';
        productRecord.Item_Number__c='4567';
        productRecord.Name='TEST product';
        insert productRecord;      
        
        
        WebStore webStore = new WebStore(Name='Bodewell Store');
        insert webStore;
        system.debug(webStore);
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=ac.Id,status='Active',IsSecondary=false);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;
        CartItem ctItem=new CartItem();
        ctItem.Name=productRecord.Name;
        ctItem.Product2Id=productRecord.Id;
        ctItem.CartId=cart.Id;
        ctItem.Sku=productRecord.StockKeepingUnit;    
        ctItem.Type='Product';
        ctItem.CartDeliveryGroupId=cartDeliveryGroup.Id;
        ctItem.Quantity=1;
        ctItem.SalesPrice=20;
        ctItem.TotalPrice=30;
        
        
        insert ctItem;
        //  system.runas(user)
        //  {
        Test.startTest(); 
        BuyerGroupMember memberCreated= BWC_PAController.changeMembershipAfterPreservation(ac.Id,cart.Id,user.Id); 
        Test.stopTest();
        // }
        
         }
       
    
}