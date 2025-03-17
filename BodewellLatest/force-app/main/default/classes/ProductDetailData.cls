public class ProductDetailData {

    public Data data{get;set;}

    public class Data {
        public String getMDMInfo {get;set;}
    }

    
    public static ProductDetailData parse(String json) {
        return (ProductDetailData) System.JSON.deserialize(json, ProductDetailData.class);
    }
}