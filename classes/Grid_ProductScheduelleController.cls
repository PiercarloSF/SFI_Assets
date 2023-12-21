/**
 * Class to implement the Product Schedules Controller
 *
 * @Author  Salesforce
 *
 */
public with sharing class Grid_ProductScheduelleController {
  /**
   * @description get list of delivery plan terms
   * @param String qId quote id
   * @return List<Grid_DeliveryPlanTerm>
   **/
  @AuraEnabled(cacheable=true)
  public static List<Grid_DeliveryPlanTerm> getProductSchedules(String qId) {
    List<String> activatedStatus = new List<String>{'Activated', 'Closed/under warranty'};
    Map<String, List<ProductSchedule__c>> productSchedulesMap = new Map<String, List<ProductSchedule__c>>();
    List<Grid_DeliveryPlanTerm> deliPlanTerms = new List<Grid_DeliveryPlanTerm>();
    Set<String> periodsSet = new Set<String>();
    String totalQuantity = '';
    Integer versionNumber = 1;
    String cStatus = '';
    String profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
    String kamProfile = Label.KAM_profile;

    if(qId.startsWithIgnoreCase('800')){
      Contract contract = [SELECT Id, Status FROM Contract WHERE Id = :qId];
      cStatus = contract.Status;
      if (!profileName.equals(kamProfile) && activatedStatus.contains(cStatus)) {
        versionNumber = 2;
      }
    }
    List<ProductSchedule__c> productScheduleList =  [
      SELECT
        ID,
        Name,
        Grid_PlannedQuantity__c,
        Grid_SalesPric__c,
        Grid_PlannedAmn__c,
        Grid_StartDate__c,
        Grid_QuoteLineItem__r.Product2.Name,
        Grid_EndDate__c,
        Grid_OrderSort__c,
        Grid_QuoteLineItem__r.Quantity,
        Grid_QuoteLineItem__r.LineNumber,
        Grid_QuoteLineItem__c,
        Grid_Actual_Quantity__c,
        Grid_Actual_Amount__c,
        Grid_Version__c,
        Grid_ContractLine__r.vlocity_cmt__ContractId__c,
        Grid_Delivery_Plan__c
      FROM ProductSchedule__c
      WHERE
        (Grid_QuoteLineItem__r.Quote.Id = :qId 
        OR Grid_ContractLine__r.vlocity_cmt__ContractId__c = :qId)
        AND (Grid_Version__c = :versionNumber)
      ORDER BY Grid_StartDate__c ASC
    ];
      System.debug(qId);
    for (ProductSchedule__c ps : productScheduleList) {
      if (!productSchedulesMap.containsKey(ps.Grid_QuoteLineItem__r.Product2.Name + '_' + ps.Grid_QuoteLineItem__r.LineNumber)) {
        productSchedulesMap.put(ps.Grid_QuoteLineItem__r.Product2.Name + '_' + ps.Grid_QuoteLineItem__r.LineNumber, new List<ProductSchedule__c>());
      }
      periodsSet.add(ps.Name);
      System.debug(ps.Grid_Delivery_Plan__c);
      productSchedulesMap.get(ps.Grid_QuoteLineItem__r.Product2.Name + '_' + ps.Grid_QuoteLineItem__r.LineNumber).add(ps);
    }
    for (String productSchedule : productSchedulesMap.KeySet()) {
      totalQuantity ='' + Integer.ValueOf(productSchedulesMap.get(productSchedule)[0].Grid_QuoteLineItem__r.Quantity);
      Grid_DeliveryPlanTerm dp = new Grid_DeliveryPlanTerm();
      dp.productNameId = productSchedule;
      dp.productName = productSchedulesMap.get(productSchedule)[0].Grid_QuoteLineItem__r.Product2.Name;
      dp.metric = '';
      dp.total = totalQuantity;
      dp.periods = new List<String>(periodsSet);
      dp.productSchedules = productSchedulesMap.get(productSchedule);
      dp.contractStatus = cStatus;
      dp.dpVersion = versionNumber;
      deliPlanTerms.add(dp);

    }

    return deliPlanTerms;
  }
  /**
   * @description refresh delivery plan
   * @param String qId quote id
   * @return void
   **/
  @AuraEnabled
  public static void refreshDeliveryPlan(String qId) {
    List<DeliveryPlan__c> deliveryPlan = [
      SELECT
        Id,
        Grid_Quote__c,
        Grid_StartDate__c,
        Grid_ScheduleCount__c,
        Grid_ScheduleFrequency__c
      FROM DeliveryPlan__c
      WHERE Grid_Quote__c = :qId
      AND (Grid_Version__c = 1)
    ];
    Set<Id> quoteIds = new Set<Id>();
    quoteIds.add(qId);
    Grid_QuoteServiceClass.deleteProductSchedule(deliveryPlan);
    Grid_QuoteServiceClass.createProductSchedule(deliveryPlan, quoteIds);
  }

}