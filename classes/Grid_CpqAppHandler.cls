global with sharing class Grid_CpqAppHandler implements vlocity_cmt.VlocityOpenInterface {
    
    global boolean invokeMethod(String methodName, Map<String, object> inputMap, Map<String, object> outputMap, Map<String, object> optionsMap){
        Boolean result = true;
        
        try {

            if(methodName.equalsIgnoreCase('ApplyAdjustmentCustom')) { 
                ApplyAdjustmentCustom(inputMap, outputMap, optionsMap);
            }
        } 
        catch(Exception e){
            return false;
        }
        
        return result;
    }
    
    public void ApplyAdjustmentCustom(Map<String, object> input, Map<String, object> output, Map<String, object> options) {
        
        List<String> inputs = ((String)input.get('id')).split(':');   
        String Id = inputs[0];
        String cartId = (String)input.get('cartId');
        adjustment adj = new adjustment(inputs);
        List<adjustment> adjustments = new List<adjustment>();
        adjustments.add(adj);
        input = new Map<String, object>();
        input.put('cartId', cartId);
        input.put('id', Id);       
        
        List<Object> obj = new List<Object>();
        Map<String,Object> inputtt = new Map<String,Object>();
        inputtt.put('AdjustmentCode','');
        inputtt.put('AdjustmentMethod',adj.AdjustmentMethod);
        inputtt.put('AdjustmentType',adj.AdjustmentType);
        inputtt.put('AdjustmentValue',adj.AdjustmentValue);
        inputtt.put('DetailType',adj.DetailType);
        inputtt.put('PricingVariableCode',adj.PricingVariableCode);
        inputtt.put('Field',adj.Field);
        obj.add((Map<String,Object>)inputtt);
        input.put('adjustments', obj);
        try{
            vlocity_cmt.CpqAppHandler hand = new vlocity_cmt.CpqAppHandler(); 
            hand.invokeMethod('applyAdjustment', input, output, options);    
        }catch(Exception e){
            System.debug('****Exception: '+e.getMessage());
        }
    } 
    
    public class adjustment {
        @AuraEnabled
        public String AdjustmentCode;
        @AuraEnabled
        public String AdjustmentMethod;
        @AuraEnabled
        public String AdjustmentType;
        @AuraEnabled
        public Decimal AdjustmentValue;
        @AuraEnabled
        public String DetailType;
        @AuraEnabled
        public String Field ;
        @AuraEnabled
        public String PricingVariableCode;
        @AuraEnabled
        public String ValueSignType;
    
        public adjustment(List<String> inputs){
            AdjustmentCode  = '';
            AdjustmentMethod  = inputs[3];
            Field = inputs[1]; 
            AdjustmentType = inputs[6] == 'A'?'Adjustment':'Override';
            //Change request: accept only (+)Upcharge for manual adjustment 
            //if(inputs[4] == 'Discount'){
                 //AdjustmentValue  = -1 *  Decimal.valueOf(inputs[5]);
            //}else{
            AdjustmentValue = Decimal.valueOf(inputs[5]); 
            //}         
            DetailType = inputs[6] == 'A'?'ADJUSTMENT': 'OVERRIDE';
            PricingVariableCode   = inputs[2];
            ValueSignType  = inputs[4];  
        }
    }
}