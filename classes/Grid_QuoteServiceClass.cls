/**
 * Class that implements the Quote service
 *
 * @Author  Salesforce
 *
 */
public with sharing class Grid_QuoteServiceClass{
  /**
   * @description calculates the number of quote line items related to HW products
   * @param List Quote 
   * @return void
  **/
  public static void handleDeliveryPlanCheck(List<Quote> quotes) {
    Set<Id> quoteIds = new Set<Id>();
    for (Quote q : quotes) {
      quoteIds.add(q.Id);
    }
    Map<Id, List<quotelineitem>> listQuotelineitemMap = new Map<Id, List<quotelineitem>>();
    List<quotelineitem> listQuotelineitem = [SELECT Id, QuoteId, Product2.Grid_Category__c
                                              FROM quotelineitem
                                              WHERE QuoteId IN :quoteIds AND Product2.Grid_Category__c = 'Hardware'
                                            ];
    for (quotelineitem qItem : ListQuotelineitem) {
      if (ListQuotelineitemMap.containsKey(qItem.QuoteId)) {
        ListQuotelineitemMap.get(qItem.QuoteId).add(qItem);
      } else {
        ListQuotelineitemMap.put(
          qItem.QuoteId,
          new List<quotelineitem>{ qItem }
        );
      }
    }
    for (Quote q : quotes) {
      q.Grid_NumberOfHardwareProducts__c = 0;
      if (ListQuotelineitemMap.get(q.Id) != null) {
        q.Grid_NumberOfHardwareProducts__c = ListQuotelineitemMap.get(q.Id)
          .size();
      }
    }
  }
  /**
   * @description auto populate Quote data 
   * @param List Quote, Set quote Ids
   * @return void
  **/
  public static void updateQuote(List<Quote> quotes, Set<Id> ids){
    Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
    Map<String, List<vlocity_cmt__PriceList__c>> priceListMap = Grid_ServiceClass.getPriceList();
    for (Opportunity opp : [SELECT Id,
                            vlocity_cmt__PriceListId__c,
                            CurrencyIsoCode,
                            Grid_CurrencyCountry__c,
                            (SELECT id, Grid_QuoteAutoNumber__c FROM quotes)
                          FROM Opportunity
                          WHERE Id IN :ids
                        ]) {
      oppMap.put(opp.id, opp);
    }
    for (Quote qq : quotes) {
      qq.CurrencyIsoCode = oppMap.get(qq.OpportunityId).CurrencyIsoCode;
      List<vlocity_cmt__PriceList__c> priceListsByCurrency = new List<vlocity_cmt__PriceList__c>();
      if(priceListMap.get(oppMap.get(qq.OpportunityId).CurrencyIsoCode) != null){
        priceListsByCurrency = priceListMap.get(oppMap.get(qq.OpportunityId).CurrencyIsoCode);
      }
      if (priceListsByCurrency.size() == 1) {
        qq.vlocity_cmt__PriceListId__c = priceListsByCurrency.get(0).Id;
      } else if (priceListsByCurrency.size() > 1) {
        for (vlocity_cmt__PriceList__c pr : priceListsByCurrency) {
          if (
            pr.Name != null &&
            pr.Name.contains(
              oppMap.get(qq.OpportunityId).Grid_CurrencyCountry__c
            )
          ) {
            qq.vlocity_cmt__PriceListId__c = pr.Id;
          }
        }
      }
      if (oppMap.get(qq.OpportunityId).quotes != null) {
        qq.Grid_QuoteAutoNumber__c =
          getMaxAutoNumber(oppMap.get(qq.OpportunityId).quotes) + 1;
      } else {
        qq.Grid_QuoteAutoNumber__c = 1;
      }
    }
  }
  /**
   * @description get the maximum of quote auto number 
   * @param List Quote
   * @return void
  **/
  private static Integer getMaxAutoNumber(List<Quote> quotes) {
    Integer max = 0;
    for (Quote q : quotes) {
      if (q.Grid_QuoteAutoNumber__c > max) {
        max = integer.valueOf(q.Grid_QuoteAutoNumber__c);
      }
    }
    return max;
  }
  /**
   * @description create product schedule related on QLIs
   * @param List Delivery Plan, Quote Ids
   * @return void
  **/
  public static void createProductSchedule(
    List<Deliveryplan__c> lstDeliveryPlan,
    Set<Id> QuoteIds
  ) {
    List<ProductSchedule__c> prodList = new List<ProductSchedule__c>();
    date ddp;
    date edp;
    String prodName;
    Map<Id, List<quotelineitem>> ListQuotelineitemMap = new Map<Id, List<quotelineitem>>();
    List<quotelineitem> ListQuotelineitem = new List<quotelineitem>();
    ListQuotelineitem = [
      SELECT
        Id,
        QuoteId,
        Quantity,
        Product2.Name,
        Product2.Grid_Category__c,
        vlocity_cmt__OneTimeCharge__c,
        CurrencyIsoCode
      FROM quotelineitem
      WHERE QuoteId IN :QuoteIds AND Product2.Grid_Category__c = 'Hardware'
    ];
    for (quotelineitem qItem : ListQuotelineitem) {
      if (ListQuotelineitemMap.containsKey(qItem.QuoteId)) {
        ListQuotelineitemMap.get(qItem.QuoteId).add(qItem);
      } else {
        ListQuotelineitemMap.put(
          qItem.QuoteId,
          new List<quotelineitem>{ qItem }
        );
      }
    }

    for (DeliveryPlan__c dlp : lstDeliveryPlan) {
      Integer j = 0;
      Integer orderSort = 0;
      List<quotelineitem> quotelineitemByDeliveryPl = ListQuotelineitemMap.get(
        dlp.Grid_Quote__c
      );
      if (ListQuotelineitemMap.size() > 0) {
        for (quotelineitem qItem : quotelineitemByDeliveryPl) {
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
                .format('yyyy');
            }
            prodList.add(
              new ProductSchedule__c(
                Grid_OrderSort__c = ++orderSort,
                Name = prodName,
                CurrencyIsoCode = qItem.CurrencyIsoCode,
                Grid_QuoteLineItem__c = qItem.Id,
                Grid_PlannedQuantity__c = Integer.valueOf(
                  qItem.Quantity / dlp.Grid_ScheduleCount__c
                ),
                Grid_SalesPric__c = qItem.vlocity_cmt__OneTimeCharge__c,
                Grid_StartDate__c = ddp,
                Grid_EndDate__c = edp,
                Total_Quantity__c = qItem.Quantity,
                Grid_Version__c = 1,
                Grid_Delivery_Plan__c = dlp.Id
              )
            );
            j++;
          }
        }
        for (quotelineitem qItem : quotelineitemByDeliveryPl) {
          adjustPlannedQuantities(qItem.Id, prodList);
        }
      }
    }
    if (prodList.size() > 0){
      insert prodList;
    }
  }
  /**
   * @description ajust quantities 
   * @param List Product Schedules, Quote Id
   * @return void
  **/
  public static void adjustPlannedQuantities(Id qcId, List<ProductSchedule__c> prodList) {

    List<ProductSchedule__c> prodListQuoteLineItem = new List<ProductSchedule__c>();
    List<ProductSchedule__c> prodcontractLineItems = new List<ProductSchedule__c>();
    Integer totalQuantity = 0;

    for (ProductSchedule__c productSchedule : prodList) {
      if((productSchedule.Grid_Version__c == 1) && (productSchedule.Grid_QuoteLineItem__c == qcId)){
        prodListQuoteLineItem.add(productSchedule);
        totalQuantity += (Integer) productSchedule.Grid_PlannedQuantity__c;
      }
      if((productSchedule.Grid_Version__c == 2) && (productSchedule.Grid_ContractLine__c == qcId)){
        prodcontractLineItems.add(productSchedule);
        totalQuantity += (Integer) productSchedule.Grid_PlannedQuantity__c;
      }
    }
    if(!prodListQuoteLineItem.isEmpty()){
      prodListQuoteLineItem[0].Grid_PlannedQuantity__c += prodListQuoteLineItem[0].Total_Quantity__c - totalQuantity;
    }
    if(!prodcontractLineItems.isEmpty()){
      prodcontractLineItems[0].Grid_PlannedQuantity__c += prodcontractLineItems[0].Total_Quantity__c - totalQuantity;
      }
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

  /**
   * @description updates opportunity stage based on quote status 
   * @param Map delivery plan
   * @return void
  **/
  public static void updateOpportunityStage(
    List<Quote> quotes,
    Set<Id> oppoIds
  ) {
    Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
    for (Opportunity opp : [
      SELECT Id, Grid_TypeOfOpportunity__c, StageName, Loss_Reason__c
      FROM Opportunity
      WHERE Id IN :oppoIds
    ]) {
      oppMap.put(opp.id, opp);
    }

    Map<Id, Boolean> quoteToRevenueMap = new Map<Id, Boolean>();
    for (Revenue__c rev : [
      SELECT Id, Grid_Quote__c
      FROM Revenue__c
      WHERE Grid_Quote__c IN :quotes
    ]) {
      // add quote id to map if it has revenue linked to it
      quoteToRevenueMap.put(rev.Grid_Quote__c, true);
    }

    List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
    for (Quote qte : quotes) {
      Opportunity opp = oppMap.get(qte.OpportunityId);
      if (qte.Status == 'Approved') {
        // check if the quote has revenue linked to it, add error if it does not have revenue linked to it
        if (!quoteToRevenueMap.containsKey(qte.Id)) {
          qte.addError(Label.generateRevenueBeforeApprovingQuote);
        }
        opp.StageName = 'Negotiation';
        opportunitiesToUpdate.add(opp);
      } else if (
        qte.Status == 'Finalized' &&
        opp.Grid_TypeOfOpportunity__c == 'Tender'
      ) {
        opp.StageName = 'Closed Awarded';
        opp.Grid_AwardedDate__c = system.today();
        opportunitiesToUpdate.add(opp);
      } else if (
        qte.Status == 'Finalized' &&
        opp.Grid_TypeOfOpportunity__c != 'Tender'
      ) {
        opp.StageName = 'Closed Won';
        opportunitiesToUpdate.add(opp);
      }
    }
    update opportunitiesToUpdate;
  }

  /**
   * @description creates revenue schedules for software and services products
   * @param List Revenue, Quote Ids
   * @return void
  **/
  public static void createRevenueSchedule(
    List<Revenue__c> revenueList,
    Set<Id> QuoteIds
  ) {
    date revSchedStart;
    date revSchedEnd;
    String revSchedName;
    List<Grid_RevenueSchedule__c> revSchedList = new List<Grid_RevenueSchedule__c>();
    Map<Id, List<quotelineitem>> ListQuotelineitemMap = new Map<Id, List<quotelineitem>>();
    List<quotelineitem> ListQuotelineitem = new List<quotelineitem>();
    ListQuotelineitem = [ 
      SELECT
        Id,
        QuoteId,
        Product2.Name,
        Product2.Grid_IsChild__c,
        Product2.Grid_Category__c,
        vlocity_cmt__OneTimeTotal__c,
        Grid_RecurringTotalYearly__c,         //or Grid_Recurring_Cost_Total_Yearly__c
        vlocity_cmt__RecurringTotal__c,       // is this right?
        vlocity_cmt__ParentItemId__c,
        CurrencyIsoCode
      FROM quotelineitem
      WHERE QuoteId IN :QuoteIds AND Product2.Grid_Category__c IN ('Software','Services') AND Product2.Grid_IsChild__c = true
    ];
    for (quotelineitem qItem : ListQuotelineitem) {
      if (ListQuotelineitemMap.containsKey(qItem.QuoteId)) {
        ListQuotelineitemMap.get(qItem.QuoteId).add(qItem);
      } else {
        ListQuotelineitemMap.put(
          qItem.QuoteId,
          new List<quotelineitem>{ qItem }
        );
      }
    }

    for (Revenue__c rev : revenueList) {
      Integer j = 0;
      Integer orderSort = 0;
      Integer nMonths = 0;
      Integer contractedMonths;
      Date tempDate;
      // check if rev scheds for sw/services already exist for this revenue, if so delete them
      List<Grid_RevenueSchedule__c> revSchedToDelete = [
        SELECT Id, Grid_Revenue__c, Grid_Category__c
        FROM Grid_RevenueSchedule__c
        WHERE Grid_Revenue__c = :rev.Id AND Grid_Category__c IN ('Software','Services')
      ];
      if(!revSchedToDelete.isEmpty()){
        try {
          delete revSchedToDelete;
        } catch (DmlException e) {
          System.debug('cannot delete existing revenue schedules');
        }
      }

      // calculate contracted months
      contractedMonths = rev.Grid_StartDate__c.monthsBetween(rev.Grid_EndDate__c);

      // get list of qli of quote (related to revenue)
      List<quotelineitem> quotelineitemByRevenue = ListQuotelineitemMap.get(
        rev.Grid_Quote__c
      );
      if (ListQuotelineitemMap.size() > 0) {
        // iterate on single qli (revenue table row)
        for (quotelineitem qItem : quotelineitemByRevenue) {
          // set revenue schedule start and end date
          revSchedStart = rev.Grid_StartDate__c;
          revSchedEnd = rev.Grid_StartDate__c;
          j = 0;

          for (integer i = 0; i < rev.Grid_Count__c; i++) {
            revSchedStart = j > 0 ? revSchedStart.addYears(1) : revSchedStart;
            revSchedEnd = revSchedStart.addYears(1)<rev.Grid_EndDate__c ? revSchedStart.addYears(1) : rev.Grid_EndDate__c;
            revSchedName = DateTime.newInstance(         
                revSchedStart.year(),
                revSchedStart.month(),
                revSchedStart.day()
                ).format('yyyy');
            // create three variables which save the amounts in case of different metrics
            Double amountOT = 0;
            Double amountMonthly = 0;
            Double amountYearly = 0;

            // get planned amount
            if (qItem.vlocity_cmt__OneTimeTotal__c != 0){       
              System.debug('is onetime');
              if(j==0){
                amountOT = qItem.vlocity_cmt__OneTimeTotal__c;  // first year
              } else {
                amountOT = 0;                                   // other years
              }
            } if (qItem.vlocity_cmt__RecurringTotal__c != 0) {
              System.debug('is monthly');
              if(j==0){       //first year
                tempDate = Date.newInstance(rev.Grid_StartDate__c.year(),12,31);
                nMonths = rev.Grid_StartDate__c.monthsBetween(tempDate)+1;
                amountMonthly = qItem.vlocity_cmt__RecurringTotal__c*nMonths;
              } else if (j>0 && j<rev.Grid_Count__c-1){   //middle years
                amountMonthly = qItem.vlocity_cmt__RecurringTotal__c*12;
              } else if (j == rev.Grid_Count__c-1){   //last year
                tempDate = Date.newInstance(rev.Grid_EndDate__c.year(),1,1);
                nMonths = tempDate.monthsBetween(rev.Grid_EndDate__c)+1;
                amountMonthly = qItem.vlocity_cmt__RecurringTotal__c*nMonths;
              }
            } if (qItem.Grid_RecurringTotalYearly__c != 0) {    //equally distributed
              System.debug('is yearly');
              amountYearly = (qItem.Grid_RecurringTotalYearly__c*contractedMonths/12)/rev.Grid_Count__c; 
            }
 
            if(qItem.vlocity_cmt__OneTimeTotal__c != 0){
              revSchedList.add(
                new Grid_RevenueSchedule__c(
                  Grid_OrderSort__c = ++orderSort,
                  Name = revSchedName,
                  Grid_QuoteLineItem__c = qItem.Id,
                  Grid_Category__c = qItem.Product2.Grid_Category__c,
                  Grid_Metric__c = 'One Time',
                  Grid_PlannedAmount__c = amountOT,
                  Grid_StartDate__c = revSchedStart,
                  Grid_EndDate__c = revSchedEnd,
                  Grid_Version__c = 1,
                  Grid_Revenue__c = rev.Id,
                  CurrencyIsoCode = qItem.CurrencyIsoCode
                )
              );
            }
            if(amountMonthly!=0){
              revSchedList.add(
                new Grid_RevenueSchedule__c(
                  Grid_OrderSort__c = ++orderSort,
                  Name = revSchedName,
                  Grid_QuoteLineItem__c = qItem.Id,
                  Grid_Category__c = qItem.Product2.Grid_Category__c,
                  Grid_Metric__c = 'Recurring Monthly',
                  Grid_PlannedAmount__c = amountMonthly,
                  Grid_StartDate__c = revSchedStart,
                  Grid_EndDate__c = revSchedEnd,
                  Grid_Version__c = 1,
                  Grid_Revenue__c = rev.Id,
                  CurrencyIsoCode = qItem.CurrencyIsoCode
                )
              );
            }
            if(amountYearly!=0){
              revSchedList.add(
                new Grid_RevenueSchedule__c(
                  Grid_OrderSort__c = ++orderSort,
                  Name = revSchedName,
                  Grid_QuoteLineItem__c = qItem.Id,
                  Grid_Category__c = qItem.Product2.Grid_Category__c,
                  Grid_Metric__c = 'Recurring Yearly',
                  Grid_PlannedAmount__c = amountYearly,
                  Grid_StartDate__c = revSchedStart,
                  Grid_EndDate__c = revSchedEnd,
                  Grid_Version__c = 1,
                  Grid_Revenue__c = rev.Id,
                  CurrencyIsoCode = qItem.CurrencyIsoCode
                )
              );
            }
            // zero price case
            if(qItem.vlocity_cmt__OneTimeTotal__c == 0 && amountMonthly==0 && amountYearly==0){
              revSchedList.add(
                new Grid_RevenueSchedule__c(
                  Grid_OrderSort__c = ++orderSort,
                  Name = revSchedName,
                  Grid_QuoteLineItem__c = qItem.Id,
                  Grid_Category__c = qItem.Product2.Grid_Category__c,
                  Grid_PlannedAmount__c = 0,
                  Grid_StartDate__c = revSchedStart,
                  Grid_EndDate__c = revSchedEnd,
                  Grid_Version__c = 1,
                  Grid_Revenue__c = rev.Id,
                  CurrencyIsoCode = qItem.CurrencyIsoCode
                )
              );
            }
            j++;
          }
        }
      }
    }
    if (revSchedList.size() > 0){
      insert revSchedList;
    }
  }

  /**
   * @description creates revenue schedules for hardware products
   * @param List Revenue, Quote Ids
   * @return void
  **/
  public static void createHWRevenueSchedule(
    List<Revenue__c> revenueList,
    Set<Id> QuoteIds
  ) {
    // get product schedules using qli ids from quote

    date revSchedStart;
    date revSchedEnd;
    String revSchedName;
    List<String> prodSchedNames;
    Integer deliveryPlanCount;
    List<Grid_RevenueSchedule__c> revSchedList = new List<Grid_RevenueSchedule__c>();
    Map<Id, List<quotelineitem>> ListQuotelineitemMap = new Map<Id, List<quotelineitem>>();
    List<quotelineitem> ListQuotelineitem = new List<quotelineitem>();
    Map<String, ProductSchedule__c> prodSchedMap = new Map<String, ProductSchedule__c>();
    Integer nMonths;
    Date tempDate;
    Double sum = 0;
    String psName;
    List<ProductSchedule__c> prodSchedOfYear = new List<ProductSchedule__c>();
    ListQuotelineitem = [ 
      SELECT
        Id,
        QuoteId,
        Product2.Name,
        Product2.Grid_IsChild__c,
        Product2.Grid_Category__c,
        vlocity_cmt__OneTimeTotal__c,
        Grid_RecurringTotalYearly__c,         //or Grid_Recurring_Cost_Total_Yearly__c
        vlocity_cmt__RecurringTotal__c,       // is this right?
        vlocity_cmt__ParentItemId__c,
        Gridspertise_JobiModel__c,
        Gridspertise_LVMModel__c,
        Gridspertise_NexyModel__c,
        Gridspertise_OpenModel__c,
        CurrencyIsoCode
      FROM quotelineitem
      WHERE QuoteId IN :QuoteIds AND Product2.Grid_Category__c IN ('Hardware') AND Product2.Grid_IsChild__c = true
    ];

    for (quotelineitem qItem : ListQuotelineitem) {
      if (ListQuotelineitemMap.containsKey(qItem.QuoteId)) {
        ListQuotelineitemMap.get(qItem.QuoteId).add(qItem);
      } else {
        ListQuotelineitemMap.put(
          qItem.QuoteId,
          new List<quotelineitem>{ qItem }
        );
      }
    }
    for (Revenue__c rev : revenueList) {
      //Integer orderSort = 0;
      double plannedAmount;
      string metric;
      // check if rev scheds for hw already exist for this revenue, if so delete them
      List<Grid_RevenueSchedule__c> revSchedToDelete = [
        SELECT Id, Grid_Revenue__c, Grid_Category__c
        FROM Grid_RevenueSchedule__c
        WHERE Grid_Revenue__c = :rev.Id AND Grid_Category__c IN ('Hardware')
      ];
      if(!revSchedToDelete.isEmpty()){
        try {
          delete revSchedToDelete;
        } catch (DmlException e) {
          System.debug('cannot delete existing hardware revenue schedules');
        }
      }

      // retrieve delivery plans of quote
      List<Deliveryplan__c> quoteDeliveryPlan = [
        SELECT Id, Grid_Quote__c, Grid_ScheduleCount__c, Grid_ScheduleFrequency__c
        FROM Deliveryplan__c
        WHERE Grid_Quote__c =: rev.Grid_Quote__c
      ];
      // get list of qli of quote (related to revenue)
      List<quotelineitem> quotelineitemByRevenue = ListQuotelineitemMap.get(
        rev.Grid_Quote__c
      );
      if (ListQuotelineitemMap.size() > 0) {
        // iterate on single qli (revenue table row)
        for (quotelineitem qItem : quotelineitemByRevenue) {
          // retrieve product schedules for single qli, organize them by name
          List<ProductSchedule__c> prodSchedList = [
            SELECT Id, Name, Grid_PlannedAmn__c, Grid_QuoteLineItem__c
            FROM ProductSchedule__c
            WHERE Grid_QuoteLineItem__c =: qItem.Id
            AND Grid_Version__c = 1
          ];
          for (ProductSchedule__c ps : prodSchedList) {
            prodSchedMap.put(ps.Name, ps);
          }
          // for each contracted year
          for (integer i = 0; i < rev.Grid_Count__c; i++) {
            sum = 0;
            revSchedStart = i > 0 ? revSchedStart.addYears(1) : rev.Grid_StartDate__c;
            revSchedEnd = revSchedStart.addYears(1)<rev.Grid_EndDate__c ? revSchedStart.addYears(1) : rev.Grid_EndDate__c;
            revSchedName = DateTime.newInstance(         
              revSchedStart.year(),
              revSchedStart.month(),
              revSchedStart.day()
              ).format('yyyy');

            // filter only product schedules for that year
            // taking into account the delivery plan frequency and count
            deliveryPlanCount = Integer.valueOf(quoteDeliveryPlan[0].Grid_ScheduleCount__c);

            System.debug('Grid_ScheduleFrequency__c: '+quoteDeliveryPlan[0].Grid_ScheduleFrequency__c);
            // if delivery plan is monthly
            if(quoteDeliveryPlan[0].Grid_ScheduleFrequency__c == 'Monthly'){
              if (i==0){  // first year
                tempDate = Date.newInstance(rev.Grid_StartDate__c.year(),12,31);
                nMonths = rev.Grid_StartDate__c.monthsBetween(tempDate)+1;
                for(Integer j=0; j<nMonths; j++){
                  psName = DateTime.newInstance(         
                    revSchedStart.year(),
                    revSchedStart.month()+j,
                    revSchedStart.day()
                    ).format('MMM-yyyy');
                  sum = prodSchedMap.containsKey(psName)? sum + prodSchedMap.get(psName).Grid_PlannedAmn__c : sum;
                }
              } else if (i>0 && i<rev.Grid_Count__c-1){   // middle years
                for(Integer j=0; j<12; j++){
                  tempDate = Date.newInstance(revSchedStart.year(),1,1);
                  psName = DateTime.newInstance(         
                    tempDate.year(),
                    tempDate.month()+j,
                    tempDate.day()
                    ).format('MMM-yyyy');
                  sum = prodSchedMap.containsKey(psName)? sum + prodSchedMap.get(psName).Grid_PlannedAmn__c : sum;
                }
              } else if (i == rev.Grid_Count__c-1) {
                tempDate = Date.newInstance(rev.Grid_EndDate__c.year(),1,1);
                nMonths = tempDate.monthsBetween(rev.Grid_EndDate__c)+1; 
                for(Integer j=0; j<nMonths; j++){
                  psName = DateTime.newInstance(         
                    tempDate.year(),
                    tempDate.month()+j,
                    tempDate.day()
                    ).format('MMM-yyyy');
                  sum = prodSchedMap.containsKey(psName)? sum + prodSchedMap.get(psName).Grid_PlannedAmn__c : sum;
                }
              } 
            }
            // if delivery plan is yearly
            else if(quoteDeliveryPlan[0].Grid_ScheduleFrequency__c == 'Yearly'){
              psName = DateTime.newInstance(         
                revSchedStart.year(),
                revSchedStart.month(),
                revSchedStart.day()
                ).format('yyyy');
              sum = prodSchedMap.containsKey(psName)? prodSchedMap.get(psName).Grid_PlannedAmn__c : 0;
            }
            // if delivery plan is one-time
            else if(quoteDeliveryPlan[0].Grid_ScheduleFrequency__c == 'One Time'){
              sum = 0;
              for(String key : prodSchedMap.keySet()){
                if(key.contains(revSchedStart.year()+'')){
                  sum = prodSchedMap.get(key).Grid_PlannedAmn__c;
                }
              }
            }

            // filling revenue schedule fields for that qli and year
            plannedAmount = sum;
            metric = 'One Time';
            String model;
            if(!String.isBlank(qItem.Gridspertise_JobiModel__c)){
              model = qItem.Gridspertise_JobiModel__c;
            } else if (!String.isBlank(qItem.Gridspertise_LVMModel__c)){
              model = qItem.Gridspertise_LVMModel__c;
            } else if (!String.isBlank(qItem.Gridspertise_NexyModel__c)){
              model = qItem.Gridspertise_NexyModel__c;
            } else if (!String.isBlank(qItem.Gridspertise_OpenModel__c)){
              model = qItem.Gridspertise_OpenModel__c;
            }
            
            // create revenue schedule
            revSchedList.add(
              new Grid_RevenueSchedule__c(
                //Grid_OrderSort__c = ++orderSort,        // what is this for?
                Name = revSchedName,
                Grid_QuoteLineItem__c = qItem.Id,
                Grid_Category__c = qItem.Product2.Grid_Category__c,
                Grid_Metric__c = metric,
                Grid_Model__c = model,
                Grid_PlannedAmount__c = plannedAmount,
                Grid_StartDate__c = revSchedStart,
                Grid_EndDate__c = revSchedEnd,
                Grid_Version__c = 1,
                Grid_Revenue__c = rev.Id,
                CurrencyIsoCode = qItem.CurrencyIsoCode
              )
            );
          }
        }
      }
    }
    if (revSchedList.size() > 0){
      insert revSchedList;
    }
  }
}