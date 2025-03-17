public class BWC_ProductDataLoadScheduler implements schedulable{
	public void execute(SchedulableContext sc) {
        
        BWC_ProducDataLoadBatch l_ProductAttributeSetProduct = new BWC_ProducDataLoadBatch(Label.BWC_ProductAttributeSetProduct_Query,'ProductAttributeSetProduct');
        BWC_ProducDataLoadBatch l_ProductAttribute = new BWC_ProducDataLoadBatch(Label.BWC_ProductAttribute_Query,'ProductAttribute');
        BWC_ProducDataLoadBatch l_ProductCategoryProduct = new BWC_ProducDataLoadBatch(Label.BWC_ProductCategoryProduct_Query,'ProductCategoryProduct');
        BWC_ProducDataLoadBatch l_CommerceEntitlementProduct = new BWC_ProducDataLoadBatch(Label.BWC_CommerceEntitlementProduct_Query,'CommerceEntitlementProduct');
        
        l_ProductAttributeSetProduct.setNextBatch(l_ProductAttribute); 
        l_ProductAttribute.setNextBatch(l_ProductCategoryProduct);
        l_ProductCategoryProduct.setNextBatch(l_CommerceEntitlementProduct);
        l_CommerceEntitlementProduct.setNextBatch(null);
        
        Database.executeBatch(l_ProductAttributeSetProduct);
        
        /*BWC_ProductDataLoad_CAT_EP_Sheduler scheduler = new BWC_ProductDataLoad_CAT_EP_Sheduler();
            Datetime scheduleTime = Datetime.now().addSeconds(5);
            String cronExpression = scheduleTime.second() + ' ' + scheduleTime.minute() + ' ' + scheduleTime.hour() + ' ' +
                scheduleTime.day() + ' ' + scheduleTime.month() + ' ? ' + scheduleTime.year();
            String jobName = 'BWC_ProductDataLoad_CAT_EP_Sheduler';
            
            System.schedule(jobName, cronExpression, scheduler);
		*/
        
    }
}