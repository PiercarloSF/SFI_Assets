/**
* This class is a test class for Grid_SFIAllRemoteAction
*  
* @author	
* @version	1.0
*
*/
@isTest
private class Grid_SFIAllRemoteActionTest {
    
    
    @TestSetup
    private static void prepareData() {      
        Account acc = new Account(Name='AES');     
        Opportunity oppo = (Opportunity) TestDataFactory.createSObject(
        'Opportunity',
        new Map<String, Object>{ 'StageName' => 'Internal Review' },
        true
      );
      vlocity_cmt__PriceList__c spainPriceList = (vlocity_cmt__PriceList__c) TestDataFactory.createSObject(
        'vlocity_cmt__PriceList__c',
        new Map<String, Object>{
          'CurrencyIsoCode' => 'EUR',
          'vlocity_cmt__Code__c' => 'PL_ITALY_EUR'
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
      List<Quotelineitem> qlis = TestDataFactory.createQuoteLineItem(qte, 2);
        Contract c = (Contract) TestDataFactory.createSObject(
            'Contract',
            new Map<String, Object>{
                'Status' => 'Draft',
                    'vlocity_cmt__OpportunityId__c' => oppo.Id,
                    'Contract_Signature_Date__c' => System.today(),
                    'startDatee__c' => System.today(),
                    'Enddatee__c' => System.today() + 5
                    },
            true
        );
        
        Order order = TestDataFactory.createOrder(acc.Id,c.Id);
        OrderItem om = TestDataFactory.createOrderItems(order.Id);

    }
    
    private static quote getQuote(){ 
        return [ SELECT Id FROM Quote LIMIT 1];
    }
    private static Contract getContract(){ 
        return [ SELECT Id FROM Contract LIMIT 1]; 
    }
    
    
    @IsTest
    private static void createContractLItemsTest(){
        Map<String,Object> input = new Map<String, Object>{ 'quoteId' => getQuote().Id ,'contractId' => getContract().Id};
        Grid_SFIAllRemoteAction remoteActionClass = new Grid_SFIAllRemoteAction();
        Test.StartTest(); 
        remoteActionClass.invokeMethod('createContractLItems',input, new Map<String,Object>(), new Map<String,Object>());
        Assert.areEqual(1, [select id from vlocity_cmt__ContractLineItem__c].size()); 
        Test.StopTest(); 
    } 
    @IsTest
    private static void doCloneWithLineItemsTest(){
        
        Map<String,Object> input = new Map<String, Object>{ 'recordId' => getQuote().Id};
        Grid_SFIAllRemoteAction remoteActionClass = new Grid_SFIAllRemoteAction();
        Test.StartTest(); 
        remoteActionClass.invokeMethod('doCloneWithLineItems',input, new Map<String,Object>(), new Map<String,Object>());
        Assert.areEqual(2, [select id from Quote].size()); 
        Test.StopTest(); 
    } 
    
    @IsTest
    private static void checkSumOfOrderProductQuantitiesTest(){
        
        Map<String,Object> input = new Map<String, Object>{ 'recordId' => getQuote().Id};
        Grid_SFIAllRemoteAction remoteActionClass = new Grid_SFIAllRemoteAction();
        input.put('orderId',[Select Id From Order limit 1].Id);
        Test.StartTest(); 
        Boolean check = remoteActionClass.invokeMethod('checkSumOfOrderProductQuantities',input, new Map<String,Object>(), new Map<String,Object>());
        Assert.areEqual(true, check); 
        Test.StopTest(); 
    } 
    
    @IsTest
    private static void refreshContractRecordPageTest(){
        
        Map<String,Object> input = new Map<String, Object>{ 'recordId' => getQuote().Id};
        Grid_SFIAllRemoteAction remoteActionClass = new Grid_SFIAllRemoteAction();
        Test.StartTest(); 
        Boolean check = remoteActionClass.invokeMethod('refreshContractRecordPage',input, new Map<String,Object>(), new Map<String,Object>());
        Test.StopTest(); 
    } 
    
}