public class ProductDetails {

    public List<benefitCopy> benefits {get;set;}
    public List<attribute> attributes{get;set;}
    public List<image> images{get;set;}
    
    public class benefitCopy {
        public String featureCopy {get;set;}
        public String feature {get;set;}    
    }
    
    public class attribute{
        public String attributeName {get;set;}
        public List<String> values {get;set;}
        public String definition {get;set;}
        public String displayName {get;set;} 
        public String priority {get;set;} 
        public String testValues {get;set;}   
    }
    
    public class image{
        public String imageID {get;set;}
        public String dataCategory {get;set;}
        public String dataId {get;set;} 
        public String imageName {get;set;}   
    }

}