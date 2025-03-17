public class DescribeDataCategoryGroupStructures {    
    final static String baseUrl=URL.getSalesforceBaseUrl().toExternalForm();
    public static List<DataCategory> getAll(String passedGroupName){
        List<DescribeDataCategoryGroupResult> describeCategoryResult;
        List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;
        List<DataCategory> dcList = new List<DataCategory>();
        try {
            //Making the call to the describeDataCategoryGroups to
            //get the list of category groups associated
            List<String> objType = new List<String>();
            objType.add('KnowledgeArticleVersion');         
            describeCategoryResult = Schema.describeDataCategoryGroups(objType);
            
            //Creating a list of pair objects to use as a parameter for the describe call
            List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
            
            //Looping throught the first describe result to create
            //the list of pairs for the second describe call
            for(DescribeDataCategoryGroupResult singleResult : describeCategoryResult){
                if(singleResult.getName()==passedGroupName){
                    DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
                    p.setSobject(singleResult.getSobject());
                    p.setDataCategoryGroupName(singleResult.getName());                
                    pairs.add(p);
                }
            }
            
            //describeDataCategoryGroupStructures()
            describeCategoryStructureResult = Schema.describeDataCategoryGroupStructures(pairs, false);            
            //Getting data from the result
            for(DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult){
                DataCategory [] topLevelCategories = singleResult.getTopCategories();
                //Recursively get all the categories
                List<DataCategory> allCategories = getAllCategories(toplevelCategories);
                for(DataCategory category : allCategories) {
                    dcList.add(category);
                }
            }
        } 
        catch (Exception e){
        }
        //return describeCategoryStructureResult;
        return dcList;
    }
    public static knowledgerestresource.dataItem getChildren(String passedGroupName){
        List<DescribeDataCategoryGroupResult> describeCategoryResult;
        List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;        
        knowledgeRestResource.dataItem di = new knowledgeRestResource.dataItem();
        try {
            //Making the call to the describeDataCategoryGroups to
            //get the list of category groups associated
            List<String> objType = new List<String>();
            objType.add('KnowledgeArticleVersion');         
            describeCategoryResult = Schema.describeDataCategoryGroups(objType);            
            //Creating a list of pair objects to use as a parameter for the describe call
            List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();   
            
            //Looping throught the first describe result to create
            //the list of pairs for the second describe call
            for(DescribeDataCategoryGroupResult singleResult : describeCategoryResult){
                if(singleResult.getName()=='Service_Categories'){
                    DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
                    p.setSobject(singleResult.getSobject());
                    p.setDataCategoryGroupName(singleResult.getName());                
                    pairs.add(p);
                }
            }                    
            describeCategoryStructureResult = Schema.describeDataCategoryGroupStructures(pairs, false);            
            //Getting data from the result
            for(DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult){
                DataCategory [] topLevelCategories = singleResult.getTopCategories();                
                for(DataCategory tlc : topLevelCategories){
                    if(tlc.getName()==passedGroupName){                        
                        //System.debug('parentname:'+tlc.getName());
                        setDataItem(di,tlc,'All',passedGroupName);
                        break;
                    }                    
                    for(DataCategory child : tlc.getChildCategories()){
                        if(child.getName()==passedGroupName){
                        	//System.debug('childName:'+child.getName());     
                        	setDataItem(di,child,tlc.getName(),passedGroupName);
                            break;
                        }
                        for(DataCategory childChild : child.getChildCategories()){
                            if(childChild.getName()==passedGroupName){ 
                                setDataItem(di,childChild,child.getName(),passedGroupName);
                                break;                                    
                            }                            
                        }
                    }
                }
            }
        }            
        catch (Exception e){}
        return di;
    }    
    private static void setDataItem(KnowledgeRestResource.DataItem di, DataCategory dc, String parentName,String passedGroupName){
        di.id=dc.getName();
        di.lookupName=dc.getLabel();
        di.links = new List<knowledgeRestResource.link>();
        di.links.add(new knowledgeRestResource.link('canonical',baseUrl+'/services/apexrest/serviceCategories/'+passedGroupName));
        di.parent = new knowledgerestresource.parent();
        di.parent.links = new List<knowledgeRestResource.link>();
        di.parent.links.add(new knowledgeRestResource.link('canonical',baseUrl+'/services/apexrest/serviceCategories/'+parentName));
	}
    private static DataCategory[] getAllCategories(DataCategory [] categories){
        if(categories.isEmpty()){
            return new DataCategory[]{};
                } else {
                    DataCategory [] categoriesClone = categories.clone();
                    DataCategory category = categoriesClone[0];
                    DataCategory[] allCategories = new DataCategory[]{category};
                        categoriesClone.remove(0);
                    categoriesClone.addAll(category.getChildCategories());
                    allCategories.addAll(getAllCategories(categoriesClone));
                    return allCategories;
                }
    }
}