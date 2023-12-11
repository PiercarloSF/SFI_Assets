trigger DeliveryPlanTrigger on DeliveryPlan__c (after insert,after update) {   
    new DeliveryPlanTriggerHandler().run();    
}