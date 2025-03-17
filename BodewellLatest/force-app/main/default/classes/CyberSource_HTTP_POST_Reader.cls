public class CyberSource_HTTP_POST_Reader {
    
     public string reasonCode{get; set;}
     public string paymentToken{get; set;}
     public string concessionId{get; set;}
     public string caseId{get; set;}
     public Map<string, string> params {get; set;}

    public PageReference init() {
        
     params= ApexPages.currentPage().getParameters();
        
        for (string key : params.keySet() )
        {
              if (key!=null && key.contains('req_merchant_defined_data3'))
                   caseId = params.get(key);
              if (key!=null && key.contains('req_merchant_defined_data4'))
                   concessionId = params.get(key);         
			  if (key!=null && key.contains('payment_token'))
                   paymentToken = params.get(key);
              if (key!=null && key.contains('reason_code'))
                   reasonCode = params.get(key);                        
        }
        return null;
    }
}