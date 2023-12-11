/**
 * Class to implement the trigger handler for Opportunity Object
 *
 * @Author  Salesforce
 *
 */
public class DeliveryPlanTriggerHandler extends TriggerHandler {

  Map<Id, DeliveryPlan__c> deliveryNewMap = new Map<Id, DeliveryPlan__c>();
  Map<Id, DeliveryPlan__c> deliveryOldMap = new Map<Id, DeliveryPlan__c>();
  List<DeliveryPlan__c> deliveryPlanList = new List<DeliveryPlan__c>();
  Set<Id> quoteIds = new Set<Id>();
  Set<Id> contractIds = new Set<Id>();

  public DeliveryPlanTriggerHandler() {
    deliveryNewMap = (Map<Id, DeliveryPlan__c>) Trigger.newMap;
    deliveryOldMap = (Map<Id, DeliveryPlan__c>) Trigger.oldMap;
    for (DeliveryPlan__c dlp : deliveryNewMap.values()) {
      if(dlp.Grid_Version__c == 1){
        quoteIds.add(dlp.Grid_Quote__c);
      }
      if(dlp.Grid_Version__c == 2){
        contractIds.add(dlp.Grid_Contract__c);
      }
    } 
  }

  public override void afterInsert() {
    if(!quoteIds.isEmpty()){
      Grid_QuoteServiceClass.createProductSchedule(deliveryNewMap.values(), quoteIds);
    }
    if(!contractIds.isEmpty()){
      Grid_WithoutSharingServiceClass.createProductSchedule(deliveryNewMap.values(), contractIds);
    } 
   }

  public override void afterUpdate() {
    for (Id newDlId : deliveryNewMap.keySet()) {
      if (
        deliveryNewMap.get(newDlId).Grid_ScheduleFrequency__c !=
        deliveryOldMap.get(newDlId).Grid_ScheduleFrequency__c ||
        deliveryNewMap.get(newDlId).Grid_ScheduleCount__c !=
        deliveryOldMap.get(newDlId).Grid_ScheduleCount__c ||
        deliveryNewMap.get(newDlId).Grid_StartDate__c !=
        deliveryOldMap.get(newDlId).Grid_StartDate__c
      ) {
        deliveryPlanList.add(deliveryNewMap.get(newDlId));
      }   
    }
    if (!deliveryPlanList.isEmpty()) {
      if(!quoteIds.isEmpty()){
        Grid_QuoteServiceClass.deleteProductSchedule(deliveryPlanList);
        Grid_QuoteServiceClass.createProductSchedule(deliveryPlanList, quoteIds);
      }
      if(!contractIds.isEmpty()){
        Grid_WithoutSharingServiceClass.deleteProductSchedule(deliveryPlanList);
        Grid_WithoutSharingServiceClass.createProductSchedule(deliveryPlanList, contractIds);
      }
    }
  }
}