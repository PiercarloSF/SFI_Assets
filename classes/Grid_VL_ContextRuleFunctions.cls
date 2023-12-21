global class Grid_VL_ContextRuleFunctions implements vlocity_cmt.VlocityOpenInterface2 {
    
    public final static string KEY_RESULT = 'result';
    public final static string KEY_ARGUMENTS = 'arguments'; //this is set in the input map by Vlocity
    
    global Boolean invokeMethod(String methodName, Map<String,Object> input, Map<String,Object> output, Map<String,Object> options) {
        Boolean result = true;
        try {      
            if (methodName == 'getContractProduct') 
                output.put('result', getContractProduct(input));  
                   // if (methodName == 'getPriceProduct') return getPriceProduct(input, output, options); 

        }
        catch (Exception e) {                       
            result = false;        
        }
        return result; 
    
        
        

    }
    
    private Boolean getContractProduct(Map<String,Object> input) {
        String methodName;
        List<Object> arguments = (List<Object>) input.get(KEY_ARGUMENTS);
        Id orderId=(Id)arguments.get(0);
        Id productId=(Id)arguments.get(1);
        Boolean result = false;
        if(orderId!= null) {
            
            Order ord=[select Id,ContractId FROM Order WHERE Id=:orderId];
            
            
            
            List<vlocity_cmt__ContractLineItem__c> gridContractLineItems = [
                SELECT Id, Name, vlocity_cmt__ContractId__c,vlocity_cmt__QuoteLineItem__r.vlocity_cmt__ParentItemId__c,
                vlocity_cmt__QuoteLineItem__r.vlocity_cmt__RootItemId__c,vlocity_cmt__Product2Id__r.ProductCode,
                vlocity_cmt__Product2Id__c 
                FROM vlocity_cmt__ContractLineItem__c
                WHERE vlocity_cmt__ContractId__c =:ord.ContractId
            ];
            
            for (vlocity_cmt__ContractLineItem__c gridContractLineItem : gridContractLineItems) {
                
                if(gridContractLineItem.vlocity_cmt__Product2Id__c==(Id)productId) {
                    result=true;
                }
            }
        }
        
        else {
            result=true;
        }
        
        return result;
    }
     /*private Boolean getPriceProduct(Map<String,Object> input, Map<String,Object> output, Map<String,Object> options) {
        String methodName;
        List<Object> arguments = (List<Object>) input.get(KEY_ARGUMENTS);
        Id orderId=(Id)input.get('orderId');
        //Id productId=(Id)arguments.get(1);
        //Boolean result = false;
        if(orderId!= null) {
            
            Order ord=[select Id,ContractId FROM Order WHERE Id=:orderId];
            
            
            
            List<vlocity_cmt__ContractLineItem__c> gridContractLineItems = [
                SELECT Id, Name, vlocity_cmt__ContractId__c,vlocity_cmt__QuoteLineItem__r.vlocity_cmt__ParentItemId__c,
                vlocity_cmt__Product2Id__c,OpenMeterFormula__c,vlocity_cmt__OneTimeCharge__c,vlocity_cmt__OneTimeTotal__c 
                FROM vlocity_cmt__ContractLineItem__c
                WHERE vlocity_cmt__ContractId__c =:ord.ContractId and vlocity_cmt__QuoteLineItem__r.vlocity_cmt__ParentItemId__c != null
            ];
            system.debug('list contract line item : '+gridContractLineItems);
            
            for (vlocity_cmt__ContractLineItem__c gridContractLineItem : gridContractLineItems) {
                
                 system.debug('Model : '+gridContractLineItem.OpenMeterFormula__c);
                 system.debug('One time : '+gridContractLineItem.vlocity_cmt__OneTimeCharge__c);
                 system.debug('One time total : '+gridContractLineItem.vlocity_cmt__OneTimeTotal__c);


            }
        }
        
        
        return true;
    }*/
}