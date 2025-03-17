@RestResource(urlMapping='/contacts/*')
global class ContactREST{
    
    @HttpGet
    global static wrapper doGet()
    {
        
        String emailAddress = '';
        
        RestRequest restReq = RestContext.request;
        emailAddress = restReq.params.get('email');
        
        if(emailAddress == ''){
            wrapper w = new wrapper();
            w.text='Error - No email supplied';
            return w;
        }
        
        //search standard contacts
        String qryString = 'SELECT  id,name,accountId,phone,email,mailingStreet,mailingPostalCode,PersonID__c FROM Contact WHERE ID != NULL  ';
        qryString += 'AND email =: emailAddress ';    
        qryString += ' ORDER BY lastName LIMIT 100 ';  
        
        List<Contact> returnContacts = Database.query(qryString);
        
        //if not found search 360 and restore
        if(returnContacts.size() > 0){
            wrapper w = new wrapper();
            w.text='success';
            w.contacts = returnContacts;
            return w;  
            
        } else {
            //if not found return not found otherwise return id
        }
        
        return null;
              
    }
    
    @HttpPost
    global static wrapper doPost()
    {
        
        // create contact from data sent into API
        
        wrapper w = new wrapper();
        w.text='success123';
        return w;        
    }
    
    global class wrapper
    {
        public String text {get;set;}
        public List<Contact> contacts{get;set;}
    }
}