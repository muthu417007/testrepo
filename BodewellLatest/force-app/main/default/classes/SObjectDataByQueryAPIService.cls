/********************************************************************************************************************
 * * @author      :   Monu Samrat
 * @company      :  GEA
 * @JiraTicket     :  CCOE-509 
 * @description :   Changing the CCPA API from GET to POST (as GET request may save the PII data in network logs)
 					 for both SFSC and Ductless automations that are written for CCPA. A custom label is created with
					name SFSC_CCPI_POST_LIMIT for making the  limits value default to 100. 
 * @testClass   :   SObjectDataByQueryAPIServiceTest
 * ********************************************************************************************************* */
@RestResource(urlMapping='/sobject-data/query/v1/*')
global with sharing  class  SObjectDataByQueryAPIService {
    @HttpPost
     /*this method is taking four parameters. This method is returning the sobject list based on the paramerters*/
   global static list<sobject>  doPost(string [] fieldList, string objName ,  string criteria , integer limits ){  
        String qry = 'SELECT ID';
            for(string f: fieldList){
                qry +=  ', '+ f  ;      
            }
            qry +=' from ' + objName;
       
       if( criteria !=null){
           qry+= ' where '+ Criteria ;
       }
       if(limits!= null )
       {
           qry+= '  limit ' +  limits ;
       }
       string customLabelValue = System.Label.SFSC_CCPI_POST_LIMIT;
       if(limits== null){ qry+= '  limit ' +  customLabelValue; }
            //system.debug('@@@@@'+ qry);
            list<sobject> objlist= database.query(qry);
         //  system.debug('@@@@@@@'+ objlist );
            return objlist;
     
   }  
}