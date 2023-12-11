/**
 * Class that implements the services needed without sharing
 *
 * @Author  Salesforce
 *
 */
public without sharing class Grid_WithoutSharingServiceClass {

  /**
   * @description clone the delivery plan related to contract and set the version of the cloned one to 2
   * @param String contractId 
   * @return void
  **/
  public static void cloneDeliveryPlan(Set<Id> activatedContractIds) {
    Id deliveryPlanId;
    List<ProductSchedule__c> clonedProdSchedules = new List<ProductSchedule__c>();
    List<DeliveryPlan__c> clonedDelivery = new List<DeliveryPlan__c>();
    List<DeliveryPlan__c> deliveryPlans =  [SELECT id, Grid_ActivatedDate__c, Grid_Contract__c, CreatedById, CurrencyIsoCode, Grid_EndDate__c,  Grid_Version__c, LastModifiedById, Name, 
                                            Grid_Quote__c, Grid_ScheduleCount__c, Grid_ScheduleFrequency__c, Grid_StartDate__c,Grid_IsCloned__c
                                            FROM DeliveryPlan__c 
                                            WHERE Grid_Contract__r.Id  IN :activatedContractIds 
                                            AND Grid_Version__c = 1 ];
    for(DeliveryPlan__c dlp : deliveryPlans){
      DeliveryPlan__c deliveryPlanCloned = dlp.clone();  
      deliveryPlanId = dlp.Id; 
      deliveryPlanCloned.Grid_Version__c = 2;
      deliveryPlanCloned.Grid_IsCloned__c = true;
      clonedDelivery.add(deliveryPlanCloned);
    }
    if(!clonedDelivery.isEmpty()){
        try {
        insert clonedDelivery;
        system.debug('#### clonedDelivery '+ clonedDelivery);
        }catch(DMLException e) {
          system.debug('#### exception '+ e);
            ApexPages.addMessages(e);
        } 
    }    
}

    /**
   * @description add contract owner to Account Team
   * @param contract 
   * @return void
  **/
  public static void updateAccountTeam(List<Contract> oldContractList) {
    List<AccountTeamMember> newAccountTeamMembers = new List<AccountTeamMember>();
    for (Contract oldContract : oldContractList) {
        AccountTeamMember newATM = new AccountTeamMember();
        newATM.accountId = oldContract.accountId;
        newATM.userId = oldContract.ownerId;
        newATM.accountAccessLevel = 'Edit';
        newATM.caseAccessLevel = 'None';
        newATM.opportunityAccessLevel = 'None';
        newAccountTeamMembers.add(newATM);
    }
    if(!newAccountTeamMembers.isEmpty()){
      insert newAccountTeamMembers;
    }
  }

     /**
   * @description create product schedule related on contract line items
   * @param List Delivery Plan, contractsIds
   * @return void
  **/
  public static void createProductSchedule(List<Deliveryplan__c> lstDeliveryPlan,Set<Id> contractsIds) {
    List<ProductSchedule__c> prodList = new List<ProductSchedule__c>();
    date ddp;
    date edp;
    String prodName;

    Map<Id, List<vlocity_cmt__ContractLineItem__c>> contractLineItemMap = new Map<Id, List<vlocity_cmt__ContractLineItem__c>>();
    
    List<vlocity_cmt__ContractLineItem__c> contractLineItems = [
      SELECT Id,vlocity_cmt__ContractId__c, vlocity_cmt__Quantity__c, vlocity_cmt__QuoteLineItem__r.Product2.Name,vlocity_cmt__QuoteLineItem__r.Product2.Grid_Category__c, vlocity_cmt__OneTimeCharge__c,vlocity_cmt__Product2Id__r.Name
      FROM vlocity_cmt__ContractLineItem__c 
      WHERE vlocity_cmt__ContractId__c IN :contractsIds AND vlocity_cmt__QuoteLineItem__r.Product2.Grid_Category__c = 'Hardware'
    ];

    for (vlocity_cmt__ContractLineItem__c contractItem : contractLineItems) {
      if (contractLineItemMap.containsKey(contractItem.vlocity_cmt__ContractId__c)) {
        contractLineItemMap.get(contractItem.vlocity_cmt__ContractId__c).add(contractItem);
      } else {
        contractLineItemMap.put(contractItem.vlocity_cmt__ContractId__c, new List<vlocity_cmt__ContractLineItem__c>{ contractItem });
      }
    }
    Set<Id> quoteIds = new Set<Id>();
    for(DeliveryPlan__c dlp : lstDeliveryPlan){
      quoteIds.add(dlp.Grid_Quote__c);
    }
    List<ProductSchedule__c> productSchedules = [SELECT Id,CreatedDate,Name,Grid_ContractLine__c,Grid_QuoteLineItem__c,Grid_StartDate__c,Grid_Version__c,Grid_PlannedQuantity__c,Grid_Delivery_Plan__c,
                                    Grid_PlannedAmn__c,Total_Quantity__c,Grid_EndDate__c,Grid_SalesPric__c,Grid_QuoteLineItem__r.QuoteId
                                    FROM ProductSchedule__c WHERE
                                    Grid_QuoteLineItem__r.QuoteId in :quoteIds
                                    AND Grid_Version__c = 1 order by CreatedDate];
    Map<Id, List<ProductSchedule__c>> quoteLineItemToProductSchedulesMap = new Map<Id, List<ProductSchedule__c>>();
    for (ProductSchedule__c productSchedule : productSchedules) {
      if (quoteLineItemToProductSchedulesMap.containsKey(productSchedule.Grid_QuoteLineItem__c)) {
        quoteLineItemToProductSchedulesMap.get(productSchedule.Grid_QuoteLineItem__c).add(productSchedule);
      } else {
        quoteLineItemToProductSchedulesMap.put(productSchedule.Grid_QuoteLineItem__c, new List<ProductSchedule__c>{ productSchedule });
      }
    }
    for (DeliveryPlan__c dlp : lstDeliveryPlan) {
      Integer j = 0;
      Integer orderSort = 0;

      List<vlocity_cmt__ContractLineItem__c> contractLineItemByDeliveryPl = contractLineItemMap.get(dlp.Grid_Contract__c);
      if (contractLineItemMap.size() > 0) {
        for (vlocity_cmt__ContractLineItem__c contractItem :  contractLineItemByDeliveryPl) {
          if(dlp.Grid_IsCloned__c == true){
            for (ProductSchedule__c prodSchedule : quoteLineItemToProductSchedulesMap.get(contractItem.vlocity_cmt__QuoteLineItem__c)) {
              ProductSchedule__c clonnedProdSchedule = prodSchedule.clone();
              clonnedProdSchedule.Grid_ContractLine__c = contractItem.Id;
              clonnedProdSchedule.Grid_Version__c = 2;
              clonnedProdSchedule.Grid_Delivery_Plan__c = dlp.Id;
              prodList.add(clonnedProdSchedule);
            }
          }else{
            ddp = dlp.Grid_StartDate__c;
            edp = dlp.Grid_StartDate__c;
            j = 0;
            for (integer i = 0; i < dlp.Grid_ScheduleCount__c; i++) {
              if (dlp.Grid_ScheduleFrequency__c == 'One time') {
                ddp = j > 0 ? ddp.addDays(1) : ddp;
                edp = ddp.addDays(1);
                prodName = ddp.format();
              }

              if (dlp.Grid_ScheduleFrequency__c == 'Weekly') {
                ddp = j > 0 ? ddp.addDays(7) : ddp;
                edp = ddp.addDays(7);
                prodName = ddp.format() + '-' + edp.format();
              } 
              if (dlp.Grid_ScheduleFrequency__c == 'Monthly') {
                ddp = j > 0 ? ddp.addMonths(1) : ddp;
                edp = ddp.addMonths(1);
                prodName =
                  DateTime.newInstance(ddp.year(), ddp.month(), ddp.day())
                    .format('MMM') + -+ddp.year();
              }

              if (dlp.Grid_ScheduleFrequency__c == 'Yearly') {
                ddp = j > 0 ? ddp.addYears(1) : ddp;
                edp = ddp.addYears(1);
                prodName = DateTime.newInstance(
                    ddp.year(),
                    ddp.month(),
                    ddp.day()
                  )
                  .format('YYYY');
              }
              prodList.add(
                new ProductSchedule__c(
                  Grid_OrderSort__c = ++orderSort,
                  Name = prodName,
                  Grid_ContractLine__c = contractItem.Id,
                  Grid_QuoteLineItem__c = contractItem.vlocity_cmt__QuoteLineItem__c ,
                  Grid_PlannedQuantity__c = Integer.valueOf(
                    contractItem.vlocity_cmt__Quantity__c / dlp.Grid_ScheduleCount__c
                  ),
                  Grid_SalesPric__c = contractItem.vlocity_cmt__OneTimeCharge__c,
                  Grid_StartDate__c = ddp,
                  Grid_EndDate__c = edp,
                  Total_Quantity__c = contractItem.vlocity_cmt__Quantity__c,
                  Grid_Version__c	 = dlp.Grid_Version__c,
                  Grid_Delivery_Plan__c = dlp.Id
                )
              );
              j++;
            }
          }
        }
        for (vlocity_cmt__ContractLineItem__c contractItem : contractLineItemByDeliveryPl) {
          Grid_QuoteServiceClass.adjustPlannedQuantities(contractItem.Id, prodList);
        }
      }
    }
    if (prodList.size() > 0)
      insert prodList;
  }

    /**
   * @description delete product schedules 
   * @param Map delivery plan
   * @return void
  **/
  public static void deleteProductSchedule(List<Deliveryplan__c> lstDeliveryPlan) {
    Map<Id, List<ProductSchedule__c>> deliveryPlanToProductSchedulesMap = Grid_ServiceClass.getDeliveryPlanToProductSchedules(lstDeliveryPlan);
    for (Id deliveryPlanId : deliveryPlanToProductSchedulesMap.keySet()) {
      List<ProductSchedule__c> productSchedulesToDelete = deliveryPlanToProductSchedulesMap.get(deliveryPlanId);
      if (!productSchedulesToDelete.isEmpty()) {
          delete productSchedulesToDelete;
      }
    }
  }   
  }