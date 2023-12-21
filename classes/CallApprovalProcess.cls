/**
* This class provides utilities to use as remote actions
*  
* @author	AES
* @version	1.0
*
*
*/

global class CallApprovalProcess implements vlocity_cmt.VlocityOpenInterface2 {
    
    
    global Boolean invokeMethod(String methodName, Map<String,Object> input, Map<String,Object> output, Map<String,Object> options) {
        try {      
            if (methodName == 'generateApprovalStatus') return generateApprovalStatus(input, output, options);          
        }
        catch (Exception e) {                       
            output.put('error', e.getMessage() + ':' + e.getStackTraceString());
        }
        return false;
    }
    private Boolean generateApprovalStatus(Map<String,Object> input, Map<String,Object> output, Map<String,Object> options) {
        String methodName;
        Id quoteId=(Id)input.get('quoteId');
        List<vlocity_cmt__QuoteDiscount__c> ListDeliv2=new List<vlocity_cmt__QuoteDiscount__c>();
        Id userId1=UserInfo.getUserId();
        for(vlocity_cmt__QuoteDiscount__c qli: [select Id,(select id,vlocity_cmt__AdjustmentValue__c from vlocity_cmt__QuoteDiscountPricing__r),vlocity_cmt__ApprovalStatus__c,vlocity_cmt__DiscountType__c,
                                                vlocity_cmt__QuoteId__c,CreatedById,CreatedBy.ManagerId FROM vlocity_cmt__QuoteDiscount__c 
                                                WHERE vlocity_cmt__QuoteId__c=:quoteId and vlocity_cmt__ApprovalStatus__c='Not Submitted']){
                                                    for(vlocity_cmt__QuoteDiscountPricing__c qli1 : qli.vlocity_cmt__QuoteDiscountPricing__r){
                                                        if(qli1.vlocity_cmt__AdjustmentValue__c<-10 && qli1.vlocity_cmt__AdjustmentValue__c>=-15 ){
                                                            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                                                            req1.setObjectId(qli.Id);
                                                            req1.setSubmitterId(qli.CreatedBy.ManagerId);
                                                            req1.setProcessDefinitionNameOrId('QuoteDiscountApprovalV4');
                                                            Approval.ProcessResult result = Approval.process(req1);   
                                                        }
                                                        else if(qli1.vlocity_cmt__AdjustmentValue__c<-15 && qli1.vlocity_cmt__AdjustmentValue__c>=-20 ){
                                                            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                                                            req1.setObjectId(qli.Id);
                                                            req1.setSubmitterId(qli.CreatedBy.ManagerId);
                                                            req1.setProcessDefinitionNameOrId('QuoteDiscountApprovalV4');
                                                            Approval.ProcessResult result = Approval.process(req1);   
                                                        }
                                                        else if(qli1.vlocity_cmt__AdjustmentValue__c<-20 ){
                                                            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                                                            req1.setObjectId(qli.Id);
                                                            req1.setSubmitterId(qli.CreatedBy.ManagerId);
                                                            req1.setProcessDefinitionNameOrId('QuoteDiscountApprovalV4');
                                                            Approval.ProcessResult result = Approval.process(req1);   
                                                        }
                                                    }  
                                                }         
        return true;
    }
    
}