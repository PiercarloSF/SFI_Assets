/**
 * Class to test the quote service class 'Grid_QuoteServiceClass'
 *
 * @Author  Salesforce
 *
 */
@isTest
private class Grid_QuoteServiceClassTest {
  @IsTest
  static void opportunityStatusShouldBeInStageNegociation() {
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      Test.startTest();
      vlocity_cmt__PriceList__c italyPriceList = (vlocity_cmt__PriceList__c) TestDataFactory.createSObject(
        'vlocity_cmt__PriceList__c',
        new Map<String, Object>{
          'CurrencyIsoCode' => 'EUR',
          'vlocity_cmt__Code__c' => 'PL_ITALY_EUR',
          'Name' => 'B2B Pricelist Italy'
        },
        true
      );
      vlocity_cmt__PriceList__c spainPriceList = (vlocity_cmt__PriceList__c) TestDataFactory.createSObject(
        'vlocity_cmt__PriceList__c',
        new Map<String, Object>{
          'CurrencyIsoCode' => 'EUR',
          'vlocity_cmt__Code__c' => 'PL_SPAIN_EUR',
          'Name' => 'B2B Pricelist Spain'
        },
        true
      );
      Opportunity oppo = (Opportunity) TestDataFactory.createSObject(
        'Opportunity',
        new Map<String, Object>{
          'StageName' => 'Internal Review',
          'Grid_OpportunityCurrency__c' => 'EUR',
          'Grid_CurrencyCountry__c' => 'Spain',
          'Grid_StartContractDate__c ' => System.Today(),
          'Grid_EndContractDate__c ' => System.Today()+ 7
        },
        true
      );

      Quote qte = (Quote) TestDataFactory.createSObject(
        'Quote',
        new Map<String, Object>{ 'OpportunityId' => oppo.Id },
        true
      );
      DeliveryPlan__c deliveryPlan = (DeliveryPlan__c) TestDataFactory.createSObject(
        'DeliveryPlan__c',
        new Map<String, Object>{ 'Grid_Quote__c' => qte.Id },
        false
      );
      List<Quote> quotes = new List<Quote>{ qte };
      quotes[0].Status = 'Approved';
      Set<Id> opportunityIds = new Set<Id>{ oppo.Id };

      Grid_QuoteServiceClass.updateOpportunityStage(quotes, opportunityIds);
      Test.stopTest();
      System.assertEquals(
        'Negotiation',
        [
          SELECT Id, Opportunity.StageName
          FROM Quote
          WHERE Id = :quotes[0].Id
          LIMIT 1
        ]
        .Opportunity.StageName,
        'Wrong Opportunity Stage Name'
      );
    }
  }

  @IsTest
  static void opportunityStatusShouldBeInStageClosedWon() {
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      Test.startTest();
      vlocity_cmt__PriceList__c italyPriceList = (vlocity_cmt__PriceList__c) TestDataFactory.createSObject(
        'vlocity_cmt__PriceList__c',
        new Map<String, Object>{
          'CurrencyIsoCode' => 'EUR',
          'vlocity_cmt__Code__c' => 'PL_ITALY_EUR',
          'Name' => 'B2B Pricelist Italy'
        },
        true
      );
      Opportunity oppo = (Opportunity) TestDataFactory.createSObject(
        'Opportunity',
        new Map<String, Object>{
          'StageName' => 'Internal Review',
          'Grid_OpportunityCurrency__c' => 'EUR'
        },
        true
      );

      Quote qte = (Quote) TestDataFactory.createSObject(
        'Quote',
        new Map<String, Object>{ 'OpportunityId' => oppo.Id },
        true
      );
      DeliveryPlan__c deliveryPlan = (DeliveryPlan__c) TestDataFactory.createSObject(
        'DeliveryPlan__c',
        new Map<String, Object>{ 'Grid_Quote__c' => qte.Id },
        false
      );
      List<Quote> quotes = new List<Quote>{ qte };
      quotes[0].Status = 'Finalized';
      Set<Id> opportunityIds = new Set<Id>{ oppo.Id };

      Grid_QuoteServiceClass.updateOpportunityStage(quotes, opportunityIds);
      Test.stopTest();
      System.assertEquals(
        'Closed Won',
        [
          SELECT Id, Opportunity.StageName
          FROM Quote
          WHERE Id = :quotes[0].Id
          LIMIT 1
        ]
        .Opportunity.StageName,
        'Wrong Opportunity Stage Name'
      );
    }
  }

  @IsTest
  static void opportunityStatusShouldBeInStageClosedAwarded() {
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      Test.startTest();
      Opportunity oppo = (Opportunity) TestDataFactory.createSObject(
        'Opportunity',
        new Map<String, Object>{
          'StageName' => 'Internal Review',
          'Grid_TypeOfOpportunity__c' => 'Tender'
        },
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
      Quote qte = (Quote) TestDataFactory.createSObject(
        'Quote',
        new Map<String, Object>{ 'OpportunityId' => oppo.Id },
        true
      );
      DeliveryPlan__c deliveryPlan = (DeliveryPlan__c) TestDataFactory.createSObject(
        'DeliveryPlan__c',
        new Map<String, Object>{ 'Grid_Quote__c' => qte.Id },
        false
      );
      List<Quote> quotes = new List<Quote>{ qte };
      quotes[0].Status = 'Finalized';
      Set<Id> opportunityIds = new Set<Id>{ oppo.Id };

      Grid_QuoteServiceClass.updateOpportunityStage(quotes, opportunityIds);
      Test.stopTest();
      System.assertEquals(
        'Closed Awarded',
        [
          SELECT Id, Opportunity.StageName
          FROM Quote
          WHERE Id = :quotes[0].Id
          LIMIT 1
        ]
        .Opportunity.StageName,
        'Wrong Opportunity Stage Name'
      );
      System.assertEquals(
        System.today(),
        [
          SELECT Id, Opportunity.Grid_AwardedDate__c
          FROM Quote
          WHERE Id = :quotes[0].Id
          LIMIT 1
        ]
        .Opportunity.Grid_AwardedDate__c,
        'Wrong Opportunity Stage Name'
      );
    }
  }

  @IsTest
  static void testProgressiveQuoteNumber() {
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
          'vlocity_cmt__Code__c' => 'PL_ITALY_EUR'
        },
        true
      );
      TestDataFactory.createSObject(
        'Quote',
        new Map<String, Object>{ 'OpportunityId' => oppo.Id },
        true
      );
      TestDataFactory.createSObject(
        'Quote',
        new Map<String, Object>{ 'OpportunityId' => oppo.Id },
        true
      );
      TestDataFactory.createSObject(
        'Quote',
        new Map<String, Object>{ 'OpportunityId' => oppo.Id },
        true
      );
      Test.stopTest();
      List<Quote> result = [
        SELECT Id, Grid_QuoteAutoNumber__c
        FROM Quote
        WHERE OpportunityId = :oppo.Id
        ORDER BY Grid_QuoteAutoNumber__c
      ];
      System.assertEquals(
        3,
        result.size(),
        'No quote has been created for the opportunity'
      );
      System.assertEquals(
        1,
        result[0].Grid_QuoteAutoNumber__c,
        'Wrong quote number'
      );
      System.assertEquals(
        3,
        result[2].Grid_QuoteAutoNumber__c,
        'Wrong quote number'
      );
    }
  }

  @IsTest
  static void testCreateProductSchedulesOneTime() {
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
      DeliveryPlan__c deliveryPlan = (DeliveryPlan__c) TestDataFactory.createSObject(
        'DeliveryPlan__c',
        new Map<String, Object>{
          'Grid_Quote__c' => qte.Id,
          'Grid_StartDate__c' => System.today(),
          'Grid_ScheduleCount__c' => 1,
          'Grid_ScheduleFrequency__c' => 'One time'
        },
        false
      );
      List<DeliveryPlan__c> deliveryPlanList = new List<DeliveryPlan__c>();
      deliveryPlanList.add(deliveryPlan);
      Set<Id> QuoteIds = new Set<Id>();
      QuoteIds.add(qte.Id);
      Grid_QuoteServiceClass.createProductSchedule(deliveryPlanList, QuoteIds);
      Test.stopTest();

      List<ProductSchedule__c> productSchedules = [
        SELECT Id, Grid_QuoteLineItem__c, Name
        FROM ProductSchedule__c
        WHERE Grid_QuoteLineItem__c = :qlis[0].Id
      ];
      System.assertEquals(
        1,
        productSchedules.size(),
        'No product schedules were created'
      );
      System.assertEquals(
        System.today().format(),
        productSchedules[0].Name,
        'Wrong product schedule name'
      );
    }
  }
  @IsTest
  static void testCreateProductSchedulesWeekly() {
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

      DeliveryPlan__c deliveryPlan = (DeliveryPlan__c) TestDataFactory.createSObject(
        'DeliveryPlan__c',
        new Map<String, Object>{
          'Grid_Quote__c' => qte.Id,
          'Grid_StartDate__c' => System.today(),
          'Grid_ScheduleCount__c' => 4,
          'Grid_ScheduleFrequency__c' => 'Weekly'
        },
        false
      );
      List<DeliveryPlan__c> deliveryPlanList = new List<DeliveryPlan__c>();
      deliveryPlanList.add(deliveryPlan);
      Set<Id> QuoteIds = new Set<Id>();
      QuoteIds.add(qte.Id);
      Grid_QuoteServiceClass.createProductSchedule(deliveryPlanList, QuoteIds);
      Test.stopTest();

      List<ProductSchedule__c> productSchedules = [
        SELECT Id, Grid_QuoteLineItem__c, Name
        FROM ProductSchedule__c
        WHERE Grid_QuoteLineItem__c = :qlis[0].Id
      ];
      System.assertEquals(
        4,
        productSchedules.size(),
        'No product schedules were created'
      );
      System.assertEquals(
        System.today().format() + '-' + System.today().addDays(7).format(),
        productSchedules[0].Name,
        'Wrong product schedule name'
      );
    }
  }
  @IsTest
  static void testCreateProductSchedulesMonthly() {
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

      DeliveryPlan__c deliveryPlan = (DeliveryPlan__c) TestDataFactory.createSObject(
        'DeliveryPlan__c',
        new Map<String, Object>{
          'Grid_Quote__c' => qte.Id,
          'Grid_StartDate__c' => System.today(),
          'Grid_ScheduleCount__c' => 4,
          'Grid_ScheduleFrequency__c' => 'Monthly'
        },
        false
      );
      List<DeliveryPlan__c> deliveryPlanList = new List<DeliveryPlan__c>();
      deliveryPlanList.add(deliveryPlan);
      Set<Id> QuoteIds = new Set<Id>();
      QuoteIds.add(qte.Id);
      Grid_QuoteServiceClass.createProductSchedule(deliveryPlanList, QuoteIds);
      Test.stopTest();

      List<ProductSchedule__c> productSchedules = [
        SELECT Id, Grid_QuoteLineItem__c, Name
        FROM ProductSchedule__c
        WHERE Grid_QuoteLineItem__c = :qlis[0].Id
      ];
      System.assertEquals(
        4,
        productSchedules.size(),
        'No product schedules were created'
      );
      System.assertEquals(
        DateTime.newInstance(
            System.today().year(),
            System.today().month(),
            System.today().day()
          )
          .format('MMM') + -+System.today().year(),
        productSchedules[0].Name,
        'Wrong product schedule name'
      );
    }
  }
  @IsTest
  static void testCreateProductSchedulesYearly() {
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

      DeliveryPlan__c deliveryPlan = (DeliveryPlan__c) TestDataFactory.createSObject(
        'DeliveryPlan__c',
        new Map<String, Object>{
          'Grid_Quote__c' => qte.Id,
          'Grid_StartDate__c' => System.today(),
          'Grid_ScheduleCount__c' => 5,
          'Grid_ScheduleFrequency__c' => 'Yearly'
        },
        false
      );
      List<DeliveryPlan__c> deliveryPlanList = new List<DeliveryPlan__c>();
      deliveryPlanList.add(deliveryPlan);
      Set<Id> QuoteIds = new Set<Id>();
      QuoteIds.add(qte.Id);
      Grid_QuoteServiceClass.deleteProductSchedule(deliveryPlanList);
      Grid_QuoteServiceClass.createProductSchedule(deliveryPlanList, QuoteIds);
      Test.stopTest();

      List<ProductSchedule__c> productSchedules = [
        SELECT Id, Grid_QuoteLineItem__c, Name
        FROM ProductSchedule__c
        WHERE Grid_QuoteLineItem__c = :qlis[0].Id
      ];
      System.assertEquals(
        5,
        productSchedules.size(),
        'No product schedules were created'
      );
      System.assertEquals(
        DateTime.newInstance(
            System.today().year(),
            System.today().month(),
            System.today().day()
          )
          .format('YYYY'),
        productSchedules[0].Name,
        'Wrong product schedule name'
      );
    }
  }
  @IsTest
  static void testDeleteProductSchedules() {
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

      DeliveryPlan__c deliveryPlan = (DeliveryPlan__c) TestDataFactory.createSObject(
        'DeliveryPlan__c',
        new Map<String, Object>{
          'Grid_Quote__c' => qte.Id,
          'Grid_StartDate__c' => System.today(),
          'Grid_ScheduleCount__c' => 5,
          'Grid_ScheduleFrequency__c' => 'Yearly'
        },
        false
      );
      List<DeliveryPlan__c> deliveryPlanList = new List<DeliveryPlan__c>();
      deliveryPlanList.add(deliveryPlan);
      Set<Id> QuoteIds = new Set<Id>();
      QuoteIds.add(qte.Id);
      Grid_QuoteServiceClass.createProductSchedule(deliveryPlanList, QuoteIds);
      Test.stopTest();
      List<ProductSchedule__c> productSchedules = [
        SELECT Id, Grid_QuoteLineItem__c, Name
        FROM ProductSchedule__c
        WHERE Grid_QuoteLineItem__c = :qlis[0].Id
      ];
      System.assertEquals(
        5,
        productSchedules.size(),
        'Product schedules were not deleted'
      );
    }
  }
  @IsTest
  static void testCreateRevenueSchedulesSoftware(){
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      Test.startTest();
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

      Quotelineitem qli = (Quotelineitem) TestDataFactory.createSObject(
        'Quotelineitem',
        new Map<String, Object>{
          'QuoteId' => qte.Id,
          'Quantity' => 3,
          'Product2' => prod,
          'PricebookEntryId' => priceBook.Id,
          'vlocity_cmt__OneTimeTotal__c' => 1000,
          'Grid_RecurringTotalYearly__c'=> 200,
          'vlocity_cmt__RecurringTotal__c' => 25
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

      Revenue__c revenueWithAllFields = [
        SELECT Id, Grid_Quote__c, Grid_Version__c, Grid_StartDate__c, Grid_EndDate__c, Grid_Count__c
        FROM Revenue__c
        WHERE Id = :revenue.Id
      ];

      List<Revenue__c> revenueList = new List<Revenue__c>();
      revenueList.add(revenueWithAllFields);
      Set<Id> QuoteIds = new Set<Id>();
      QuoteIds.add(qte.Id);

      Grid_QuoteServiceClass.createRevenueSchedule(revenueList,QuoteIds);
      Test.stopTest();

      List<Grid_RevenueSchedule__c> revenueSchedules = [
        SELECT Id, Grid_QuoteLineItem__c, Name
        FROM Grid_RevenueSchedule__c
        WHERE Grid_QuoteLineItem__c = :qli.Id
      ];
      System.assertEquals(
        12,
        revenueSchedules.size(),
        'No revenue schedules were created'
      );
    }
  }

  @IsTest
  static void testCreateRevenueSchedulesHardware(){
    System.runAs(TestDataFactory.createGridspertiseUser()) {
      Test.startTest();
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

      DeliveryPlan__c deliveryPlanWithAllFields = [
        SELECT Id, Grid_Quote__c, Grid_Version__c, Grid_StartDate__c, Grid_EndDate__c, Grid_ScheduleCount__c, Grid_ScheduleFrequency__c
        FROM DeliveryPlan__c
        WHERE Id = :deliveryPlan.Id
      ];
      List<DeliveryPlan__c> deliveryPlanList = new List<DeliveryPlan__c>();
      deliveryPlanList.add(deliveryPlanWithAllFields);

      Revenue__c revenueWithAllFields = [
        SELECT Id, Grid_Quote__c, Grid_Version__c, Grid_StartDate__c, Grid_EndDate__c, Grid_Count__c
        FROM Revenue__c
        WHERE Id = :revenue.Id
      ];

      List<Revenue__c> revenueList = new List<Revenue__c>();
      revenueList.add(revenueWithAllFields);
      Set<Id> QuoteIds = new Set<Id>();
      QuoteIds.add(qte.Id);

      Grid_QuoteServiceClass.createHWRevenueSchedule(revenueList, QuoteIds);
      Test.stopTest();

      List<Grid_RevenueSchedule__c> revenueSchedules = [
        SELECT Id, Grid_QuoteLineItem__c, Name
        FROM Grid_RevenueSchedule__c
        WHERE Grid_QuoteLineItem__c = :qli.Id
      ];
      System.assertEquals(
        4,
        revenueSchedules.size(),
        'No revenue schedules were created'
      );
    }
  }
}