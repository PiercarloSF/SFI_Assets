@IsTest
private class Grid_RevenueScheduleControllerTest {
    @isTest
    public static void testGetContractStatus(){
        // Create a test contract using the TestDataFactory class
        Contract testContract = (Contract) TestDataFactory.createSObject(
            'Contract',
            new Map<String, Object>{ 'Status' => 'Draft' },
            true
          );
        // Call the apex method with the test contract id
        Test.startTest();
        String status = Grid_RevenueScheduleController.getContractStatus(testContract.Id);
        Test.stopTest();
    
        // Assert that the status is correct
        System.assertEquals('Draft', status, 'The status should match the test contract status');
    
        // Call the apex method with a null id and catch the exception
        try {
            Grid_RevenueScheduleController.getContractStatus(null);
            System.assert(false, 'The method should throw an exception when the id is null');
        } catch (AuraHandledException e) {
            // Assert that AuraHandledException is thrown
            System.assertEquals('System.AuraHandledException', e.getTypeName(), 'The exception type should be correct');
        }
    
        // Call the apex method with an invalid id and assert that the status is empty
        String invalidId = '001000000000000';
        status = Grid_RevenueScheduleController.getContractStatus(invalidId);
        System.assertEquals('', status, 'The status should be empty when the id is invalid');
    }
    

