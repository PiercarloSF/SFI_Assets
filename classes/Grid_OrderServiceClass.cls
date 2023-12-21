/**
 * Class to implement the contract service
 *
 * @Author  Salesforce
 *
 */
public with sharing class Grid_OrderServiceClass {

    /**
       * @description creates version 2 of revenue
           * @param contractIds
           * @return void
        **/
        public static void cloneRevenue(
            Set<Id> contractIds
            ){
                String contractQuoteId;
                List<Contract> contracts = [ SELECT Id, vlocity_cmt__QuoteId__c FROM Contract WHERE Id IN :contractIds];
                List<Revenue__c> clonedRevenues = new List<Revenue__c>();
                Revenue__c revenue1 = new Revenue__c();
                Revenue__c revenue2 = new Revenue__c();
        
                for(Contract contr : contracts){
                    // get contract quoteId
                    contractQuoteId = contr.vlocity_cmt__QuoteId__c;
                    // check if revenue has already been cloned
                    List<Revenue__c> existingClone = [
                        SELECT Id, Grid_Quote__c, Grid_Version__c 
                        FROM Revenue__c
                        WHERE Grid_Quote__c = :contractQuoteId AND Grid_Version__c = 2
                    ];
                    if(!existingClone.isEmpty()){
                        System.Debug('This Revenue already exists');
                        return;
                    }
                    // retrieve revenue so that its quoteid is the order's quoteid
                    List<String> revenueFields = new List<String>(Revenue__c.SObjectType.getDescribe().fields.getMap().keySet());
                    String soql = ''
                    + ' SELECT ' + String.join(revenueFields, ',')
                    + ' FROM Revenue__c'
                    + ' WHERE Grid_Quote__c = :contractQuoteId';
                    revenue1 = Database.query(soql);
                    revenue2 = revenue1.clone();
                    revenue2.Grid_Version__c = 2;
                    revenue2.Grid_Contract__c = contr.Id;
                    System.debug('contractid' + contr.Id);
                    clonedRevenues.add(revenue2);
                }
                if(!clonedRevenues.isEmpty()){
                    try {
                        insert clonedRevenues;
                    }catch(DMLException e) {
                        ApexPages.addMessages(e);
                    } 
                }
            }
        
        public static void cloneRevenueSchedules(
            Set<Id> contractIds
        ){
            String contractQuoteId;
            List<Contract> contracts = [ SELECT Id, vlocity_cmt__QuoteId__c FROM Contract WHERE Id IN :contractIds];
            List<Grid_RevenueSchedule__c> revSchedList1 = new List<Grid_RevenueSchedule__c>();
            List<Grid_RevenueSchedule__c> revSchedList2 = new List<Grid_RevenueSchedule__c>();
        
            for(Contract contr : contracts){
                // get contract quoteId
                contractQuoteId = contr.vlocity_cmt__QuoteId__c;
                // retrieve revenues
                List<Revenue__c> revenue1 = [
                    SELECT Id, Grid_Quote__c, Grid_Version__c
                    FROM Revenue__c
                    WHERE Grid_Quote__c = :contractQuoteId AND Grid_Version__c = 1
                ];
                List<Revenue__c> revenue2 = [
                    SELECT Id, Grid_Quote__c, Grid_Version__c 
                    FROM Revenue__c
                    WHERE Grid_Quote__c = :contractQuoteId AND Grid_Version__c = 2
                ];
                // retrieve cli related to contract
                List<vlocity_cmt__ContractLineItem__c> contractLineItems = [
                    SELECT Id, vlocity_cmt__Product2Id__r.Id, vlocity_cmt__Product2Id__r.Name, vlocity_cmt__ContractId__c, OpenMeterFormula__c
                    FROM vlocity_cmt__ContractLineItem__c
                    WHERE vlocity_cmt__ContractId__c = :contr.Id
                ];
            
                // clone revenue schedules and change version
                String revenueId = revenue1[0].Id;
                String soql = ' SELECT Id, Grid_EndDate__c, Grid_StartDate__c, Grid_QuoteLineItem__c, Grid_PlannedAmount__c, Grid_Model__c, Grid_Category__c, Grid_Metric__c, Grid_Revenue__c, Name, Grid_ContractLine__c, Grid_QuoteLineItem__r.OpenMeterFormula__c,Grid_QuoteLineItem__r.Product2.Name'
                + ' FROM Grid_RevenueSchedule__c'
                + ' WHERE Grid_Revenue__c = :revenueId';
                revSchedList1 = Database.query(soql);
                for(Grid_RevenueSchedule__c revSched : revSchedList1){
                    Grid_RevenueSchedule__c revSchedClone = revSched.clone();
                    revSchedClone.Grid_Version__c = 2;
                    revSchedClone.Grid_Revenue__c = revenue2[0].Id;
                    revSchedClone.Grid_QuoteLineItem__c = revSched.Grid_QuoteLineItem__c;
                    // match contractlineitems
                    String meterFormula = revSchedClone.Grid_QuoteLineItem__r.OpenMeterFormula__c;
                    for (vlocity_cmt__ContractLineItem__c cli : contractLineItems) {
                        boolean modelCheck = (meterFormula != null && meterFormula == cli.OpenMeterFormula__c) || meterFormula == null;
                        if (revSchedClone.Grid_QuoteLineItem__r.Product2.Name == cli.vlocity_cmt__Product2Id__r.Name && modelCheck) {
                            revSchedClone.Grid_ContractLine__c = cli.Id;
                        }
                    } 
                    revSchedList2.add(revSchedClone);
                }
            }
            if(!revSchedList2.isEmpty()){
                try {
                    insert revSchedList2;
                }catch(DMLException e) {
                    ApexPages.addMessages(e);
                } 
            }
        }
    
    /**
       * @description update actual amounts of revenue schedules
       * @param List Order Id
       * @return void
    **/
        public static void updateRevenueSchedulesActual(
            List<Order> ordersInvoiced,Boolean refresh
        ) {
            Id OrderId = ordersInvoiced[0].Id;
            // query order from id
            List<Order> orderObj = [ SELECT Id, Grid_Delivery_Date__c, Contract.vlocity_cmt__QuoteId__c FROM Order WHERE Id = :OrderId]; 
            // query revenue and delivery plan lists
            String orderQuoteId = orderObj[0].Contract.vlocity_cmt__QuoteId__c;
            List<Revenue__c> revenueList = [ SELECT Id, Grid_Count__c, Grid_StartDate__c, Grid_EndDate__c, Grid_Quote__c, Grid_Version__c 
                FROM Revenue__c WHERE Grid_Quote__c = :orderQuoteId AND Grid_Version__c = 2];
            Date startBillingDate = OrderObj[0].Grid_Delivery_Date__c;
            
            List<Grid_RevenueSchedule__c> SWrevSchedsToUpdate = new List<Grid_RevenueSchedule__c>();
            List<Grid_RevenueSchedule__c> HWrevSchedsToUpdate = new List<Grid_RevenueSchedule__c>();
    
            // map cli with orderitem ids (HW+SW)
            Map<Id,OrderItem> orderproductMap = getCliToOrderItemMap(OrderId,refresh);
    
            // SOFTWARE ACTUALS
            SWrevSchedsToUpdate = calculateActualRevenues(revenueList,orderproductMap,startBillingDate);
            system.debug('SWrevSchedsToUpdate' + SWrevSchedsToUpdate);
            update SWrevSchedsToUpdate;
        }
    
        /**
           * @description calculate actual revenues for software products
           * @param List Revenue, Map OrderItem, Date
           * @return List<Grid_RevenueSchedule__c>
        **/
        public static List<Grid_RevenueSchedule__c> calculateActualRevenues(
            List<Revenue__c> revenueList,
            Map<Id,OrderItem> orderProductMap,
            Date startBillingDate
        ){
            system.debug('orderProductMap' + orderProductMap);
            system.debug('revenueList' + revenueList);
            List<Grid_RevenueSchedule__c> revSchedsToUpdate = new List<Grid_RevenueSchedule__c>();
            Integer billedYearsN = (revenueList[0].Grid_EndDate__c).year() - startBillingDate.year() +1;
            Integer billedMonthsN = (startBillingDate).monthsBetween(revenueList[0].Grid_EndDate__c);
            Integer contractedMonthsN = revenueList[0].Grid_StartDate__c.monthsBetween(revenueList[0].Grid_EndDate__c);
            Integer contractedYearsN = Integer.valueOf(revenueList[0].Grid_Count__c);
            double cliTotalRevenue;
            String startingRevSchedName;
            double newRecurringPayement;
            Integer nMonths;
            Date tempDate;
            Double sum;
            String psName;
            Date startingDate;
    
            // map of map of revenue schedules with name as key, using cli ids as keys
            Map<Id, Map<String, Grid_RevenueSchedule__c>> revSchedsSWMapped = mapRevSchedstoCli(revenueList);
            System.debug('orderProductMap keyset ' + orderProductMap.keySet());
            System.debug('revSchedsSWMapped keyset ' + revSchedsSWMapped.keySet());
            // iterate map of order items
            for(Id cliID : orderProductMap.keySet()){
                // check if cli is also in the map of SW/services revenue schedules (if it's not HW)
                if(revSchedsSWMapped.containsKey(cliID)){
                    System.debug('YESSSS cliID' + cliID);
                    // if yes, update rev scheds of that cli (actual amount) based on metric
                    // start populating actual fields from rev sched whose name is the same year as the "invoced date" year
                    startingRevSchedName = DateTime.newInstance(         
                        startBillingDate.year(),
                        startBillingDate.month(),
                        startBillingDate.day()
                        ).format('YYYY');
                    for(Integer y=0; y<billedYearsN; y++){
                        // retrieve all revenue schedules for that cli + name(year)
                        String model = orderProductMap.get(cliID).Grid_MeterModel__c;
                        List<Grid_RevenueSchedule__c> cliRevSchedYearY = [
                            SELECT Id, Name, Grid_ActualAmount__c, Grid_Metric__c, Grid_QuoteLineItem__r.Product2.Name, Grid_Version__c, Grid_Revenue__c	
                            FROM Grid_RevenueSchedule__c
                            WHERE Name = :startingRevSchedName 
                            AND (Grid_QuoteLineItem__r.Product2.Name = :orderProductMap.get(cliID).Product2.Name OR Grid_ContractLine__r.vlocity_cmt__Product2Id__r.Name = :orderProductMap.get(cliID).Product2.Name)
                            AND Grid_Version__c = 2
                            AND Grid_Revenue__c = :revenueList[0].Id
                            AND Grid_Model__c = :model
                            ];
                        // iterate over all retrieved schedules
                        for(Integer r=0; r<cliRevSchedYearY.size(); r++){
                            if(cliRevSchedYearY[r].Grid_ActualAmount__c == null) cliRevSchedYearY[r].Grid_ActualAmount__c = 0;
                            // if one time
                            if(cliRevSchedYearY[r].Grid_Metric__c == 'One Time' && y==0){
                                cliRevSchedYearY[r].Grid_ActualAmount__c += orderProductMap.get(cliID).vlocity_cmt__OneTimeTotal__c;
                            }
                            // if monthly
                            else if(cliRevSchedYearY[r].Grid_Metric__c == 'Recurring Monthly'){
                                // first calculate total revenue over contracted years per single product    
                                cliTotalRevenue = orderProductMap.get(cliID).vlocity_cmt__RecurringTotal__c * contractedMonthsN;
                                newRecurringPayement = cliTotalRevenue/billedMonthsN != 0 ? cliTotalRevenue/billedMonthsN : 0;
                                // first year revenue
                                if(y==0){
                                    tempDate = Date.newInstance(startBillingDate.year(),12,31);
                                    nMonths = startBillingDate.monthsBetween(tempDate)+1;
                                    cliRevSchedYearY[r].Grid_ActualAmount__c += newRecurringPayement * nMonths;
                                }
                                // middle years revenue
                                else if (y>0 && y<billedYearsN-1){
                                    nMonths = 12;
                                    cliRevSchedYearY[r].Grid_ActualAmount__c += newRecurringPayement * nMonths;
                                }
                                // last year revenue
                                else if (y==billedYearsN-1) {
                                    tempDate = Date.newInstance(revenueList[0].Grid_EndDate__c.year(),1,1);
                                    nMonths = tempDate.monthsBetween(revenueList[0].Grid_EndDate__c);
                                    cliRevSchedYearY[r].Grid_ActualAmount__c += newRecurringPayement * nMonths;
                                }
                            }
                            // if yearly
                            else if(cliRevSchedYearY[r].Grid_Metric__c == 'Recurring Yearly'){
                                cliTotalRevenue = orderProductMap.get(cliID).Grid_RecurringTotalYearly__c * (((Double)contractedMonthsN)/12.0);
                                newRecurringPayement = cliTotalRevenue / billedYearsN != 0 ? cliTotalRevenue / billedYearsN : 0;
                                cliRevSchedYearY[r].Grid_ActualAmount__c += newRecurringPayement;
                            }
                            revSchedsToUpdate.add(cliRevSchedYearY[r]);
                        }
                        startingRevSchedName = nextScheduleName(startingRevSchedName);
                    }
                }
            }
            return revSchedsToUpdate;
        }
    
      /**
        * @description Map Software Revenue Schedules by Name and Contract Line Id
        * @param List Revenue
        * @return Map<Id, Map<String, Grid_RevenueSchedule__c>>
        **/
        public static Map<Id, Map<String, Grid_RevenueSchedule__c>> mapRevSchedstoCli(
            List<Revenue__c> revenueList
        ){
            List<Grid_RevenueSchedule__c> revschedList = new List<Grid_RevenueSchedule__c>();
            Map<Id, Map<String, Grid_RevenueSchedule__c>> revSchedsMapped = new Map<Id, Map<String, Grid_RevenueSchedule__c>>();
    
            // retrieve all revenue schedules in revenue
            revschedList = [
                SELECT Id, Grid_ActualAmount__c, Grid_Category__c, Grid_StartDate__c, Grid_EndDate__c, 
                Grid_QuoteLineItem__c, Grid_Revenue__c, Grid_Metric__c, Name, Grid_Version__c, Grid_ContractLine__c
                FROM Grid_RevenueSchedule__c
                WHERE Grid_Revenue__c = :revenueList[0].Id
                AND Grid_Version__c = 2
            ];

    
            // map maps based on cli id + map rev scheds based on name
            if(revschedList.isEmpty()) System.debug('empty rev sched list');
            for (Grid_RevenueSchedule__c revSched: revschedList) {
                if(revSchedsMapped.get(revSched.Grid_ContractLine__c) == null){
                    revSchedsMapped.put(revSched.Grid_ContractLine__c, new Map<String, Grid_RevenueSchedule__c>{revSched.Name => revSched});
                } else {
                    revSchedsMapped.get(revSched.Grid_ContractLine__c).put(revSched.Name, revSched);
                }
            }

            return revSchedsMapped;
        }
    
      /**
           * @description update Map OrderItem objects to Contract Line Ids
           * @param List orderID
           * @return Map<Id,OrderItem>
        **/
        public static Map<Id,OrderItem> getCliToOrderItemMap(
            Id orderId,Boolean refresh
        ){
            Map<Id,OrderItem> orderItemMap = new Map<Id,OrderItem>();
            // Query OrderItems with related Order and Product
            List<OrderItem> orderItems = new List<OrderItem>();
            if(refresh){
                orderItems = [
                    SELECT Id, Quantity ,OrderId ,Product2.Id,Product2.Name, Grid_MeterModel__c, Grid_Category__c ,
                    vlocity_cmt__OneTimeTotal__c, vlocity_cmt__RecurringTotal__c, Grid_RecurringTotalYearly__c
                    FROM OrderItem
                    WHERE Product2Id != null AND OrderId = :orderId AND Grid_Category__c ='Hardware'
                ];
            }else{
                orderItems = [
                    SELECT Id, Quantity ,OrderId ,Product2.Id,Product2.Name, Grid_MeterModel__c, 
                    vlocity_cmt__OneTimeTotal__c, vlocity_cmt__RecurringTotal__c, Grid_RecurringTotalYearly__c
                    FROM OrderItem
                    WHERE Product2Id != null AND OrderId = :orderId
                ];
            }
    
            // Query the related Contract
            Id contractId = [SELECT ContractId FROM Order WHERE Id = :orderId].ContractId;
    
            // Query ContractLineItems related to the Contract
            List<vlocity_cmt__ContractLineItem__c> contractLineItems = new List<vlocity_cmt__ContractLineItem__c>();
            if(refresh){
                contractLineItems = [
                    SELECT Id,Grid_Actual_Quantity__c, vlocity_cmt__Quantity__c,vlocity_cmt__Product2Id__r.Grid_Category__c, vlocity_cmt__Product2Id__r.Id,vlocity_cmt__Product2Id__r.Name,vlocity_cmt__ContractId__c,OpenMeterFormula__c
                    FROM vlocity_cmt__ContractLineItem__c
                    WHERE vlocity_cmt__ContractId__c = :contractId AND vlocity_cmt__Product2Id__r.Grid_Category__c ='Hardware'
                ];
            }else{
                contractLineItems = [
                    SELECT Id,Grid_Actual_Quantity__c, vlocity_cmt__Quantity__c, vlocity_cmt__Product2Id__r.Id,vlocity_cmt__Product2Id__r.Name,vlocity_cmt__ContractId__c,OpenMeterFormula__c
                    FROM vlocity_cmt__ContractLineItem__c
                    WHERE vlocity_cmt__ContractId__c = :contractId
                ];
            }
    
            // Iterate through OrderItems and find matching ContractLineItems
            for (vlocity_cmt__ContractLineItem__c cli : contractLineItems) {
                for (OrderItem oi : orderItems) {
                    boolean modelCheck = (oi.Grid_MeterModel__c != null && oi.Grid_MeterModel__c == cli.OpenMeterFormula__c) || oi.Grid_MeterModel__c == null;
                    if (oi.Product2.Name == cli.vlocity_cmt__Product2Id__r.Name && modelCheck) {
                        orderItemMap.put(cli.Id, oi);
                        break;
                    }
                }
            }
            return orderItemMap;
        }
    
        public static String nextScheduleName(String name){
            Decimal value = Decimal.valueOf(name);
            value = value.setScale(0)+1;
            return String.valueOf(value);
        }
    
        /**
        * @description update Actual Quantity in contract Line from it's related order product
        * @param List ordersInvoiced
        * @return void
        **/
        public static void updateQuantityInContractLine(List<Order> ordersInvoiced) {
            Map<Id, vlocity_cmt__ContractLineItem__c> contractLineByOrderItem = getOrderItemToContractLineItemMap(ordersInvoiced[0].Id);
            List<vlocity_cmt__ContractLineItem__c> contractLines = new List<vlocity_cmt__ContractLineItem__c>();
            Map<Id, Decimal> productTotalQuantities = new Map<Id, Decimal>();
            Map<String, Decimal> modelTotalQuantities = new Map<String, Decimal>();
            Map<Id, OrderItem> orderItemById = new Map<Id, OrderItem>();
      
            // Get all Order Items related to the input Order invoiced
            List<OrderItem> orderItems = [
            SELECT Id, Product2Id, Quantity,Product2.Name, Grid_MeterModel__c, Grid_IsChild__c
            FROM OrderItem
            WHERE Order.ContractId = :ordersInvoiced[0].contractId AND (Order.Status = 'Delivered' OR Order.Status = 'Closed' OR Order.Status = 'Activated')
            ];
      
          // Calculate the total quantity of each product
          for (OrderItem oi : orderItems) {
              String model = oi.Grid_MeterModel__c;
              Id productId = oi.Product2Id;
              // For smart meters product case use model as key, for normal product use productId as key 
              if (model != null) {
                  if (!modelTotalQuantities.containsKey(model)) {
                      modelTotalQuantities.put(model, 0);
                  }
                  modelTotalQuantities.put(model, modelTotalQuantities.get(model) + oi.Quantity);
              }else{
                if(oi.Grid_IsChild__c){
                    if (productTotalQuantities.containsKey(productId)) {
                        productTotalQuantities.put(productId, productTotalQuantities.get(productId) + oi.Quantity);
                    }else {
                        productTotalQuantities.put(productId, oi.Quantity);
                    }
                }else {         
                    orderItemById.put(oi.Id, oi);
                }
      
              }
      
            }  
      
         // loop on contractLineByOrderItem to assign quantity in contractLine
        for(Id orderItemId : contractLineByOrderItem.keySet()){
            vlocity_cmt__ContractLineItem__c contractLine = contractLineByOrderItem.get(orderItemId);    
            if(contractLine.OpenMeterFormula__c != null){
                if (modelTotalQuantities.containsKey(contractLine.OpenMeterFormula__c)) {
                    contractLine.Grid_Actual_Quantity__c = modelTotalQuantities.get(contractLine.OpenMeterFormula__c);
                    }
            }else{
                if (productTotalQuantities.containsKey(contractLine.vlocity_cmt__Product2Id__r.Id)) {
                    contractLine.Grid_Actual_Quantity__c = productTotalQuantities.get(contractLine.vlocity_cmt__Product2Id__r.Id);
                    }
                if(contractLine.Grid_Remaining_Quantity__c == 1 && orderItemById.containsKey(orderItemId)){
                    contractLine.Grid_Actual_Quantity__c = 1;
                }
            }
      
                // Check if the contractLine is already present in contractLines
              Boolean isDuplicate = false;
              for (vlocity_cmt__ContractLineItem__c existingContractLine : contractLines) {
                  if (existingContractLine.Id == contractLine.Id) {
                      isDuplicate = true;
                      break;
                  }
              }
              // If it's not a duplicate, add it to the contractLines list
              if (!isDuplicate || contractLines.isEmpty() ) {
                  contractLines.add(contractLine);
              }    
        }
          // update contractLines
          if(!contractLines.isEmpty()){
          update contractLines;
        }
        }
      
        /**
          * @description update Actual Quantity in ProductScheduelle from it's related contract line
          * @param List ordersInvoiced
          * @return void
        **/
        public static void updateRelatedProductScheduelle(List<Order> ordersInvoiced){
            Map<Id, vlocity_cmt__ContractLineItem__c> contractLineByOrderItem = getOrderItemToContractLineItemMap(ordersInvoiced[0].Id);
            Map<Id, List<ProductSchedule__c>> contractLineWithRelatedProductScheduelles = new Map<Id, List<ProductSchedule__c>>();
            Map<Id, vlocity_cmt__ContractLineItem__c> contractLineById = new Map<Id, vlocity_cmt__ContractLineItem__c>();
        
            // Retrieve productScheduelles that will be updated
            List<ProductSchedule__c> productScheduelles = [
                Select Id,Grid_Actual_Quantity__c, Grid_Version__c,  Grid_StartDate__c, Grid_EndDate__c, Grid_ContractLine__r.Id From ProductSchedule__c 
                WHERE Grid_ContractLine__r.vlocity_cmt__ContractId__c  =: ordersInvoiced[0].ContractId AND Grid_Version__c = 2
            ];
            // Browse productScheduelles to fill the map contractLineWithRelatedProductScheduelles by productScheduelles list and it's related contract line
            for(ProductSchedule__c product : productScheduelles){
                  if(contractLineWithRelatedProductScheduelles.containsKey(product.Grid_ContractLine__r.Id)){
                    contractLineWithRelatedProductScheduelles.get(product.Grid_ContractLine__r.Id).add(product);
                }else{
                    contractLineWithRelatedProductScheduelles.put(product.Grid_ContractLine__r.Id, new List<ProductSchedule__c>{ product });
              }
        
            }
            // Prepare contractLineById Map that give ContractLine List by Id to be used later
            for(Id orderItemId : contractLineByOrderItem.keySet()){
                vlocity_cmt__ContractLineItem__c contractLine = contractLineByOrderItem.get(orderItemId);
                contractLineById.put(contractLine.Id, contractLine );
            
            }
            // Iterate through contractLineWithRelatedProductScheduelles to retrieve productSchedules and it's related contractLine
            for (Id contractLineId : contractLineWithRelatedProductScheduelles.keySet()) {
              List<ProductSchedule__c> productSchedules = contractLineWithRelatedProductScheduelles.get(contractLineId);
              vlocity_cmt__ContractLineItem__c contractLine;
            
                if(contractLineById.containsKey(contractLineId)){
                  contractLine = contractLineById.get(contractLineId);
                }
                if (productSchedules.size() > 0) {
                // Iterate through productSchedules to check the convenable invoiced date and set the Grid_Actual_Quantity__c for it
                for(ProductSchedule__c product : productSchedules){
                    if(contractLine == null){
                        break;
                    }
                  if(ordersInvoiced[0].Grid_Delivery_Date__c >= product.Grid_StartDate__c && ordersInvoiced[0].Grid_Delivery_Date__c <= product.Grid_EndDate__c){
                      product.Grid_Actual_Quantity__c = contractLine.Grid_Actual_Quantity__c;
                  }
              }
                // Update the productSchedule record
                if(!productSchedules.isEmpty()){
                  update productSchedules;
        
                }
              }
            }  
          }
    
    
           /**
           * This method returns a map of OrderItem to related ContractLineItem
           * related to the same Contract.
           *
           * @param orderId The Id of the Order
           * @return A map of OrderItem to related ContractLineItem
           * related to the same Contract.
           */
          public static Map<Id, vlocity_cmt__ContractLineItem__c> getOrderItemToContractLineItemMap(Id orderId) {
            Map<Id, vlocity_cmt__ContractLineItem__c> orderItemToContractLineItemMap = new Map<Id, vlocity_cmt__ContractLineItem__c>();
    
            // Query OrderItems with related Order and Product
            List<OrderItem> orderItems = [
                SELECT Id, Quantity ,OrderId ,Product2.Id,Product2.Name, Grid_MeterModel__c
                FROM OrderItem
                WHERE Product2Id != null AND OrderId = :orderId
            ];
    
            // Query the related Contract
            Id contractId = [SELECT ContractId FROM Order WHERE Id = :orderId].ContractId;
    
            // Query ContractLineItems related to the Contract
            List<vlocity_cmt__ContractLineItem__c> contractLineItems = [
                SELECT Id,Grid_Actual_Quantity__c, vlocity_cmt__Quantity__c, vlocity_cmt__Product2Id__r.Id,vlocity_cmt__Product2Id__r.Name,vlocity_cmt__ContractId__c,OpenMeterFormula__c, Grid_Remaining_Quantity__c
                FROM vlocity_cmt__ContractLineItem__c
                WHERE vlocity_cmt__ContractId__c = :contractId
            ];
            List<vlocity_cmt__ContractLineItem__c> previouscontractLines = new List<vlocity_cmt__ContractLineItem__c>();
    
            // Iterate through OrderItems and find matching ContractLineItems
            for (OrderItem oi : orderItems) {
                for (vlocity_cmt__ContractLineItem__c cli : contractLineItems) {
                    boolean modelCheck = (oi.Grid_MeterModel__c != null && oi.Grid_MeterModel__c == cli.OpenMeterFormula__c) || (oi.Grid_MeterModel__c == null && cli.OpenMeterFormula__c == null);
                    if(previouscontractLines.contains(cli)){
                        continue;
                    }
                    if (oi.Product2.Name == cli.vlocity_cmt__Product2Id__r.Name && modelCheck) {
                        orderItemToContractLineItemMap.put(oi.Id, cli);
                        previouscontractLines.add(cli);
                        break;
                    }
                }
            }
    
            return orderItemToContractLineItemMap;
        }
        /**
           * This method map CurrencyIsoCode of Order to related contract CurrencyIsoCode
           * @param List<Order> orders 
           * @return void
           */
          public static void mapOrderCurrency(List<Order> orders){
            for(Order order: orders){
                order.CurrencyIsoCode = order.vlocity_cmt__FrameContractId__r.CurrencyIsoCode;
                order.Grid_isOrder__c = true;
            }
        }

        /**
           * This method updates the orchestration status on FLR according to status changes
           * @param List<Order> orders 
           * @return void
           */
        public static void updateFlrOrchestrationStatus(List<Order> orders) {

            List<vlocity_cmt__FulfilmentRequest__c> flrs = [SELECT vlocity_cmt__OrderId__c, Name  
            FROM vlocity_cmt__FulfilmentRequest__c 
            WHERE vlocity_cmt__OrderId__c =  :orders[0].Id 
            AND  vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__State__c = 'In Progress' ];

            // Collecting Fulfilment Request IDs 
            Map<Id, Id> orderToFulfilmentRequestIdMap = new Map<Id, Id>();
            for (vlocity_cmt__FulfilmentRequest__c fLr : [
                SELECT vlocity_cmt__OrderId__c, Id
                FROM vlocity_cmt__FulfilmentRequest__c
                WHERE vlocity_cmt__OrderId__c = :orders[0].Id 
                AND vlocity_cmt__orchestrationPlanId__r.vlocity_cmt__State__c = 'In Progress'
            ]) {
                orderToFulfilmentRequestIdMap.put(fLr.vlocity_cmt__OrderId__c, fLr.Id);
            }


            List<vlocity_cmt__FulfilmentRequestLine__c> flrLines = [ SELECT Id, vlocity_cmt__FulfilmentRequestID__c, Grid_Orchestration_status__c
            FROM vlocity_cmt__FulfilmentRequestLine__c
            WHERE vlocity_cmt__FulfilmentRequestID__c IN :orderToFulfilmentRequestIdMap.values()
        ];
            System.debug(flrLines);

            Set<Id> flrItemIds = new Set<Id>();

            for (vlocity_cmt__FulfilmentRequest__c fLr : flrs) {
                for (vlocity_cmt__FulfilmentRequestLine__c fLritem : flrLines) {
                    flrItemIds.add(fLritem.Id);
                    fLritem.Grid_Orchestration_status__c = orders[0].Status;
                }
            }

            List<vlocity_cmt__OrchestrationItem__c> orchItems = [SELECT vlocity_cmt__State__c, vlocity_cmt__AssignedToManualQueueId__c, vlocity_cmt__ErrorQueueId__c  
            FROM vlocity_cmt__OrchestrationItem__c 
            WHERE vlocity_cmt__FulfilmentRequestLineId__c IN :flrItemIds AND Name = 'SAP KO' 
            ];
     
            if (orders[0].Status == 'SAP KO') {
                
                // setting its state to completed and adding to the assigned manual queue
                for (vlocity_cmt__OrchestrationItem__c orchItem : orchItems) {
                    orchItem.vlocity_cmt__State__c = 'Fatally Failed';
                    orchItem.vlocity_cmt__AssignedToManualQueueId__c = orchItem.vlocity_cmt__ErrorQueueId__c;
                }
                

                // looping trought the items on the opposite branch to skip them.
                List<String> skippedItems = new List<String>{
                    'Order Sent to SAP',
                    'Billing Invoicing',
                    'Create Assets'
                };                
                List<vlocity_cmt__OrchestrationItem__c> orchestrationItemsToUpdate = [SELECT vlocity_cmt__State__c, vlocity_cmt__AssignedToManualQueueId__c, vlocity_cmt__ErrorQueueId__c  
                    FROM vlocity_cmt__OrchestrationItem__c 
                    WHERE vlocity_cmt__FulfilmentRequestLineId__c IN :flrItemIds AND Name IN :skippedItems];
                for (vlocity_cmt__OrchestrationItem__c oI : orchestrationItemsToUpdate) {
                    oI.vlocity_cmt__State__c = 'Skipped';
                }

                // adding the SAP KO item to update once
                for (vlocity_cmt__OrchestrationItem__c orchItem : orchItems) {
                    orchestrationItemsToUpdate.add(orchItem);

                }
                update orchestrationItemsToUpdate;

            } else if (orders[0].Status == 'Sent to SAP') {
                //skipping the SAP KO branch
                for (vlocity_cmt__OrchestrationItem__c orchItem : orchItems) {
                    orchItem.vlocity_cmt__State__c = 'Skipped';
                }
                update orchItems;
            } 

            update flrLines;

        }
        
    }