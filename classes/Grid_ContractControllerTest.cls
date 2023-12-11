/**
* This class is a test class for ContractController Class
*  
* @author  Salesforce
* @version	1.0
*
*/
@isTest
public class Grid_ContractControllerTest {
    
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
    }
    @IsTest
    static void fetchGridProductHierarchyLevelTest() {
        Test.startTest();
        Grid_ContractController.Node node = new Grid_ContractController.Node('test','test');
        Integer level = Grid_ContractController.fetchGridProductHierarchyLevel();
        Assert.areEqual(5,level);
        Test.stopTest();
    }
    @IsTest
    static void getLineItemsByRootIdTest() {
        Test.startTest();
        Map<String, List<vlocity_cmt__ContractLineItem__c>> myMap = Grid_ContractController.getLineItemsByRootId([Select Id From Contract limit 1].Id);
        Assert.areNotEqual(null,myMap);
        Test.stopTest();
    }
     @IsTest
    static void getProductChildItemsByParentIdTest() {
        Test.startTest();
        Map<String, List<vlocity_cmt__ProductChildItem__c>> myMap = Grid_ContractController.getProductChildItemsByParentId([Select Id From Contract limit 1].Id);
        Assert.areNotEqual(null,myMap);
        Test.stopTest();
    }

}