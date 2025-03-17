public class ModelNumberResponse {

    public String ModelNumber;
    public String BrandCode;
    public String ProductTypeCode;
    public String ProductLineCode;
    public String ProductLineDesc;
    public String ProductTypeDesc;
    
    public static ModelNumberResponse parse(String json) {
        return (ModelNumberResponse) System.JSON.deserialize(json, ModelNumberResponse.class);
    }
}