/**
 * @description Revenue Schedule Controller 
 **/
public with sharing class Grid_RevenueScheduleController {
    /**
     * @description get revenue schedules
     * @param String id record id
     * @return List<Grid_Revenue> list of revenue schedules
     **/
    @AuraEnabled(cacheable=true)
    public static List<Grid_Revenue> getRevenueSchedules(String id){
        List<String> activatedStatus = new List<String>{'Activated', 'Closed/under warranty'};
        Id recordId = (Id) id;
        Id idToFilter = recordId;
        if(recordId == null){
            throw new AuraHandledException('Record Id is null');
        }
        String objectName;
        String status = '';
        String title = 'Revenue Calculation Version ';
        Integer versionNumber = 1;  
        Boolean showActuals = false;
        if (recordId != null) {
            objectName = recordId.getSObjectType().getDescribe().getName();

        }
        if(objectName != null && objectName == 'Contract'){
            Contract contract = [SELECT Id, Status,vlocity_cmt__QuoteId__c FROM Contract WHERE Id = :recordId];
            status = contract.Status;
            if(activatedStatus.contains(contract.Status)){
                title = title + '2';
                showActuals = true;
                versionNumber = 2;
            } else {
                idToFilter = contract.vlocity_cmt__QuoteId__c;
                title = title + '1';
            }
        } else {
            title = title + '1';
        }

        try {
            Map<String, List<Grid_RevenueSchedule__c>> revenueSchedulesMap = new Map<String, List<Grid_RevenueSchedule__c>>();
            List<Grid_Revenue> revenues = new List<Grid_Revenue>();
            Set<String> periodsSet = new Set<String>();
            String totalQuantity = '';
            List<Grid_RevenueSchedule__c> revenueScheduleList =  [
                SELECT
                    ID,
                    Name,
                    Grid_ContractLine__r.OpenMeterFormula__c, 
                    Grid_ContractLine__r.vlocity_cmt__Product2Id__r.Name,
                    Grid_ContractLine__r.vlocity_cmt__LineNumber__c, 
                    Grid_QuoteLineItem__r.OpenMeterFormula__c,
                    Grid_Metric__c,
                    Grid_PlannedAmount__c,
                    Grid_ActualAmount__c,
                    Grid_QuoteLineItem__r.Product2.Name,
                    Grid_QuoteLineItem__r.LineNumber,
                    Grid_Revenue__r.Grid_TotalPlannedAmount__c
                FROM Grid_RevenueSchedule__c
                WHERE (Grid_QuoteLineItem__r.Quote.Id = :idToFilter OR Grid_ContractLine__r.vlocity_cmt__ContractId__c = :idToFilter)
                AND (Grid_Version__c = :versionNumber)
            ];
            for (Grid_RevenueSchedule__c rs : revenueScheduleList) {
                if(rs.Grid_QuoteLineItem__r.Product2.Name == null || rs.Grid_QuoteLineItem__r.Product2.Name == ''){
                    if (!revenueSchedulesMap.containsKey(rs.Grid_ContractLine__r.vlocity_cmt__Product2Id__r.Name + '_' + rs.Grid_Metric__c + '_' + rs.Grid_ContractLine__r.vlocity_cmt__LineNumber__c)) {
                        revenueSchedulesMap.put(rs.Grid_ContractLine__r.vlocity_cmt__Product2Id__r.Name + '_' + rs.Grid_Metric__c +  '_' + rs.Grid_ContractLine__r.vlocity_cmt__LineNumber__c, new List<Grid_RevenueSchedule__c>());
                    }
                } else {
                    if (!revenueSchedulesMap.containsKey(rs.Grid_QuoteLineItem__r.Product2.Name + '_' + rs.Grid_Metric__c + '_' + rs.Grid_QuoteLineItem__r.LineNumber)) {
                        revenueSchedulesMap.put(rs.Grid_QuoteLineItem__r.Product2.Name + '_' + rs.Grid_Metric__c +  '_' + rs.Grid_QuoteLineItem__r.LineNumber, new List<Grid_RevenueSchedule__c>());
                    }
                }
          
                periodsSet.add(rs.Name);
                if(rs.Grid_QuoteLineItem__r.Product2.Name == null || rs.Grid_QuoteLineItem__r.Product2.Name == ''){
                    revenueSchedulesMap.get(rs.Grid_ContractLine__r.vlocity_cmt__Product2Id__r.Name + '_' + rs.Grid_Metric__c +  '_' + rs.Grid_ContractLine__r.vlocity_cmt__LineNumber__c).add(rs);
                } else {
                    revenueSchedulesMap.get(rs.Grid_QuoteLineItem__r.Product2.Name + '_' + rs.Grid_Metric__c +  '_' + rs.Grid_QuoteLineItem__r.LineNumber).add(rs);
                }
            }

            for (String revenueSchedule : revenueSchedulesMap.KeySet()) {
                Grid_Revenue revenue = new Grid_Revenue();
                revenue.productId = revenueSchedule;
                revenue.showActuals = showActuals;
                revenue.objectName = objectName;
                revenue.title = title;
                revenue.status = status;
                if(revenueSchedulesMap.get(revenueSchedule)[0].Grid_QuoteLineItem__r.Product2.Name == null || revenueSchedulesMap.get(revenueSchedule)[0].Grid_QuoteLineItem__r.Product2.Name == ''){
                    revenue.productName = revenueSchedulesMap.get(revenueSchedule)[0].Grid_ContractLine__r.vlocity_cmt__Product2Id__r.Name;
                } else {
                    revenue.productName = revenueSchedulesMap.get(revenueSchedule)[0].Grid_QuoteLineItem__r.Product2.Name;
                }
                revenue.periods = new List<String>(periodsSet);
                revenue.revenueSchedules = revenueSchedulesMap.get(revenueSchedule);
                Decimal total = 0;
                for (Grid_RevenueSchedule__c rs : revenueSchedulesMap.get(revenueSchedule)) {
                    if(rs.Grid_PlannedAmount__c != null){
                        total = total + rs.Grid_PlannedAmount__c;
                    }
                }
                revenue.totalRevenues = total;
                revenues.add(revenue);
              }
              return revenues;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

/**
   * @description create revenue
   * @param String qId quote id
   * @return void
 **/
  @AuraEnabled
  public static void generateRevenue(String qId) {
    Quote q = [SELECT Id, Grid_NumberOfHardwareProducts__c, Number_Delivery_Plan__c,CurrencyIsoCode FROM Quote WHERE Id =:qId];

    if(q != null && q.Grid_NumberOfHardwareProducts__c > 0 && q.Number_Delivery_Plan__c == 0){
      throw new AuraHandledException(Label.generate_delivery_plan_before_generate_revenue);
    }
    List<Revenue__c> revenueList = new List<Revenue__c>();
    revenueList = [
      SELECT Id, Grid_Count__c, Grid_StartDate__c, Grid_EndDate__c, Grid_Quote__c 
      FROM Revenue__c 
      WHERE Grid_Quote__c =:qId
    ];
    if(revenueList.isEmpty()){
      Revenue__c newRev = new Revenue__c(
        Grid_Quote__c = qId, 
        Grid_Version__c = 1,
        CurrencyIsoCode = q.CurrencyIsoCode
        );
      insert newRev;
      revenueList = [
      SELECT Id, Grid_Count__c, Grid_StartDate__c, Grid_EndDate__c, Grid_Quote__c 
      FROM Revenue__c 
      WHERE Grid_Quote__c =:qId
      ];
    }
    Set<Id> quoteIds = new Set<Id>();
    quoteIds.add(qId);
    Grid_QuoteServiceClass.createRevenueSchedule(revenueList, quoteIds);
    Grid_QuoteServiceClass.createHWRevenueSchedule(revenueList, quoteIds);
  }

  public static List<Revenue__c> getRevenueList(String contractId){
    List<Contract> contracts = [
        SELECT Id, vlocity_cmt__QuoteId__c
        FROM Contract
        WHERE Id = :contractId
    ];
    if(contracts.isEmpty()){
        throw new AuraHandledException('No contract found for this id');
    }
    String quoteId = contracts[0].vlocity_cmt__QuoteId__c;
    List<Revenue__c> revenueList = new List<Revenue__c>();
    revenueList = [
        SELECT Id, Grid_Count__c, Grid_StartDate__c, Grid_EndDate__c, Grid_Quote__c ,Grid_Contract__c
        FROM Revenue__c 
        WHERE (Grid_Contract__c =:contractId OR Grid_Quote__c =:quoteId) AND Grid_Version__c = 2
    ];
    if(revenueList.isEmpty()){
        throw new AuraHandledException('No revenue found for this contract');
    }
    return revenueList;
  }

  private static void deleteRevenueSchedules(Id revId){
    List<Grid_RevenueSchedule__c> revSchedToDelete = [
        SELECT Id, Grid_Revenue__c,Grid_Category__c
        FROM Grid_RevenueSchedule__c 
        WHERE Grid_Revenue__c = :revId AND Grid_Category__c ='Hardware'
    ];
    if(!revSchedToDelete.isEmpty()){
        try {
            delete revSchedToDelete;
        } catch (DmlException e) {
            throw new AuraHandledException(e.getMessage());        
        }
    }
  }

    private static List<Order> getOrders(String contractId){
        List<Order> orders = [
            SELECT Id, Status, ContractId
            FROM Order
            WHERE ContractId = :contractId AND (Status = 'Delivered' OR Status = 'Closed')
        ];
        return orders;
    }

  /**
   * @description refresh revenue schedules version 2
   * @param String contractId contract id
   * @return void
   * @throws AuraHandledException
   **/
  @AuraEnabled
  public static void refreshRevenueSchedulesV2(String contractId){
    try {
        // get contract related revenue (version 2)
        List<Revenue__c> revenueList = getRevenueList(contractId);
        // delete old revenue schedules
        deleteRevenueSchedules(revenueList[0].Id);
        Set<Id> contractIds = new Set<Id>();
        contractIds.add(contractId);
        // create new revenue schedules for the contract
        Grid_ContractServiceClass.createHWRevenueScheduleVersion2(revenueList,contractIds);
        // get orders related to the contract that are closed or delivered to calculate the actuals again
        List<Order> orders = getOrders(contractId);
        for(Order order : orders){
            List<Order> orderDelivered = new List<Order>();
            orderDelivered.add(order);
            Grid_OrderServiceClass.updateRevenueSchedulesActual(orderDelivered,true);
        }
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
  }

    /**
     * @description get contract status
     * @param String id record id
     * @return String status
     **/
    @AuraEnabled
    public static String getContractStatus(String id){
        String status = '';
        Id recordId = (Id) id;
        if(recordId == null){
            throw new AuraHandledException('Record Id is null');
        }
        String objectName;
        if (recordId != null) {
            objectName = recordId.getSObjectType().getDescribe().getName();
        }
        if(objectName != null && objectName == 'Contract'){
            Contract contract = [SELECT Id, Status FROM Contract WHERE Id = :recordId];
            status = contract.Status;
        }
        return status;
    }
}