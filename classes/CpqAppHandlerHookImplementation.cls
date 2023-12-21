global without sharing class CpqAppHandlerHookImplementation implements vlocity_cmt.VlocityOpenInterface
{
    global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)
    {
        try
        {   
            if (
                methodName == 'getCartsItems.PreInvoke' 
                || methodName == 'postCartsItems.PreInvoke' 
                || methodName == 'putCartsItems.PreInvoke'
                || methodName == 'getCartLineItemPrices.PreInvoke' 
            )  
            {
                String allFields = 'Grid_isOrder__c,OpenMeterFormula__c,isChildQuote__c,Grid_IsChild__c,vlocity_cmt__OneTimeCost__c,vlocity_cmt__RecurringCost__c,Grid_Recurring_Cost_Yearly__c,vlocity_cmt__OneTimeCharge__c,vlocity_cmt__RecurringCharge__c,Grid_RecurringChargeYearly__c,vlocity_cmt__OneTimeTotal__c,Grid_RecurringTotalYearly__c, Grid_Recurring_Cost_Total_Yearly__c, Grid_CurrencySymbol__c,Grid_Recurring_Margin_Yearly__c,vlocity_cmt__RecurringTotal__c,vlocity_cmt__OneTimeCostTotal__c,vlocity_cmt__OneTimeMargin__c,vlocity_cmt__RecurringCostTotal__c, Grid_RecurringMargin__c, Grid_OneTimeMargin__c, Grid_RecurringMarginYearly__c';
                String customFields ='Grid_RecurringChargeYearly__c, Grid_Recurring_Cost_Yearly__c, Grid_Recurring_Margin_Yearly__c, Grid_RecurringTotalYearly__c, Grid_Recurring_Cost_Total_Yearly__c, Grid_CurrencySymbol__c, Grid_Effective_RecurringCostTotal_Yearly__c, Grid_EffectiveRecurringTotalYearly__c, Grid_Recurring_Margin_Yearly__c, Grid_RecurringMargin__c, Grid_OneTimeMargin__c, Grid_RecurringMarginYearly__c';
                if (String.isNotBlank((String)input.get('fields'))){
                    input.put('fields', input.get('fields') + ',' + customFields);
                }else{
                    input.put('fields', allFields);
                }
                if (String.isNotBlank((String)input.get('priceDetailsFields'))){
                    input.put('priceDetailsFields', input.get('priceDetailsFields') + ',' + customFields);
                }else{ 
                    input.put('priceDetailsFields',allFields);
                }
                
            } 
            return true;
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
}