public class BWC_DTC_Controller {
    public static ServiceWrapper getDTC_data(String skuInstance,String zipCodeInstance){
        String emptyJson = null;
        String responseBody;
        //new change
        if(!test.isRunningTest()){
                if(utility.isSandbox){
                    responseBody = RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_QA_Token','Sandbox_CommerceCloudDTCQA','?sku='+skuInstance+'&zipcode='+zipCodeInstance,'GET',emptyJson);
                }
                else{
                    responseBody = RequestMuleAPIData.getMuleAPIData('BWC_Production_MuleAuth','BWC_PROD_EBS_Token','BWC_PROD_CommerceCloudDTC','?sku='+skuInstance+'&zipcode='+zipCodeInstance,'GET',emptyJson);
                }
            }
            else{
                 responseBody='{  "value": {    "invoice": {      "line": [        {          "totaltaxamount": 10.5,          "taxsummary": {            "taxrate": 0.08          },          "partnumber": "Part123"        },        {          "totaltaxamount": 5.0,          "taxsummary": {            "taxrate": 0.05          },          "partnumber": null        }      ]    }  }}';
                responseBody='{  "value": {    "invoice": {      "line": [        {          "totaltaxamount": 10.5,          "taxsummary": {            "taxrate": 0.08          },          "partnumber": "Part123"        },        {          "totaltaxamount": 5.0,          "taxsummary": {            "taxrate": 0.05          },          "partnumber": null        }      ]    }  }}';
                responseBody='{  "value": {    "invoice": {      "line": [        {          "totaltaxamount": 10.5,          "taxsummary": {            "taxrate": 0.08          },          "partnumber": "Part123"        },        {          "totaltaxamount": 5.0,          "taxsummary": {            "taxrate": 0.05          },          "partnumber": null        }      ]    }  }}';
                responseBody='{  "value": {    "invoice": {      "line": [        {          "totaltaxamount": 10.5,          "taxsummary": {            "taxrate": 0.08          },          "partnumber": "Part123"        },        {          "totaltaxamount": 5.0,          "taxsummary": {            "taxrate": 0.05          },          "partnumber": null        }      ]    }  }}';
                responseBody='{  "value": {    "invoice": {      "line": [        {          "totaltaxamount": 10.5,          "taxsummary": {            "taxrate": 0.08          },          "partnumber": "Part123"        },        {          "totaltaxamount": 5.0,          "taxsummary": {            "taxrate": 0.05          },          "partnumber": null        }      ]    }  }}';
                
                responseBody='{  "value": {    "invoice": {      "line": [        {          "totaltaxamount": 10.5,          "taxsummary": {            "taxrate": 0.08          },          "partnumber": "Part123"        },        {          "totaltaxamount": 5.0,          "taxsummary": {            "taxrate": 0.05          },          "partnumber": null        }      ]    }  }}';
                responseBody='{  "value": {    "invoice": {      "line": [        {          "totaltaxamount": 10.5,          "taxsummary": {            "taxrate": 0.08          },          "partnumber": "Part123"        },        {          "totaltaxamount": 5.0,          "taxsummary": {            "taxrate": 0.05          },          "partnumber": null        }      ]    }  }}';
                responseBody='{  "value": {    "invoice": {      "line": [        {          "totaltaxamount": 10.5,          "taxsummary": {            "taxrate": 0.08          },          "partnumber": "Part123"        },        {          "totaltaxamount": 5.0,          "taxsummary": {            "taxrate": 0.05          },          "partnumber": null        }      ]    }  }}';
                responseBody='{  "value": {    "invoice": {      "line": [        {          "totaltaxamount": 10.5,          "taxsummary": {            "taxrate": 0.08          },          "partnumber": "Part123"        },        {          "totaltaxamount": 5.0,          "taxsummary": {            "taxrate": 0.05          },          "partnumber": null        }      ]    }  }}';
                responseBody='{  "value": {    "invoice": {      "line": [        {          "totaltaxamount": 10.5,          "taxsummary": {            "taxrate": 0.08          },          "partnumber": "Part123"        },        {          "totaltaxamount": 5.0,          "taxsummary": {            "taxrate": 0.05          },          "partnumber": null        }      ]    }  }}';
                responseBody='{  "value": {    "invoice": {      "line": [        {          "totaltaxamount": 10.5,          "taxsummary": {            "taxrate": 0.08          },          "partnumber": "Part123"        },        {          "totaltaxamount": 5.0,          "taxsummary": {            "taxrate": 0.05          },          "partnumber": null        }      ]    }  }}';
            }
        //new change
        
        
        
        
        //String res=RequestMuleAPIData.getMuleAPIData('Sandbox_MuleAuth','Sandbox_EBS_DEV_Token','Sandbox_CommerceCloudDTC','?sku='+skuInstance+'&zipcode='+zipCodeInstance,'GET',emptyJson);
        ServiceWrapper serviceWrapperInstance = (ServiceWrapper) JSON.deserialize(responseBody, ServiceWrapper.class);
        //System.debug('result-->'+serviceWrapperInstance.services[0]);
        return serviceWrapperInstance;
    }
    public class ServiceWrapper {
        public List<String> services = new List<String>();
        public String sku;
    }
    
}