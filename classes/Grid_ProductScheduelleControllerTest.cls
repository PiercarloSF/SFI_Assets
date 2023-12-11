/**
 * Class to test the product schedulelle controller class 'Grid_ProductScheduelleController'
 *
 * @Author  Salesforce
 *
 */
@isTest
private class Grid_ProductScheduelleControllerTest {
  @IsTest
  static void testGetProductSchedules() {
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      Test.startTest();
      Opportunity opp = (Opportunity) TestDataFactory.createSObject(
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
      Quote q = (Quote) TestDataFactory.createSObject(
        'Quote',
        new Map<String, Object>{
          'opportunityId' => opp.Id,
          'Pricebook2Id' => pricebookId
        },
        true
      );
      Product2 p2 = (Product2) TestDataFactory.createSObject(
        'Product2',
        new Map<String, Object>{ 'Name' => 'product name example' },
        true
      );
      PricebookEntry priceBook = (PricebookEntry) TestDataFactory.createSObject(
        'PricebookEntry',
        new Map<String, Object>{
          'Pricebook2Id' => pricebookId,
          'Product2Id' => p2.Id,
          'IsActive' => true,
          'UnitPrice' => 0
        },
        true
      );
      QuoteLineItem qli = (QuoteLineItem) TestDataFactory.createSObject(
        'QuoteLineItem',
        new Map<String, Object>{
          'Quantity' => 1,
          'PricebookEntryId' => priceBook.Id,
          'Product2Id' => p2.Id,
          'QuoteId' => q.Id
        },
        true
      );
      ProductSchedule__c productSchedule = (ProductSchedule__c) TestDataFactory.createSObject(
        'ProductSchedule__c',
        new Map<String, Object>{
          'Grid_PlannedQuantity__c' => 1,
          'Grid_SalesPric__c' => 1,
          'Grid_StartDate__c' => system.today(),
          'Grid_EndDate__c' => system.today() + 1,
          'Grid_OrderSort__c' => 1,
          'Grid_QuoteLineItem__c' => qli.Id
        },
        true
      );
      List<Grid_DeliveryPlanTerm> deliveryPlans = Grid_ProductScheduelleController.getProductSchedules(
        q.Id
      );
      Test.stopTest();
      QuoteLineItem myQli = [
        SELECT Id, LineNumber
        FROM QuoteLineItem
        WHERE Id = :qli.Id
        LIMIT 1
      ];
      System.assert(deliveryPlans.size() > 0, 'List should contains records');
      System.assertEquals(
        p2.Name + '_' + myQli.LineNumber,
        deliveryPlans[0].productNameId,
        'Wrong product name Id'
      );
      System.assertEquals(
        p2.Name,
        deliveryPlans[0].productName,
        'Wrong product name'
      );
    }
  }
  @IsTest
  static void testUpdateProductSchedules() {
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      Test.startTest();
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
      DeliveryPlan__c deliveryPlan = (DeliveryPlan__c) TestDataFactory.createSObject(
        'DeliveryPlan__c',
        new Map<String, Object>{
          'Grid_Quote__c' => qte.Id,
          'Grid_StartDate__c' => System.today(),
          'Grid_ScheduleCount__c' => 1,
          'Grid_ScheduleFrequency__c' => 'One time'
        },
        true
      );
      Grid_ProductScheduelleController.refreshDeliveryPlan(qte.Id);
      Test.stopTest();
    }
  }
}