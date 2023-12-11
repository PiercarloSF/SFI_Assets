@IsTest
private class Grid_OrderServiceClassTest {
    
     @TestSetup
    private static void prepareData() {
        Id pricebookId = Test.getStandardPricebookId(); 
        Account acc = (Account) TestDataFactory.createSObject(
            'Account',
            new Map<String, Object>{
              'Name' => 'TestAccount',
              'CurrencyIsoCode'=> 'EUR'
            },
            true
          );
        Opportunity oppo = (Opportunity) TestDataFactory.createSObject(
            'Opportunity',
            new Map<String, Object>{
               'StageName' => 'Internal Review',
               'Grid_StartContractDate__c' => System.today(),
               'AccountId' => acc.Id,
               'Grid_EndContractDate__c' => Date.newInstance(         
                 System.today().year()+3,
                 System.today().month(),
                 System.today().day()
                 )
              },
            true
          );
          vlocity_cmt__PriceList__c spainPriceList = (vlocity_cmt__PriceList__c) TestDataFactory.createSObject(
            'vlocity_cmt__PriceList__c',
            new Map<String, Object>{
              'CurrencyIsoCode' => 'EUR',
              'vlocity_cmt__Code__c' => 'testcode'
            },
            true
          );
          Quote quote = (Quote) TestDataFactory.createSObject(
            'Quote',
            new Map<String, Object>{
              'OpportunityId' => oppo.Id,
              'Pricebook2Id' => pricebookId
            },
            true
          );
          Product2 prod = (Product2) TestDataFactory.createSObject(
            'Product2',
            new Map<String, Object>{
              'Name' => 'Testing Product',
              'Grid_Category__c' => 'Hardware',
              'Grid_IsChild__c' => true   
            },
            true
          );
          Product2 prod2 = (Product2) TestDataFactory.createSObject(
            'Product2',
            new Map<String, Object>{
              'Name' => 'Testing Product22',
              'Grid_Category__c' => 'Software',
              'Grid_IsChild__c' => true
            },
            true
          );
          PricebookEntry priceBook = (PricebookEntry) TestDataFactory.createSObject(
            'PricebookEntry',
            new Map<String, Object>{
              'Pricebook2Id' => pricebookId,
              'Product2Id' => prod.Id,
              'Product2' => prod, 
              'IsActive' => true,
              'UnitPrice' => 0
            },
            true
          );
          PricebookEntry priceBook2 = (PricebookEntry) TestDataFactory.createSObject(
            'PricebookEntry',
            new Map<String, Object>{
              'Pricebook2Id' => pricebookId,
              'Product2Id' => prod2.Id,
              'Product2' => prod2, 
              'IsActive' => true,
              'UnitPrice' => 0
            },
            true
          );
    
          Quotelineitem qli = (Quotelineitem) TestDataFactory.createSObject(
            'Quotelineitem',
            new Map<String, Object>{
              'QuoteId' => quote.Id,
              'Quantity' => 3,
              'Product2' => prod,
              'PricebookEntryId' => priceBook.Id
            },
            true
          );
          Quotelineitem qli2 = (Quotelineitem) TestDataFactory.createSObject(
            'Quotelineitem',
            new Map<String, Object>{
              'QuoteId' => quote.Id,
              'Quantity' => 77,
              'Product2' => prod2,
              'PricebookEntryId' => priceBook.Id
            },
            true
          );
        // Create a mock Contract record
        Contract contract = (Contract) TestDataFactory.createSObject(
            'Contract',
            new Map<String, Object>{
                'Status' => 'Draft',
                'vlocity_cmt__OpportunityId__c' => oppo.Id,
                'vlocity_cmt__QuoteId__c' => quote.Id,
                'AccountId' => acc.Id,
                'Contract_Signature_Date__c' => System.today(),
                'startDatee__c' => System.today(),
                'Enddatee__c' => System.today() + 5
                },
                true
        );
        vlocity_cmt__ContractLineItem__c contractLine = (vlocity_cmt__ContractLineItem__c) TestDataFactory.createSObject(
            'vlocity_cmt__ContractLineItem__c',
            new Map<String, Object>{
                'vlocity_cmt__ContractId__c' => contract.Id,
                'vlocity_cmt__Product2Id__c' => prod2.id
            },
            true
        );
        vlocity_cmt__ContractLineItem__c contractLine2 = (vlocity_cmt__ContractLineItem__c) TestDataFactory.createSObject(
            'vlocity_cmt__ContractLineItem__c',
            new Map<String, Object>{
                'vlocity_cmt__ContractId__c' => contract.Id,
                'vlocity_cmt__Product2Id__c' => prod.id
            },
            true
        );
        Revenue__c revenue = (Revenue__c) TestDataFactory.createSObject(
            'Revenue__c',
            new Map<String, Object>{
                'Grid_Quote__c' => quote.Id,
                'Grid_Version__c' => 1
            },
        true
        );
		DeliveryPlan__c deliveryPlan = (DeliveryPlan__c) TestDataFactory.createSObject(
            'DeliveryPlan__c',
            new Map<String, Object>{
              'Grid_Quote__c' => quote.Id,
              'Grid_StartDate__c' => System.today(),
              'Grid_ScheduleCount__c' => 3,
              'Grid_ScheduleFrequency__c' => 'Yearly'
            },
            true
          );
          ProductSchedule__c prodSched1 = (ProductSchedule__c) TestDataFactory.createSObject(
            'ProductSchedule__c',
            new Map<String, Object>{
              'Grid_QuoteLineItem__c' => qli.Id,
              'Name' => DateTime.newInstance(         
                System.today().year(),
                System.today().month(),
                System.today().day()
                ).format('YYYY'),
              'Grid_Version__c' => 1,
              'Grid_Delivery_Plan__c' => deliveryPlan.Id,
              'Grid_SalesPric__c' => 100,
              'Grid_PlannedQuantity__c' => 2
            },
            true
          );        
        // Create a test revenue schedule record with some fields using the TestDataFactory class
        Grid_RevenueSchedule__c testRS = (Grid_RevenueSchedule__c) TestDataFactory.createSObject(
            'Grid_RevenueSchedule__c',
            new Map<String, Object>{ 
                'Grid_Metric__c' => 'One Time',
                'Grid_QuoteLineItem__c' => qli.Id,
                'Grid_PlannedAmount__c' => 100,
                'Grid_ActualAmount__c' => 90,
                'Grid_Revenue__c' => revenue.Id, 
                'Grid_Version__c' => 1,
                'Grid_ContractLine__c' => contractLine.Id
            },
            true
        );

    }
    
