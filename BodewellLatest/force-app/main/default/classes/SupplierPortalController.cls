public class SupplierPortalController{
    
  public String username{get;set;}
  public String password{get;set;}
   
  public PageReference login() {
      PageReference p= new PageReference('https://appliances.force.com/suppliercollaboration/login?pw=lb!3L9OM5V2r&un=ssgknowledge@ssg.com');
      p.setRedirect(true);
      return p;     
  }
    
}