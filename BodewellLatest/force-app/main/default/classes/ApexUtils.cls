public with sharing class ApexUtils {
    /**
     * @description Helper function that relates the parent product to the child product
     * @param {Id} parentId
     * @param {Id} childId
     * @param {string} attributeApiName - the API name of the field used for variations
     */
    public static void createProductVariationRelationship(Id parentId, Id childId, String attributeApiName) {
        //Get the Id of the 'Color' attribute
        FieldDefinition[] ed = [SELECT DurableId from FieldDefinition
                                WHERE EntityDefinition.QualifiedApiName = 'ProductAttribute'
                                AND (QualifiedApiName = :attributeApiName)];

        String durableId = ed[0].DurableId;
        String attributeId = durableId.substringAfter('.');

        ProductAttributeSet pas = new ProductAttributeSet(
            DeveloperName = 'Test',
            MasterLabel = 'Test'
        );
        insert pas;

        ProductAttributeSetItem pasi = new ProductAttributeSetItem(
            ProductAttributeSetId = pas.id,
            Sequence = 0,
            Field = attributeId
        );
        insert pasi;

        ProductAttributeSetProduct pasp = new ProductAttributeSetProduct(
            ProductId = parentId,
            ProductAttributeSetId = pas.Id
        );
        insert pasp;

        ProductAttribute pa = new ProductAttribute(
            ProductId = childId,
            VariantParentId = parentId,
            Color__c = ApexUtils.getPicklistValues('ProductAttribute', attributeApiName)[0]
        );
        insert pa;
    }

    /**
     * @description helper method to get the values from a picklist field
     */
    public static String[] getPicklistValues(String object_name, String field_name) {
        String[] values = new String[]{};
        String[] types = new String[]{object_name};
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        for(Schema.DescribeSobjectResult res : results) {
           for (Schema.PicklistEntry entry : res.fields.getMap().get(field_name).getDescribe().getPicklistValues()) {
              if (entry.isActive()) {values.add(entry.getValue());}
           }
        }
        return values;
     }
}