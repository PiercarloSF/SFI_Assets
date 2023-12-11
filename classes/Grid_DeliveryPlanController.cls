/**
 * Class to implement the Delivery Plan Controller
 *
 * @Author  Salesforce
 *
 */
public without sharing class Grid_DeliveryPlanController {
    /**
     * @description get list of delivery plans
     * @param String cId contract id
     * @return List<DeliveryPlan__c>
     **/
    @AuraEnabled(cacheable=true)
    public static List<DeliveryPlan__c> getDeliveryPlans(String cId, Integer Cversion) {
      List<DeliveryPlan__c> deliveryPlans = [
          SELECT Grid_ScheduleFrequency__c, Grid_ScheduleCount__c, Grid_StartDate__c, Grid_EndDate__c
          FROM DeliveryPlan__c 
          WHERE Grid_Contract__r.Id = :cId AND Grid_Version__c = :Cversion
      ];
      return deliveryPlans;
  }

    /**
     * @description update delivery plans with new fields
     * @param String deliveryPlanId, Map<String, Object> fieldsToUpdate
     * @return void
     **/
    @AuraEnabled
    public static void updateDeliveryPlan(String deliveryPlanId,Map<String, Object> fieldsToUpdate) {
        List<DeliveryPlan__c> deliveryPlans = [
            SELECT Grid_ScheduleFrequency__c, Grid_ScheduleCount__c, Grid_StartDate__c, Grid_EndDate__c, Grid_Start_Month__c,Grid_IsCloned__c
            FROM DeliveryPlan__c 
            WHERE Id = :deliveryPlanId Limit 1
        ];
        if (deliveryPlans[0] != null) {
            for (String fieldName : fieldsToUpdate.keySet()) {
                Object fieldValue = fieldsToUpdate.get(fieldName);
                if (fieldValue instanceof String && Schema.getGlobalDescribe().get('DeliveryPlan__c').getDescribe().fields.getMap().get(fieldName).getDescribe().getType() == Schema.DisplayType.Date) {
                    Date convertedDate = Date.valueOf((String)fieldValue);
                    deliveryPlans[0].put(fieldName, convertedDate);
                } else if(fieldValue instanceof String && Schema.getGlobalDescribe().get('DeliveryPlan__c').getDescribe().fields.getMap().get(fieldName).getDescribe().getType() == Schema.DisplayType.Double) {
                    deliveryPlans[0].put(fieldName, Decimal.valueOf((String)fieldValue));
                } else {
                    deliveryPlans[0].put(fieldName, fieldValue);
                }     
            }

        update deliveryPlans;

        }
    }
  
  }