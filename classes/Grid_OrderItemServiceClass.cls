/**
 * Class that implements the Order Item service
 *
 * @Author  Salesforce
 *
 */
public with sharing class Grid_OrderItemServiceClass {
    public static void updateOrderItem(List<OrderItem> orderitems, Boolean isBefore) {
        if(null == orderitems) return;
        
        for(OrderItem oiIndex : orderitems) {
            oiIndex.vlocity_cmt__OneTimeCost__c = oiIndex.Grid_OneTimeCost__c;
            oiIndex.vlocity_cmt__OneTimeCostTotal__c = oiIndex.Grid_OneTimeCostTotal__c;
            oiIndex.vlocity_cmt__RecurringCost__c = oiIndex.Grid_RecurringCost__c;
            oiIndex.vlocity_cmt__RecurringCostTotal__c = oiIndex.Grid_RecurringCostTotal__c;
        }
        
        if(!isBefore) {
            update orderitems;
        }
    }
}