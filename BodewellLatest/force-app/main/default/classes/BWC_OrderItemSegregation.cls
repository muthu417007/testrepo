/**
    * @author Sreevani
    * @date 11/07/2023
    * @description This class is used to seggregate order Items based on Zipcode and listof orderitems.
    */
    public class BWC_OrderItemSegregation {
            
             @AuraEnabled(Cacheable=true)
            Public Static  Map<String,List<OrderItemSummary>> getProductSegregation( String zipCode , String orderItemIdList)
            {
                try{
                String agentResponse = BWC_CartController.getZipcodeServiceInfo2(zipCode);
           /*     BWC_AgentResponseWrapper agentWrapperResponse = (BWC_AgentResponseWrapper)JSON.deserialize(agentResponse,BWC_AgentResponseWrapper.class);
                    if(agentWrapperResponse.response_message == 'SUCCESS' && agentWrapperResponse.response_status== 'SUCCESS'){
                        return null;
                    }  */
                Map<String,List<OrderItemSummary>> deliveryTypeVsOrderItem = new Map<String,List<OrderItemSummary>>();
                for(OrderItemSummary orderItem : [SELECT Id , BWC_Shipping_Method__c from OrderItemSummary ]){
                    
                    if(orderItem.BWC_Shipping_Method__c == 'SDS Delivery' ){
                               if(!deliveryTypeVsOrderItem.containsKey(orderItem.BWC_Shipping_Method__c)){
                                   deliveryTypeVsOrderItem.put(orderItem.BWC_Shipping_Method__c,new List<OrderItemSummary>());
                                   
                               }
                               deliveryTypeVsOrderItem.get(orderItem.BWC_Shipping_Method__c).add(orderItem);
                               
                           }
                        else if(orderItem.BWC_Shipping_Method__c == 'Home Delivery')
                               {   if(!deliveryTypeVsOrderItem.containsKey(orderItem.BWC_Shipping_Method__c)){
                                   deliveryTypeVsOrderItem.put(orderItem.BWC_Shipping_Method__c,new List<OrderItemSummary>());
                               }
                               deliveryTypeVsOrderItem.get(orderItem.BWC_Shipping_Method__c).add(orderItem);
                           }
                         else if(orderItem.BWC_Shipping_Method__c == 'sps')
                           {   if(!deliveryTypeVsOrderItem.containsKey(orderItem.Product2.BWC_Delivery_Type__c)){
                                   deliveryTypeVsOrderItem.put(orderItem.BWC_Shipping_Method__c,new List<OrderItemSummary>());
                               }
                               deliveryTypeVsOrderItem.get(orderItem.BWC_Shipping_Method__c).add(orderItem);
                           }
                         else if(orderItem.BWC_Shipping_Method__c == 'sps fee' )
                           {   
                               if(!deliveryTypeVsOrderItem.containsKey(orderItem.BWC_Shipping_Method__c)){
                                   deliveryTypeVsOrderItem.put(orderItem.BWC_Shipping_Method__c,new List<OrderItemSummary>());
                               }
                               deliveryTypeVsOrderItem.get(orderItem.Product2.BWC_Delivery_Type__c).add(orderItem);
                           } 
                          else if(orderItem.BWC_Shipping_Method__c == 'Will Call')
                           {   
                               if(!deliveryTypeVsOrderItem.containsKey('will call')){
                                   deliveryTypeVsOrderItem.put(orderItem.Product2.BWC_Delivery_Type__c,new List<OrderItemSummary>());
                               }
                               deliveryTypeVsOrderItem.get(orderItem.Product2.BWC_Delivery_Type__c).add(orderItem);
                           }  
                }      
                system.Debug('deliveryTypeVsOrderItem' +deliveryTypeVsOrderItem);
                 return deliveryTypeVsOrderItem;
                }
                catch(Exception e){
                     System.debug('Error in Agent API>>'+e.getLineNumber()+'>>>Message>>>'+e.getMessage());
                    return null;
                }
               
            }
            
          
            
        }