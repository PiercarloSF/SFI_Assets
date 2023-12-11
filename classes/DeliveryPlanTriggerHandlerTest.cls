/**
 * Class to test the delivery plan terms handler class 'DeliveryPlanTriggerHandler'
 *
 * @Author  Salesforce
 *
 */
@isTest
private class DeliveryPlanTriggerHandlerTest {
  @IsTest
  static void testDeliveryPlanTriggerHandlerAfterUpdate() {
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      Opportunity oppo = (Opportunity) TestDataFactory.createSObject(
        'Opportunity',
        new Map<String, Object>{ 'StageName' => 'Internal Review' },
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
          'Grid_Category__c' => 'Hardware'
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

      Quotelineitem qli1 = (Quotelineitem) TestDataFactory.createSObject(
        'Quotelineitem',
        new Map<String, Object>{
          'QuoteId' => qte.Id,
          'Quantity' => 3,
          'Product2' => prod,
          'PricebookEntryId' => priceBook.Id
        },
        true
      );
      Quotelineitem qli2 = (Quotelineitem) TestDataFactory.createSObject(
        'Quotelineitem',
        new Map<String, Object>{
          'QuoteId' => qte.Id,
          'Quantity' => 150,
          'Product2' => prod,
          'PricebookEntryId' => priceBook.Id
        },
        true
      );
      DeliveryPlan__c deliveryPlan1 = (DeliveryPlan__c) TestDataFactory.createSObject(
        'DeliveryPlan__c',
        new Map<String, Object>{
          'Grid_Quote__c' => qte.Id,
          'Grid_StartDate__c' => System.today(),
          'Grid_ScheduleCount__c' => 5,
          'Grid_ScheduleFrequency__c' => 'Yearly'
        },
        true
      );
      DeliveryPlan__c deliveryPlan2 = (DeliveryPlan__c) TestDataFactory.createSObject(
        'DeliveryPlan__c',
        new Map<String, Object>{
          'Grid_Quote__c' => qte.Id,
          'Grid_StartDate__c' => System.today(),
          'Grid_ScheduleCount__c' => 6,
          'Grid_ScheduleFrequency__c' => 'Yearly'
        },
        true
      );
      Test.startTest();
      deliveryPlan1.Grid_StartDate__c = System.today() + 1;
      deliveryPlan1.Grid_ScheduleCount__c = 7;
      List<DeliveryPlan__c> deliveryPlanList = new List<DeliveryPlan__c>();
      deliveryPlanList.add(deliveryPlan1);
      update deliveryPlanList;
      Test.stopTest();
    }
  }
}