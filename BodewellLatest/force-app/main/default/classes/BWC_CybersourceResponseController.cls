public class BWC_CybersourceResponseController {
   public String paramsJson {get; set;}

   public PageReference init() {
       paramsJson = JSON.serialize(ApexPages.currentPage().getParameters());
       return null;
   }
}