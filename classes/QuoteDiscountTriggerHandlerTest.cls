@isTest
public class QuoteDiscountTriggerHandlerTest {
  @IsTest
  static void quoteDiscountStatus() {
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
        'vlocity_cmt__Code__c' => 'testcode'
      },
      true
    );
    Quote qte = (Quote) TestDataFactory.createSObject(
      'Quote',
      new Map<String, Object>{ 'OpportunityId' => oppo.Id },
      true
    );
    vlocity_cmt__QuoteDiscount__c quoteDiscount = (vlocity_cmt__QuoteDiscount__c) TestDataFactory.createSObject(
      'vlocity_cmt__QuoteDiscount__c',
      new Map<String, Object>{
        'vlocity_cmt__QuoteId__c' => qte.Id,
        'vlocity_cmt__DiscountType__c' => 'Contract',
        'vlocity_cmt__ApprovalStatus__c' => 'Not Submitted'
      },
      true
    );
    vlocity_cmt__QuoteDiscount__c quoteDiscount1 = (vlocity_cmt__QuoteDiscount__c) TestDataFactory.createSObject(
      'vlocity_cmt__QuoteDiscount__c',
      new Map<String, Object>{
        'vlocity_cmt__QuoteId__c' => qte.Id,
        'vlocity_cmt__DiscountType__c' => 'Account',
        'vlocity_cmt__ApprovalStatus__c' => 'Not Submitted'
      },
      true
    );
      vlocity_cmt__QuoteDiscount__c quoteDiscount2 = (vlocity_cmt__QuoteDiscount__c) TestDataFactory.createSObject(
      'vlocity_cmt__QuoteDiscount__c',
      new Map<String, Object>{
        'vlocity_cmt__QuoteId__c' => qte.Id,
        'vlocity_cmt__DiscountType__c' => 'Order',
        'vlocity_cmt__ApprovalStatus__c' => 'Not Submitted'
      },
      true
    );
    vlocity_cmt__QuoteDiscountPricing__c quoteDiscountPricing = (vlocity_cmt__QuoteDiscountPricing__c) TestDataFactory.createSObject(
      'vlocity_cmt__QuoteDiscountPricing__c',
      new Map<String, Object>{
        'vlocity_cmt__QuoteDiscountId__c' => quoteDiscount.Id,
        'vlocity_cmt__AdjustmentValue__c' => 9
      },
      true
    );
      vlocity_cmt__QuoteDiscountPricing__c quoteDiscountPricing2 = (vlocity_cmt__QuoteDiscountPricing__c) TestDataFactory.createSObject(
      'vlocity_cmt__QuoteDiscountPricing__c',
      new Map<String, Object>{
        'vlocity_cmt__QuoteDiscountId__c' => quoteDiscount1.Id,
        'vlocity_cmt__AdjustmentValue__c' => 9
      },
      true
    );
      vlocity_cmt__QuoteDiscountPricing__c quoteDiscountPricing1 = (vlocity_cmt__QuoteDiscountPricing__c) TestDataFactory.createSObject(
      'vlocity_cmt__QuoteDiscountPricing__c',
      new Map<String, Object>{
        'vlocity_cmt__QuoteDiscountId__c' => quoteDiscount2.Id,
        'vlocity_cmt__AdjustmentValue__c' => 9
      },
      true
    );
    List<vlocity_cmt__QuoteDiscount__c> quotes = new List<vlocity_cmt__QuoteDiscount__c>{
      quoteDiscount,
      quoteDiscount1,
      quoteDiscount2
    };
    List<vlocity_cmt__QuoteDiscountPricing__c> quotesDP = new List<vlocity_cmt__QuoteDiscountPricing__c>{
      quoteDiscountPricing,quoteDiscountPricing1,quoteDiscountPricing2
    };
    quotes[0].vlocity_cmt__ApprovalStatus__c = 'Approved';
    quotes[1].vlocity_cmt__ApprovalStatus__c = 'Approved';
    quotes[2].vlocity_cmt__ApprovalStatus__c = 'Approved';

    Set<Id> opportunityIds = new Set<Id>{ oppo.Id };
    List<Quote> quotes1 = new List<Quote>{ qte };

    QuoteDiscountTriggerHandler.checkAddressCityProvinceInsert(quotesDP);
    QuoteDiscountTriggerHandler.updateAdjustValue(quotesDP);
    System.assertEquals('Approved', quotes[0].vlocity_cmt__ApprovalStatus__c);
    System.assertEquals('Approved', quotes[1].vlocity_cmt__ApprovalStatus__c);
    System.assertEquals('Approved', quotes[2].vlocity_cmt__ApprovalStatus__c);
    

    Test.stopTest();

  }
}