     @IsTest
    static void cloneRevenueTest() {
        Set<Id> contractsSet = new Set<Id>();
        contractsSet.add([Select Id From Contract limit 1].Id);
        Test.startTest();
        Grid_OrderServiceClass.cloneRevenue(contractsSet);
        Test.stopTest();
        List<Revenue__c> revenueList = [ SELECT Id, Grid_Quote__c  FROM Revenue__c];
        Assert.areEqual(2,revenueList.size(),'Revenue not cloned correctly');
    }

    @IsTest
    static void cloneRevenueSchedulesTest() {
        Set<Id> contractsSet = new Set<Id>();
        contractsSet.add([Select Id From Contract limit 1].Id);
        Test.startTest();
        Grid_OrderServiceClass.cloneRevenue(contractsSet);   
        Grid_OrderServiceClass.cloneRevenueSchedules(contractsSet);
        Assert.areEqual(2, [ SELECT Id  FROM Grid_RevenueSchedule__c].size());
        Test.stopTest();
    }

    @IsTest
    static void updateRevenueSchedulesActualTest() {
        Set<Id> contractsSet = new Set<Id>();
        contractsSet.add([Select Id From Contract limit 1].Id);
        Order order = TestDataFactory.createOrder([Select Id From Account Limit 1].Id,[Select Id From Contract limit 1].Id);         
        List<Order> ordersInvoiced = new List<Order>{ order };
        Order.Status = 'Delivered';
        Order.Grid_Delivery_Date__c = system.today();
        update Order; 
        Test.startTest();
        Grid_OrderServiceClass.cloneRevenue(contractsSet);
        Grid_OrderServiceClass.updateRevenueSchedulesActual(ordersInvoiced, false);
        Test.stopTest();
    }
     @IsTest
    static void updateRelatedProductScheduelleTest() {
        Set<Id> contractsSet = new Set<Id>();
        contractsSet.add([Select Id From Contract limit 1].Id);
        Order order = TestDataFactory.createOrder([Select Id From Account Limit 1].Id,[Select Id From Contract limit 1].Id);         
        List<Order> ordersInvoiced = new List<Order>{ order };
        Order.Status = 'Delivered';
        Order.Grid_Delivery_Date__c = system.today();
        update Order; 
        Test.startTest();
        Grid_OrderServiceClass.cloneRevenue(contractsSet);
        Grid_OrderServiceClass.updateRelatedProductScheduelle(ordersInvoiced);
        Test.stopTest();
    }

     @IsTest
    static void UpdateQuantityInContractLineTest() {
        
        Order order = TestDataFactory.createOrder([Select Id From Account Limit 1].Id,[Select Id From Contract limit 1].Id);  
        Order.Status = 'Delivered';
        update Order;
        OrderItem om = TestDataFactory.createOrderItems(order.Id);
        List<Order> ordersInvoiced = new List<Order>{ order };
        Test.startTest();
        Grid_OrderServiceClass.updateQuantityInContractLine(ordersInvoiced);
        Test.stopTest();
    }
     @IsTest
    static void updateFlrOrchestrationStatusTest() {
        Order order = TestDataFactory.createOrder([Select Id From Account Limit 1].Id,[Select Id From Contract limit 1].Id);
        Order.Status = 'SAP KO';
        update Order;
        OrderItem om = TestDataFactory.createOrderItems(order.Id);
        vlocity_cmt__OrchestrationItem__c orchI = TestDataFactory.createOrchestrationItem(order.Id,om.Id);
        List<Order> ordersInvoiced = new List<Order>{ order };
        Test.startTest();
        Grid_OrderServiceClass.updateFlrOrchestrationStatus(ordersInvoiced);
        Test.stopTest();
    }
    @IsTest
    static void nextScheduleNameTest() {
        Test.startTest();
        String output = Grid_OrderServiceClass.nextScheduleName('57.77');
        Assert.areEqual(output,'59');
        Test.stopTest();
    }

}