    @isTest
    public static void testGenerateRevenue(){
        Opportunity oppo = (Opportunity) TestDataFactory.createSObject(
            'Opportunity',
            new Map<String, Object>{
               'StageName' => 'Internal Review',
               'Grid_StartContractDate__c' => System.today(),
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
          Id pricebookId = Test.getStandardPricebookId();
          Quote qte = (Quote) TestDataFactory.createSObject(
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
    
          Quotelineitem qli = (Quotelineitem) TestDataFactory.createSObject(
            'Quotelineitem',
            new Map<String, Object>{
              'QuoteId' => qte.Id,
              'Quantity' => 3,
              'Product2' => prod,
              'PricebookEntryId' => priceBook.Id
            },
            true
          );
          DeliveryPlan__c deliveryPlan = (DeliveryPlan__c) TestDataFactory.createSObject(
            'DeliveryPlan__c',
            new Map<String, Object>{
              'Grid_Quote__c' => qte.Id,
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
          ProductSchedule__c prodSched2 = (ProductSchedule__c) TestDataFactory.createSObject(
            'ProductSchedule__c',
            new Map<String, Object>{
              'Grid_QuoteLineItem__c' => qli.Id,
              'Name' => DateTime.newInstance(         
                System.today().year()+1,
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
          ProductSchedule__c prodSched3 = (ProductSchedule__c) TestDataFactory.createSObject(
            'ProductSchedule__c',
            new Map<String, Object>{
              'Grid_QuoteLineItem__c' => qli.Id,
              'Name' => DateTime.newInstance(         
                System.today().year()+2,
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
          Revenue__c revenue = (Revenue__c) TestDataFactory.createSObject(
            'Revenue__c',
            new Map<String, Object>{
              'Grid_Quote__c' => qte.Id,
              'Grid_Version__c' => 1
            },
            true
          );

        // Call the apex method with the test quote id
        Test.startTest();
        Grid_RevenueScheduleController.generateRevenue(qte.Id);
        Test.stopTest();
    }


    @isTest
    public static void testGetRevenueSchedulesWithQuote(){
        Opportunity oppo = (Opportunity) TestDataFactory.createSObject(
            'Opportunity',
            new Map<String, Object>{
            'StageName' => 'Internal Review',
            'Grid_StartContractDate__c' => System.today(),
            'Grid_EndContractDate__c' => Date.newInstance(         
                System.today().year()+3,
                System.today().month(),
                System.today().day()
                )
            },
            true
        );
        Id pricebookId = Test.getStandardPricebookId();
        vlocity_cmt__PriceList__c spainPriceList = (vlocity_cmt__PriceList__c) TestDataFactory.createSObject(
            'vlocity_cmt__PriceList__c',
            new Map<String, Object>{
            'CurrencyIsoCode' => 'EUR',
            'vlocity_cmt__Code__c' => 'testcode'
            },
            true
        );
        Quote testQuote = (Quote) TestDataFactory.createSObject(
            'Quote',
            new Map<String, Object>{
            'OpportunityId' => oppo.Id,
            'Pricebook2Id' => pricebookId
            },
            true
        );

        Product2 testProduct = (Product2) TestDataFactory.createSObject(
            'Product2',
            new Map<String, Object>{
              'Name' => 'Testing Product',
              'Grid_Category__c' => 'Hardware',
              'Grid_IsChild__c' => true
            },
            true
          );
          PricebookEntry priceBook = (PricebookEntry) TestDataFactory.createSObject(
            'PricebookEntry',
            new Map<String, Object>{
              'Pricebook2Id' => pricebookId,
              'Product2Id' => testProduct.Id,
              'Product2' => testProduct,
              'IsActive' => true,
              'UnitPrice' => 0
            },
            true
          );
    
          Quotelineitem testQLI = (Quotelineitem) TestDataFactory.createSObject(
            'Quotelineitem',
            new Map<String, Object>{
              'QuoteId' => testQuote.Id,
              'Quantity' => 3,
              'Product2' => testProduct,
              'PricebookEntryId' => priceBook.Id
            },
            true
          );


        // Create a test contract with some fields using the TestDataFactory class
        Contract testContract = (Contract) TestDataFactory.createSObject(
            'Contract',
            new Map<String, Object>{ 'Status' => 'Draft', 'vlocity_cmt__QuoteId__c' => testQuote.Id},
            true
        );

        vlocity_cmt__ContractLineItem__c testCL = (vlocity_cmt__ContractLineItem__c) TestDataFactory.createSObject(
            'vlocity_cmt__ContractLineItem__c',
            new Map<String, Object>{ 'vlocity_cmt__ContractId__c' => testContract.Id,
                'vlocity_cmt__Product2Id__c'=>testProduct.Id,
                    'OpenMeterFormula__c' => null,
                    'vlocity_cmt__OneTimeCharge__c'=>10,
                    'vlocity_cmt__OneTimeTotal__c'=>20,
                'vlocity_cmt__LineNumber__c'=>'abc'},
            true
        );


        // Create a test revenue record with some fields using the TestDataFactory class
        Revenue__c testRevenue = (Revenue__c) TestDataFactory.createSObject(
            'Revenue__c',
            new Map<String, Object>{ 'Grid_Quote__c' => testQuote.Id, 'Grid_Version__c' => 2},
            true
        );

        // Create a test revenue schedule record with some fields using the TestDataFactory class
        Grid_RevenueSchedule__c testRS = (Grid_RevenueSchedule__c) TestDataFactory.createSObject(
            'Grid_RevenueSchedule__c',
            new Map<String, Object>{ 
                'Grid_Metric__c' => 'One Time',
                'Grid_QuoteLineItem__c' => testQLI.Id,
                'Grid_PlannedAmount__c' => 100,
                'Grid_ActualAmount__c' => 90,
                'Grid_Revenue__c' => testRevenue.Id,
                'Grid_Version__c' => 1,
                'Grid_ContractLine__c' => testCL.Id
            },
            true
        );

        // Call the apex method with the test quote id and store the result
        Test.startTest();
        List<Grid_Revenue> result1 = Grid_RevenueScheduleController.getRevenueSchedules(testQuote.Id);
        Test.stopTest();

        // Assert that the result is not null and has one element
        System.assertNotEquals(null, result1, 'The result should not be null');
        System.assertEquals(1, result1.size(), 'The result should have one element');

        // query the quote line item using SOQL to get the LineNumber
        Quotelineitem qli = [select LineNumber from Quotelineitem where Id = :testQLI.Id];

        // Assert that the element has the correct fields and values
        Grid_Revenue revenue1 = result1[0];
        System.assertEquals(testProduct.Name + '_' + testRS.Grid_Metric__c + '_' + qli.LineNumber, revenue1.productId, 'The productId should be correct');
        System.assertEquals(false, revenue1.showActuals, 'The showActuals should be false');
        System.assertEquals('Quote', revenue1.objectName, 'The objectName should be Quote');
        System.assertEquals('Revenue Calculation Version 1', revenue1.title, 'The title should be correct');

        // Call the apex method with a null id and catch the exception
        try {
            Grid_RevenueScheduleController.getRevenueSchedules(null);
            System.assert(false, 'The method should throw an exception when the id is null');
        } catch (AuraHandledException e) {
            System.assertEquals('System.AuraHandledException', e.getTypeName(), 'The exception type should be correct');
        }
       
    }

    @isTest
    public static void testGetRevenueSchedulesWithContract(){
        Opportunity oppo = (Opportunity) TestDataFactory.createSObject(
            'Opportunity',
            new Map<String, Object>{
            'StageName' => 'Internal Review',
            'Grid_StartContractDate__c' => System.today(),
            'Grid_EndContractDate__c' => Date.newInstance(         
                System.today().year()+3,
                System.today().month(),
                System.today().day()
                )
            },
            true
        );
         Account acc = (Account) TestDataFactory.createSObject(
            'Account',
            new Map<String, Object>{
                'Name' => 'TestAccount',
                    'CurrencyIsoCode'=> 'EUR'
                    },
            true
        );
        Id pricebookId = Test.getStandardPricebookId();
        vlocity_cmt__PriceList__c spainPriceList = (vlocity_cmt__PriceList__c) TestDataFactory.createSObject(
            'vlocity_cmt__PriceList__c',
            new Map<String, Object>{
            'CurrencyIsoCode' => 'EUR',
            'vlocity_cmt__Code__c' => 'testcode'
            },
            true
        );
        Quote testQuote = (Quote) TestDataFactory.createSObject(
            'Quote',
            new Map<String, Object>{
            'OpportunityId' => oppo.Id,
            'Pricebook2Id' => pricebookId
            },
            true
        );

        Product2 testProduct = (Product2) TestDataFactory.createSObject(
            'Product2',
            new Map<String, Object>{
              'Name' => 'Testing Product',
              'Grid_Category__c' => 'Hardware',
              'Grid_IsChild__c' => true
            },
            true
          );
          PricebookEntry priceBook = (PricebookEntry) TestDataFactory.createSObject(
            'PricebookEntry',
            new Map<String, Object>{
              'Pricebook2Id' => pricebookId,
              'Product2Id' => testProduct.Id,
              'Product2' => testProduct,
              'IsActive' => true,
              'UnitPrice' => 0
            },
            true
          );
    
          Quotelineitem testQLI = (Quotelineitem) TestDataFactory.createSObject(
            'Quotelineitem',
            new Map<String, Object>{
              'QuoteId' => testQuote.Id,
              'Quantity' => 3,
              'Product2' => testProduct,
              'PricebookEntryId' => priceBook.Id
            },
            true
          );


        // Create a test contract with some fields using the TestDataFactory class
        Contract testContract = (Contract) TestDataFactory.createSObject(
            'Contract',
            new Map<String, Object>{ 'Status' => 'Draft', 'vlocity_cmt__QuoteId__c' => testQuote.Id},
            true
        );

        vlocity_cmt__ContractLineItem__c testCL = (vlocity_cmt__ContractLineItem__c) TestDataFactory.createSObject(
            'vlocity_cmt__ContractLineItem__c',
            new Map<String, Object>{ 'vlocity_cmt__ContractId__c' => testContract.Id},
            true
        );


        // Create a test revenue record with some fields using the TestDataFactory class
        Revenue__c testRevenue = (Revenue__c) TestDataFactory.createSObject(
            'Revenue__c',
            new Map<String, Object>{ 'Grid_Quote__c' => testQuote.Id, 'Grid_Version__c' => 2},
            true
        );

        // Create a test revenue schedule record with some fields using the TestDataFactory class
        Grid_RevenueSchedule__c testRS = (Grid_RevenueSchedule__c) TestDataFactory.createSObject(
            'Grid_RevenueSchedule__c',
            new Map<String, Object>{ 
                'Grid_Metric__c' => 'One Time',
                'Grid_QuoteLineItem__c' => testQLI.Id,
                'Grid_PlannedAmount__c' => 100,
                'Grid_ActualAmount__c' => 90,
                'Grid_Revenue__c' => testRevenue.Id,
                'Grid_Version__c' => 1,
                'Grid_ContractLine__c' => testCL.Id
            },
            true
        );
        /*Order order = (Order) TestDataFactory.createSObject(
            'Order',
            new Map<String, Object>{
                //'AccountId' => acc.Id,
                     'ContractId'=>testContract.Id,
                    'EffectiveDate' => System.today(),
                    'Status' => 'Closed',
                    'vlocity_cmt__FrameContractId__c' => testContract.ContractNumber,
                    'Pricebook2Id' => pricebookId                    
                    },
            true
        );*/
         /*Order order1 = (Order) TestDataFactory.createSObject(
            'Order',
            new Map<String, Object>{
                //'AccountId' => acc.Id,
                     'ContractId'=>testContract.Id,
                    'EffectiveDate' => System.today(),
                    'Status' => 'Delivered',
                    'vlocity_cmt__FrameContractId__c' => testContract.ContractNumber,
                    'Pricebook2Id' => pricebookId                    
                    },
            true
        );*/

        Test.startTest();
        List<Grid_Revenue> result2 = Grid_RevenueScheduleController.getRevenueSchedules(testContract.Id);
        List<Revenue__c> revenues = Grid_RevenueScheduleController.getRevenueList(testContract.Id);
        Grid_RevenueScheduleController.refreshRevenueSchedulesV2(testContract.Id);
        Test.stopTest();

        // Assert that the result is not null and has one element
        System.assertNotEquals(null, result2, 'The result should not be null');
        System.assertEquals(1, result2.size(), 'The result should have one element');
        // query the quote line item using SOQL to get the LineNumber
        Quotelineitem qli = [select LineNumber from Quotelineitem where Id = :testQLI.Id];
        // Assert that the element has the correct fields and values
        Grid_Revenue revenue2 = result2[0];
        System.assertEquals(testProduct.Name + '_' + testRS.Grid_Metric__c + '_' + qli.LineNumber, revenue2.productId, 'The productId should be correct');
        System.assertEquals(false, revenue2.showActuals, 'The showActuals should be false');
        System.assertEquals('Contract', revenue2.objectName, 'The objectName should be Contract');
        System.assertEquals('Revenue Calculation Version 1', revenue2.title, 'The title should be correct');
        // Call the apex method with a null id and catch the exception
        try {
            Grid_RevenueScheduleController.getRevenueSchedules(null);
            System.assert(false, 'The method should throw an exception when the id is null');
        } catch (AuraHandledException e) {
            System.assertEquals('System.AuraHandledException', e.getTypeName(), 'The exception type should be correct');
        }
    }
    
    
}