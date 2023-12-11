trigger QuoteDiscountPricingTrigger on vlocity_cmt__QuoteDiscountPricing__c (after insert) {
     if (Trigger.isAfter) {
        QuoteDiscountTriggerHandler.checkAddressCityProvinceInsert(Trigger.new);
    } 

}