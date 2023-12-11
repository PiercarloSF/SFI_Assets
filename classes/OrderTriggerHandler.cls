public with sharing class OrderTriggerHandler extends TriggerHandler{

    Map<Id, Order> newOrdersMap = new Map<Id, Order>();
    Map<Id, Order> oldOrdersMap = new Map<Id, Order>();

    public OrderTriggerHandler() {
        this.newOrdersMap = (Map<Id, Order>) Trigger.newMap;
        this.oldOrdersMap = (Map<Id, Order>) Trigger.oldMap;
     
    }
    public override void beforeInsert() {
        Grid_OrderServiceClass.mapOrderCurrency(Trigger.new);
    }

    public override void beforeUpdate() {
        Date today = Date.today();
        List<Order> orderStatusChanged = new List<Order>();

        for (Id newOrderId : newOrdersMap.keySet()) {
            if (newOrdersMap.get(newOrderId).Status != oldOrdersMap.get(newOrderId).Status
                    && newOrdersMap.get(newOrderId).Status == 'Closed') {
               newOrdersMap.get(newOrderId).Grid_Closed_Date__c = today;
            }

            if (newOrdersMap.get(newOrderId).Status != oldOrdersMap.get(newOrderId).Status &&
             ((newOrdersMap.get(newOrderId).Status == 'Delivered' && oldOrdersMap.get(newOrderId).Status == 'Sent to SAP') ||
                    (newOrdersMap.get(newOrderId).Status == 'Closed' && oldOrdersMap.get(newOrderId).Status == 'Sent to SAP'))
            ) {
                newOrdersMap.get(newOrderId).Grid_Delivery_Date__c = today;
                }

            if (oldOrdersMap.get(newOrderId).Status == 'SAP Acknowledge') {
                if (newOrdersMap.get(newOrderId).Grid_Result__c == 'OK' ) {
                    newOrdersMap.get(newOrderId).Status = 'Sent to SAP';
                }   
                if (newOrdersMap.get(newOrderId).Grid_Result__c == 'KO') {
                    newOrdersMap.get(newOrderId).Status = 'SAP KO';
                }
            }

            if ((newOrdersMap.get(newOrderId).Status != oldOrdersMap.get(newOrderId).Status) && 
            (newOrdersMap.get(newOrderId).Status == 'Sent to SAP' || newOrdersMap.get(newOrderId).Status == 'SAP KO' ||newOrdersMap.get(newOrderId).Status == 'Closed') ) {
                orderStatusChanged.add(newOrdersMap.get(newOrderId));
            }
            
        }

        if(!orderStatusChanged.isEmpty()){
            Grid_OrderServiceClass.updateFlrOrchestrationStatus(orderStatusChanged);
        }
    }
    
    public override void afterUpdate() {
        List<Order> orderDelivered = new List<Order>();
        for (Id newOrderId : newOrdersMap.keySet()) {

            if (newOrdersMap.get(newOrderId).Status != oldOrdersMap.get(newOrderId).Status &&
             ((newOrdersMap.get(newOrderId).Status == 'Delivered' && oldOrdersMap.get(newOrderId).Status == 'Sent to SAP') ||
                    (newOrdersMap.get(newOrderId).Status == 'Closed' && oldOrdersMap.get(newOrderId).Status == 'Sent to SAP'))
            ) {
                orderDelivered.add(newOrdersMap.get(newOrderId));
                }
        }
        if(!orderDelivered.isEmpty()){
            Grid_OrderServiceClass.updateQuantityInContractLine(orderDelivered);
            Grid_OrderServiceClass.updateRelatedProductScheduelle(orderDelivered);
            Grid_OrderServiceClass.updateRevenueSchedulesActual(orderDelivered,false);
        }
    } 
}