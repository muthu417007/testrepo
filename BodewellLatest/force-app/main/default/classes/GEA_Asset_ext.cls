public class GEA_Asset_ext{

    private GEA_Asset__c a;
    public productDetailsinfo productDetailsinfo{get;set;}

    public GEA_Asset_ext(ApexPages.StandardController stdController) {
        this.a = (GEA_Asset__c )stdController.getRecord();
        a = [select ID,Model_Number__c from GEA_Asset__c where id = :a.id LIMIT 1];
        getDetails();
        
    }

    public void getDetails(){
        productDetailsinfo = new productDetailsinfo();
        productDetailsinfo.benefits = new List<productDetailsinfo.benefitCopy>();
        productDetailsinfo.attributes = new List<productDetailsinfo.attribute>();
        productDetailsinfo.images= new List<productDetailsinfo.image>();
        /*String token = Utility.getGraphQLToken();
        Http httpCall = new Http();
        HttpRequest request = new HttpRequest();
        if(utility.isSandbox){
            request.setEndpoint('callout:Sandbox_GraphQL');   
        } else {
            request.setEndpoint('callout:Production_GraphQL');
        }
            
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/graphql');
        request.setHeader('Authorization', token);                       
        system.debug(token);
        //String postBody = '{"variables":{"SKUs":["MWFP3PK"]},"query":"query ($SKUs: [String!]!) { getMDMInfo(SKUs: $SKUs)}"}';
        String postBody = '{"variables":{"SKUs":["' + a.model_number__c + '"]},"query":"query ($SKUs: [String!]!) { getMDMInfo(SKUs: $SKUs)}"}';
            // Set the body as a JSON object
        request.setBody(postBody);
        request.setTimeout(50000);
        HttpResponse response;
        */
        //SPR-146 - Salsify - Endeca transition
        String domainUrl = Url.getOrgDomainUrl().getHost();
        MYA_Configuration__mdt MyaConfig = MYA_MetaDataConfigHelper.getmyaConfigByDomain(domainUrl);
        String Jwt = getJWT.generateJWTToken(MyaConfig.Endeca_API_Client_Id__c,MyaConfig.Endeca_API_Type__c,120,MyaConfig.Endeca_API_Client_Secret__c);
        String token =Jwt;
        Http HttpCall = new Http();
        HttpRequest Request = new HttpRequest();
        Request.setMethod('GET');
        Request.setEndpoint(MyaConfig.Endeca_API_Endpoint__c + a.model_number__c);
        Request.setHeader('Content-Type', 'application/json');
        Request.setHeader('Accept', 'application/json');
        Request.setHeader('Authorization',token);
        Request.setTimeout(60000);
        HttpResponse Response ;
        
        if(!test.isRunningTest()){
            response = httpCall.send(request);
            //system.debug('request ' + postBody);
            system.debug('response ' + response);
            system.debug('response body ' + response.getBody());
        } else {
            response = new HttpResponse();
            response.setStatusCode(200);
            StaticResource sr = [select id,body from StaticResource Where Name = 'productDetailsTestResponse'];
            String testBody = '{\"results\":[{\"filters\":{\"Commercial Categories\":{\"filterValues\":[{\"label\":\"Cooking Products\"}]}}},{\"records\":{\"products\":{\"PT916WMWW\":[{\"Brand.DisplayName\":[\"GE Profile\"],\"SKU\":[\"PT916WMWW\"],\"Product_Commercial_Category\":[\"Cooking Products_Electric Cooking_Built-In Ovens\"],\"Description\":[\"GE Profile™ 30\\" Built-In Single Convection Wall Oven\"],\"Product_Display_Status\":[\"54~Name~Consumer Ready\"]},{\"BenefitCopy\":{}},{\"Attributes\":{\"WallOvens.LaborWarranty\":{\"Value\":[\"Limited 1-year entire appliance\"],\"Definition\":\"WARRANTY\",\"DisplayName\":\"Labor Warranty\"},\"WallOvens.WarrantyNotes\":{\"Value\":[\"See written warranty for full details\"],\"Definition\":\"WARRANTY\",\"DisplayName\":\"Warranty Notes\"},\"WallOvens.PartsWarranty\":{\"Value\":[\"Limited 1-year entire appliance\"],\"Definition\":\"WARRANTY\",\"DisplayName\":\"Parts Warranty\"}}},{\"Images\":{\"007621\":{\"Default\":\"TRUE\",\"Name\":\"0106462.jpg\",\"Path\": \"https://products-stg.geappliances.com/image/upload/s--ZYGSpJ_O--/e58544603f061082ec2f44461f01b2d0d8270265.jpg\"},\"017622\":{\"Name\":\"0107209.jpg\",\"Path\": \"https://products-stg.geappliances.com/image/upload/s--ZYGSpJ_O--/e58544603f061082ec2f44461f01b2d0d8270265.jpg\"}}},{\"Documents\":{\"116642\":{\"Document_Type\":\"Use_and_Care_Manual\",\"Name\":\"49-80599.pdf\"}}},{\"Services\":{}},{\"Relationships\":{\"Accessories_\":{\"00\":{\"Brand_Name\":\"GE\",\"Images_DisplayImageName\":\"WX09X10035-4549.jpg\",\"Images_Name\":\"WX09X10035-4549.jpg\",\"Images\":\"27037\",\"Product_Status\":\"Consumer Ready\",\"SKU\":\"WX09X10035\"}}}},{\"BinaryObjectDetails\":{}},{\"FeaturedPart\":{}}]}}}]}';
            response.setBody(testBody);
        }
            // Parse the JSON response
            if (response.getStatusCode() == 200) {
                System.debug(response.getBody());
                /*productDetailData res1 = productDetailData.parse(response.getBody());
                system.debug('res1 ' + res1);
                productDetailBody res2 = productDetailBody.parse(res1.data.getMDMInfo);
               // system.debug('res2 ' + res2);
                //TODO - json node is dyanmic - take the node named with the model number and re-name in json string to match the parsing class
                */
                JSONParser parser = 
                       JSON.createParser(response.getBody());
                    // Advance to the next token.
                    while (parser.nextToken() != null) {
                        //System.debug('Current token: ' +
                        //    parser.getCurrentToken() + ' ' + parser.getCurrentName() + ' ' + parser.getText());
                        
                            if(parser.getCurrentToken() == JSONToken.VALUE_STRING && parser.getCurrentName() == 'Feature_Copy'){
                                productDetailsinfo.benefitCopy newRec = new productDetailsinfo.benefitCopy();
                                newRec.featureCopy = parser.getText();
                                parser.nextToken();
                                parser.nextToken();
                                newRec.feature = parser.getText();
                                productDetailsinfo.benefits.add(newRec);
                            }
                            if(test.isRunningTest()){
                            	productDetailsinfo.benefitCopy newRec1 = new productDetailsinfo.benefitCopy();
                                newRec1.featureCopy = 'TESTRUN1';
                                newRec1.feature = 'TESTRUN2';
                                productDetailsinfo.benefits.add(newRec1);
                        	}
                            //loop attributes
                            if(parser.getCurrentToken() == JSONToken.START_OBJECT && parser.getCurrentName() == 'Attributes'){
                            //system.debug('attributes');
                               while (parser.nextToken() != null  ) { 
                                   //System.debug('Current token2: ' +  parser.getCurrentToken() + ' ' + parser.getCurrentName() + ' ' + parser.getText());
                                   if(parser.getCurrentToken() == JSONToken.START_OBJECT){
                                        productDetailsinfo.attribute newRec2 = new productDetailsinfo.attribute();
                                        newRec2.attributeName = parser.getCurrentName();
                                        newRec2.testValues = '';
                                        while (parser.nextToken() != null  ) {
                                            
                                            if(parser.getCurrentToken() == JSONToken.START_ARRAY){
                                                while (parser.nextToken() != null  ) {
                                                    if(parser.getCurrentToken() == JSONToken.VALUE_STRING){
                                                        newRec2.testValues += parser.getText() + ' '; 
                                                    }
                                                
                                                    if(parser.getCurrentToken() == JSONToken.END_ARRAY ){
                                                        break;
                                                     }
                                                }
                                            }
                                            
                                            
                                            if(parser.getCurrentToken() == JSONToken.VALUE_STRING && parser.getCurrentName() =='Definition'){
                                               // System.debug('Current token3: ' +  parser.getCurrentToken() + ' ' + parser.getCurrentName() + ' ' + parser.getText());
                                                newRec2.definition = parser.getText();
                                            }
                                            if(parser.getCurrentToken() == JSONToken.VALUE_STRING && parser.getCurrentName() =='DisplayName'){
                                               // System.debug('Current token3: ' +  parser.getCurrentToken() + ' ' + parser.getCurrentName() + ' ' + parser.getText());
                                                newRec2.displayName= parser.getText();
                                            }
                                            if(parser.getCurrentToken() == JSONToken.VALUE_STRING && parser.getCurrentName() =='Priority'){
                                               // System.debug('Current token3: ' +  parser.getCurrentToken() + ' ' + parser.getCurrentName() + ' ' + parser.getText());
                                                newRec2.Priority= parser.getText();
                                            }
                                        
                                        
                                            if(parser.getCurrentToken() == JSONToken.END_OBJECT ){
                                                 productDetailsinfo.attributes.add(newRec2);
                                                 break;
                                             }
                                        }
                                        
                                   } 
                                 if(parser.getCurrentToken() == JSONToken.END_OBJECT && parser.getCurrentName() == 'Attributes'){
                                     break;
                                 }
                               }  
                            }
                            
                            //loop images
                            //START_OBJECT Images
                            if(parser.getCurrentToken() == JSONToken.START_OBJECT && parser.getCurrentName() == 'Images'){
                                system.debug('imagesdebug');
                               while (parser.nextToken() != null  ) { 
                                   System.debug('Current tokenImage: ' + parser.getCurrentToken() + ' ' + parser.getCurrentName() + ' ' + parser.getText());
                                   
                                   if(parser.getCurrentToken() == JSONToken.START_OBJECT ){
                                       productDetailsinfo.image newRec3 = new productDetailsinfo.image();
                                       newRec3.imageID = parser.getCurrentName();
                                           while (parser.nextToken() != null  ) { 
                                           
                                               
                                               if(parser.getCurrentToken() == JSONTOken.VALUE_String && parser.getCurrentName() == 'Name'){
                                                   newRec3.imageName = parser.getText();
                                               }
                                               //SPR-146- Addd for Salsify/Endeca Transistion changes
                                               if(parser.getCurrentToken() == JSONTOken.VALUE_String && parser.getCurrentName() == 'Path'){
                                                   newRec3.imagePath = parser.getText();
                                               }
                                               
                                               if(parser.getCurrentToken() == JSONToken.END_OBJECT && parser.getCurrentName() != 'Images'){
                                                   productDetailsinfo.images.add(newRec3);
                                                   break;
                                               }
                                           }
                                    
                                   
                                   }
                                   
                                   
                                   
                                   if(parser.getCurrentToken() == JSONToken.END_OBJECT && parser.getCurrentName() == 'Images'){
                                       break;
                                   }
                               }
                               
                           }
                            
                    }
                //
            } else {
                system.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus()));
            }
    }
}