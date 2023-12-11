@isTest
public class Grid_VL_ContextRuleFunctionsTest {
    @IsTest
    private static void getContractProductTest() {
        
        Id pricebookId = Test.getStandardPricebookId();
        Opportunity oppo = (Opportunity) TestDataFactory.createSObject(
            'Opportunity',
            new Map<String, Object>{ 'StageName' => 'Internal Review','CurrencyIsoCode' => 'EUR'},
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
        vlocity_cmt__PriceList__c spainPriceList = (vlocity_cmt__PriceList__c) TestDataFactory.createSObject(
            'vlocity_cmt__PriceList__c',
            new Map<String, Object>{ 'CurrencyIsoCode' => 'EUR' },
            true
        );
        Product2 p2 =  (Product2) TestDataFactory.createSObject(
            'Product2',
            new Map<String, Object>{ 'name' => 'y' },
            true
        );
        PricebookEntry pricebookEntry =  (PricebookEntry) TestDataFactory.createSObject(
            'PricebookEntry',
            new Map<String, Object>{ 'UnitPrice' => 10,
                'Pricebook2Id' =>  pricebookId,
                'Product2Id' => p2.Id,
                'IsActive' => true},
            true
        );
        Quote quote = (Quote) TestDataFactory.createSObject(
            'Quote',
            new Map<String, Object>{ 'OpportunityId' => oppo.Id , 'Pricebook2Id' => pricebookId },
            true
        );
        Contract c = (Contract) TestDataFactory.createSObject(
            'Contract',
            new Map<String, Object>{
                'Status' => 'Draft',
                    'vlocity_cmt__OpportunityId__c' => oppo.Id,
                    'vlocity_cmt__QuoteId__c' => quote.Id,
                    'Contract_Signature_Date__c' => System.today(),
                    'startDatee__c' => System.today(),
                    'Enddatee__c' => System.today() + 5
                    },
            true
        );
        //List<QuoteLineItem> qlilist = TestDataFactory.createQuoteLineItem(quote,3);
        vlocity_cmt__ContractLineItem__c contractLine = (vlocity_cmt__ContractLineItem__c) TestDataFactory.createSObject(
            'vlocity_cmt__ContractLineItem__c',
            new Map<String, Object>{
                'vlocity_cmt__ContractId__c' => c.Id,
                    'vlocity_cmt__Product2Id__c'=>p2.Id,
                    'OpenMeterFormula__c' => null,
                    'vlocity_cmt__OneTimeCharge__c'=>10,
                    'vlocity_cmt__OneTimeTotal__c'=>20
                    },
            true
        );
        Order order = (Order) TestDataFactory.createSObject(
            'Order',
            new Map<String, Object>{
                'AccountId' => acc.Id,
                    'EffectiveDate' => System.today(),
                    'Status' => 'Draft',
                    'vlocity_cmt__FrameContractId__c' => c.ContractNumber,
                    'Pricebook2Id' => pricebookId
                    
                    },
            true
        );
        
        
        
        OrderItem orderItem = (OrderItem) TestDataFactory.createSObject(
            'OrderItem',
            new Map<String, Object>{
                'OrderId' => order.Id,
                    'Product2Id' => p2.Id,
                    'Quantity' => 50,
                    //'Grid_ContractLine__c' => contractLine.Id,
                    'PricebookEntryId'=> pricebookEntry.Id,
                    'UnitPrice'=> 30
                    },
            true
        );
        OrderItem secondOrderItem = (OrderItem) TestDataFactory.createSObject(
            'OrderItem',
            new Map<String, Object>{
                'OrderId' => order.Id,
                    'Product2Id' => p2.Id,
                    'Quantity' => 10,
                    //'Grid_ContractLine__c' => contractLine.Id,
                    'PricebookEntryId'=> pricebookEntry.Id,
                    'UnitPrice'=> 30
                    
                    
                    },
            true
        );   
        system.debug('product id test'+p2.Id);
        
        
        
        Map<String, List<Object>> input = new Map<String, List<Object>>();
        List<Object> listInupts= new List<Object>();
        listInupts.add(order.Id);
        listInupts.add(p2.Id);
        input.put('arguments',listInupts);
        Test.StartTest();
        Grid_VL_ContextRuleFunctions remoteActionClass = new Grid_VL_ContextRuleFunctions(); 
        boolean check=remoteActionClass.invokeMethod('getContractProduct',input, new Map<String,Object>(), new Map<String,Object>());
        Assert.areEqual(true, check);
        Test.StopTest(); 
    } 
    
}