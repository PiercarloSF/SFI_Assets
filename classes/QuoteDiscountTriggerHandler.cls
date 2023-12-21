public class QuoteDiscountTriggerHandler {
    public static void checkAddressCityProvinceInsert(List<vlocity_cmt__QuoteDiscountPricing__c > leads) {  
        
        Set<Id> QuoteIds = new Set<Id>();
        List<vlocity_cmt__QuoteDiscount__c> ListDeliv22=new List<vlocity_cmt__QuoteDiscount__c>();
        
        for (vlocity_cmt__QuoteDiscountPricing__c dlp : leads) {
            QuoteIds.add(dlp.vlocity_cmt__QuoteDiscountId__c);                   
            
        }
        
        
        List<vlocity_cmt__QuoteDiscount__c> ListDeliv2=[select Id,(select id,vlocity_cmt__AdjustmentValue__c from vlocity_cmt__QuoteDiscountPricing__r),vlocity_cmt__ApprovalStatus__c,vlocity_cmt__DiscountType__c,
                                                        vlocity_cmt__QuoteId__c,CreatedById,CreatedBy.ManagerId FROM vlocity_cmt__QuoteDiscount__c 
                                                        WHERE Id IN:QuoteIds];                    
        
        
        for (vlocity_cmt__QuoteDiscount__c  lead : ListDeliv2) {
            for(vlocity_cmt__QuoteDiscountPricing__c qli1 : lead.vlocity_cmt__QuoteDiscountPricing__r){
                system.debug(qli1.vlocity_cmt__AdjustmentValue__c);
                
                if(lead.vlocity_cmt__DiscountType__c=='Account')
                {
                    if(qli1.vlocity_cmt__AdjustmentValue__c>=-10)
                    {                        
                    lead.vlocity_cmt__ApprovalStatus__c= 'Approved'; 
                    ListDeliv22.add(lead);
                    system.debug(qli1.vlocity_cmt__AdjustmentValue__c);
                }}
                if(lead.vlocity_cmt__DiscountType__c=='Order')
                {
                    if(qli1.vlocity_cmt__AdjustmentValue__c>=-10)
                    {                      
                    lead.vlocity_cmt__ApprovalStatus__c= 'Approved';
                    
                    ListDeliv22.add(lead);
                }}
                if(lead.vlocity_cmt__DiscountType__c=='Contract')
                {
                    if(qli1.vlocity_cmt__AdjustmentValue__c>=-10)
                    {                       
                        lead.vlocity_cmt__ApprovalStatus__c= 'Approved';
                        ListDeliv22.add(lead);
                    }
                }
                
                lead.Adjustment_Value__c=qli1.vlocity_cmt__AdjustmentValue__c;
                
            }}
        update ListDeliv22;
        
    } 
    public static void updateAdjustValue(List<vlocity_cmt__QuoteDiscountPricing__c > leads) {
        
        Set<Id> QuoteIds = new Set<Id>();
        List<vlocity_cmt__QuoteDiscount__c> ListDeliv22=new List<vlocity_cmt__QuoteDiscount__c>();
        
        for (vlocity_cmt__QuoteDiscountPricing__c dlp : leads) {
            QuoteIds.add(dlp.vlocity_cmt__QuoteDiscountId__c);                  
            
        }
        
        
        List<vlocity_cmt__QuoteDiscount__c> ListDeliv2=[select Id,(select id,vlocity_cmt__AdjustmentValue__c from vlocity_cmt__QuoteDiscountPricing__r),vlocity_cmt__ApprovalStatus__c,vlocity_cmt__DiscountType__c,
                                                        vlocity_cmt__QuoteId__c,CreatedById,CreatedBy.ManagerId FROM vlocity_cmt__QuoteDiscount__c 
                                                        WHERE Id IN:QuoteIds];                    
        
        for (vlocity_cmt__QuoteDiscount__c  lead : ListDeliv2) {
            for(vlocity_cmt__QuoteDiscountPricing__c qli1 : lead.vlocity_cmt__QuoteDiscountPricing__r){
                system.debug(qli1.vlocity_cmt__AdjustmentValue__c);
                                lead.Adjustment_Value__c=qli1.vlocity_cmt__AdjustmentValue__c;

                ListDeliv22.add(lead);
                
            }}
        update ListDeliv22;
        
    }
    
}