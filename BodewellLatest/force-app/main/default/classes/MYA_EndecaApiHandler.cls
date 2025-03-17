/**
 * @author         Akhil Raj
 * @company        TCS
 * @created        07.07.2022
 * @description    For getting product details from endeca api
 */
public with sharing class MYA_EndecaApiHandler {   
    // Method to get endeca details for a list of products
    @AuraEnabled(cacheable=false)
    public static ProductsResponse MYA_GetEndecaDetails(String[] Keys)
    {        
        ProductsResponse Details = new ProductsResponse();
        try {
            if(keys != null) {
                List<EndecaResponse> ProductResponse = new List<EndecaResponse>();
                for(String key: Keys) 
                {
                    EndecaResponseDetails ProductDetails = MYA_EndecaResponseDetails(key);
                    if(ProductDetails.Success == true) 
                    {
                        ProductResponse.add(ProductDetails.ProductInfo);
                    }
                }
                Details.ProductsInfo = ProductResponse;
            }
            return Details;
        } catch (Exception e) {
            MYA_ApplicationErrorLog.Mya_ExHandler(e, 'MYA_EndecaApiHandler', 'MYA_GetEndecaDetails');
           	throw e;
        }         
    }
    // Method to get endeca details for a products using sku
	@AuraEnabled(cacheable=false)
    public static EndecaResponseDetails MYA_EndecaResponseDetails(String SKU)
    {
        EndecaResponseDetails Result = new EndecaResponseDetails();        
        try {
            if(SKU != '') {
                String domainUrl = Url.getOrgDomainUrl().getHost();
                MYA_Configuration__mdt MyaConfig = MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);
                String Jwt = getJWT.generateJWTToken(MyaConfig.Endeca_API_Client_Id__c,MyaConfig.Endeca_API_Type__c,120,MyaConfig.Endeca_API_Client_Secret__c);
                String token =Jwt;
                Http HttpCall = new Http();
                HttpRequest Request = new HttpRequest();
                Request.setMethod('GET');
                Request.setEndpoint(MyaConfig.Endeca_API_Endpoint__c + SKU);
                Request.setHeader('Content-Type', 'application/json');
                Request.setHeader('Accept', 'application/json');
                Request.setHeader('Authorization',token);
                Request.setTimeout(60000);
                HttpResponse Response ;
                Response = HttpCall.send(Request);
                if(Response.getStatusCode() == 200) {
                    ProductsExtractResponse ProductObj = getProduct(Response.getBody());
                    if(ProductObj != null) {
                        List<Object> Item = (List<Object>) ProductObj.ProductDetails.get(SKU);
                        if(Item != null) 
                        {      
                            Result.ProductInfo = getProductInformations(Item, SKU, ProductObj.CommercialCategory, MyaConfig);
                            Result.Success = true;
                        }
                        else 
                        {
                            Result.ProductInfo = null;
                            Result.Success = false;
                        }
                    }
                    else 
                    {
                        Result.ProductInfo = null;
                        Result.Success = false;
                    }
                } else {
                    Result.ProductInfo = null;
                 	Result.Success = false;
                }                            
            }
            else 
            {
                Result.ProductInfo = null;
                Result.Success = false;
            }
            return Result;
        } catch (Exception e) {
            throw e;
        } 
    }
    // Method to extract endeca details of a product using response string
    public static ProductsExtractResponse getProduct(String Input)
    {        
        ProductsExtractResponse ProductInfo = new ProductsExtractResponse();        
        try {
            Map<String, Object> commercialCategories;
            List<Object> filterValues;
            Map<String, Object> Result = (Map<String, Object>)JSON.deserializeUntyped(Input);
            if((List<Object>) Result.get('results') != null) {
                for(Object obj : (List<Object>) Result.get('results')) {
                    Map<String, Object> data_1 = (Map<String, Object>) obj;
                    if(data_1 != null) {
                        Map<String, Object> records = (Map<String, Object>) data_1.get('records');
                        if(records != null) {
                            ProductInfo.ProductDetails = (Map<String, Object>) records.get('products');                        
                        }
                        Map<String, Object> filters = (Map<String, Object>) data_1.get('filters');
                        if(filters != null) {
                            commercialCategories = (Map<String, Object>) filters.get('Commercial Categories');     
                            if(commercialCategories != null) {
                                filterValues = (List<Object>) commercialCategories.get('filterValues');
                                for (Object filterValue : filterValues) {
                                        Map<String, Object> filValue = (Map<String, Object>) filterValue;
                                        ProductInfo.CommercialCategory = filValue.get('label');
                                    }
                            }
                        }
                    }
                }
            }
            return ProductInfo;
        } catch (Exception e) {
            throw e;
        }   
    }
    // Method to extract product details from a string
    public static EndecaResponse getProductInformations(List<Object> Item, String Sku, Object CommCategories, MYA_Configuration__mdt MyaConfig)
    {
        try {
            String ObjectRetrievalUrl = MyaConfig.Marketing_Object_Retrieval_Path__c;
            String PartsUrl = MyaConfig.Parts_And_Accessories_Path__c;
            String EServiceUrl = MyaConfig.E_service_product_selection_url__c;       
            EndecaResponse EndecaResponse = new EndecaResponse();
            EndecaResponse.ModelNumber = Sku; 
            // Endeca details fetching logic
            for(Object Obj : Item) {
                        Map<String, Object> Obj_1 = (Map<String, Object>) Obj;
                        if(Obj_1 != null){
                            List<Object> Description = (List<Object>) Obj_1.get('Description');
                            if(Description != null) {
                                EndecaResponse.ProductDescription = Description[0];
                            }
                            List<Object> ProductCommercialCategory = (List<Object>) Obj_1.get('Product_Commercial_Category');
                            if(ProductCommercialCategory != null) {
                                EndecaResponse.ProductCommercialCategory = ProductCommercialCategory;
                            }
                            List<Object> DisplayStatus = (List<Object>) Obj_1.get('Product_Display_Status');
                            if(DisplayStatus != null) { 
                                EndecaResponse.IsConsumerReady = false;
                                for(Object DisplayStatusItem : DisplayStatus) {
                                    String StatsStr = String.valueOf(DisplayStatusItem);
                                    if(StatsStr.contains('Consumer Ready')) {
                                        EndecaResponse.IsConsumerReady = true;
                                    }
                                }
                            } 
                            Map<String, Object> ImageSet = (Map<String, Object>) Obj_1.get('Images');
                            if(ImageSet != null) {
                                List<Object> ImageList = new List<Object>();
                                Set <String> ImageKeySet = new Set<String>();
                                ImageKeySet = ImageSet.keySet();
                                for (String Key : ImageKeySet) {
                                    Map<String, Object> ImageObj = (Map<String, Object>) ImageSet.get(Key);
                                    if(ImageObj != null && ImageObj.get('Default') == 'TRUE') { 
                                        //EndecaResponse.DefaultImageUrl = ObjectRetrievalUrl + '?RequestType=Image&Name=' + ImageObj.get('Name');
                                        EndecaResponse.DefaultImageUrl = string.valueOf(ImageObj.get('Path')); //added for Salsify - Endeca Transition project -- SPR - 146
                                    }  
                                    ImageList.add(ImageObj);
                                }
                                EndecaResponse.Images = ImageList;
                            }
                             Map<String, Object> Documents = ( Map<String, Object>) Obj_1.get('Documents');
                            if(Documents != null) {
                                List<Object> DocumentList = new List<Object>();
                                Set <String> DocumentKeySet = new Set<String>();
                                DocumentKeySet = Documents.keySet();
                                for (String Key : DocumentKeySet) {
                                    Map<String, Object> DocumentObj = (Map<String, Object>) Documents.get(Key);
                                    if(DocumentObj != null && DocumentObj.get('Document_Type') == 'Use_and_Care_Manual') { 
                                        //EndecaResponse.UserManualUrl = ObjectRetrievalUrl + '?RequestType=PDF&Name=' + DocumentObj.get('Name');
                                        EndecaResponse.UserManualUrl = string.valueof(DocumentObj.get('Path')); //SPR -146 added for Salsify - Endeca Transition project
                                    }  
                                    DocumentList.add(DocumentObj);
                                }
                                EndecaResponse.Documents = DocumentList;
                            }
                            List<Object> BrandObj = (List<Object>) Obj_1.get('Brand.DisplayName');
                            if(BrandObj != null) {
                                EndecaResponse.Brand = BrandObj[0];
                            }
                            List<Object> Categories = (List<Object>) Obj_1.get('Product_Commercial_Category');
                            if(Categories != null) {
                                for(Object CategoryObj : Categories) {
                                    String CategoryStr = String.valueOf(CategoryObj);
                                    if(CategoryStr.contains('Room Air Conditioners_Split-System')) {
                                        EndecaResponse.IsDuctless = true;
                                    } else {
                                        EndecaResponse.IsDuctless = false;
                                    }
                                }
                            }
                            Object Attributes = (Object) Obj_1.get('Attributes');
                            if(Attributes != null) {
                                List<Object> AttrList = ((Map<String, Object>) Attributes).values();
                                for(Object AttrListItem : AttrList) {
                                    String AttrStr = String.valueOf(AttrListItem);
                                    if(AttrStr.contains('Parts Warranty')) {
                                        Map<String, Object> PartsWarrantyItem = (Map<String, Object>) AttrListItem;
                                        List<Object> PartsWarrantyValues = (List<Object>) PartsWarrantyItem.get('Value');
                                        EndecaResponse.PartsWarranty = PartsWarrantyValues;
                                    }
                                    if(AttrStr.contains('Labor Warranty')) {
                                        Map<String, Object> LaborWarrantyItems = (Map<String, Object>) AttrListItem;
                                        List<Object> LaborWarrantyValues = (List<Object>) LaborWarrantyItems.get('Value');
                                        EndecaResponse.LaborWarranty = LaborWarrantyValues;
                                    }
                                    if(AttrStr.contains('Warranty Notes')) {
                                        Map<String, Object> WarrantyNoteItem = (Map<String, Object>) AttrListItem;
                                        List<Object> WarrantyNotevalues = (List<Object>) WarrantyNoteItem.get('Value');
                                        EndecaResponse.WarrantyNotes = WarrantyNotevalues;
                                    }
                                    if(AttrStr.contains('App Filter - Product Type')) {
                                        Map<String, Object> appFilterProductTypeItem = (Map<String, Object>) AttrListItem;
                                        List<Object> appFilterProductTypeItemvalues = (List<Object>) appFilterProductTypeItem.get('Value');
                                        EndecaResponse.AppFilterProductType = appFilterProductTypeItemvalues;
                                    }
                                    if(AttrStr.contains('Exterior Style')) {
                                        Map<String, Object> exteriorStyleItem = (Map<String, Object>) AttrListItem;
                                        List<Object> exteriorStyleItemvalues = (List<Object>) exteriorStyleItem.get('Value');
                                        EndecaResponse.ExteriorStyle = exteriorStyleItemvalues;
                                    }                                        
                                    if(AttrStr.contains('WiFi Connect')) {
                                        EndecaResponse.IsWifiConnect = true;
                                    }
                                }
                            }
                            Map<String, Object> Relationships = (Map<String, Object>) Obj_1.get('Relationships');
                            if(Relationships != null) {
                                Map<String, Object> Accessories = (Map<String, Object>) Relationships.get('Accessories_');
                                if(Accessories != null) {
                                    List<Object> AccessoryList = new List<Object>();
                                    Set <String> AccessoryKeySet = new Set<String>();
                                    AccessoryKeySet = Accessories.keySet();
                                    for (String Key : AccessoryKeySet) {
                                        Map<String, Object> Accessory = (Map<String, Object>) Accessories.get(Key);
                                        AccessoryList.add(Accessory);
                                    }
                                    EndecaResponse.RelatedParts = AccessoryList;
                                }
                            } 
                            if(PartsUrl != null) {
                                EndecaResponse.PartsAndAccessoriesUrl = PartsUrl + Sku + '&results=appliance-models';
                            }
                            if(EServiceUrl != null) {
                                EndecaResponse.EServiceUrl = EServiceUrl + '?icid=AccountSpecPg_scheduleService';
                            }
                        }
                    }
            if(CommCategories != null) {
                EndecaResponse.CommercialCategories = CommCategories;
            }        
                            
            return EndecaResponse;
        } catch (Exception e) {
            throw e;
        }        
    }
    
    public class ProductsExtractResponse {
        @AuraEnabled public Map<String, Object> ProductDetails;
        @AuraEnabled public Object CommercialCategory;
    }
    
    public class EndecaResponse {
        @AuraEnabled public List<Object> Images;
        @AuraEnabled public List<Object> Documents;
        @AuraEnabled public List<Object> PartsWarranty;
        @AuraEnabled public List<Object> LaborWarranty;
        @AuraEnabled public List<Object> WarrantyNotes;  
        @AuraEnabled public List<Object> AppFilterProductType;
        @AuraEnabled public List<Object> ExteriorStyle;
        @AuraEnabled public Object ProductDescription;
        @AuraEnabled public Object Brand;
        @AuraEnabled public Boolean IsConsumerReady;
        @AuraEnabled public Boolean IsDuctless;        
        @AuraEnabled public Boolean IsWifiConnect;
        @AuraEnabled public List<Object> RelatedParts;
        @AuraEnabled public string EServiceUrl;
        @AuraEnabled public string DefaultImageUrl;        
        @AuraEnabled public string UserManualUrl;
        @AuraEnabled public string PartsAndAccessoriesUrl;
        @AuraEnabled public string ModelNumber; 
        @AuraEnabled public Object CommercialCategories;
        @AuraEnabled public List<Object> ProductCommercialCategory;
    }

    public class EndecaResponseDetails {
        @AuraEnabled public EndecaResponse ProductInfo;
        @AuraEnabled public Boolean Success;
    }
    
    public class ProductsResponse {
        @AuraEnabled public List<EndecaResponse> ProductsInfo;
       }
}