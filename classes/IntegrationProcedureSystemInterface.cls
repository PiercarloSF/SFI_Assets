/**
* This class to customize XOMEnhancedSystemInterface to use a VIP 
*  
* @author   AES
* @version  1.0   
*
*
*/
global virtual class IntegrationProcedureSystemInterface  extends vlocity_cmt.XOMEnhancedSystemInterface {
    
    global override void executeItem(String url, String path, vlocity_cmt__OrchestrationItem__c item) {
       
       // Get the Order SObject - the technique will differ depending on if this orchestration item is related to an Order Item or a Fulfillment Request Line
       Id orderId = null;
       if (item.vlocity_cmt__OrderItemId__c != null) orderId = item.vlocity_cmt__OrderItemId__r.OrderId;
       else {           
           vlocity_cmt__OrchestrationItem__c orchItem = [SELECT vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.Id FROM vlocity_cmt__OrchestrationItem__c WHERE Id = :item.Id];
           orderId = orchItem.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.Id;
       }
       vlocity_cmt.XOMOrderDomainObject orderObj = ((vlocity_cmt.XOMOrderService)vlocity_cmt.XOMObjectFactory.getService(Order.SObjectType)).getObject(orderId, true);
       Map<String, Object> ipInput   = (Map<String, Object>)JSON.deserializeUntyped(super.generatePayload(item, orderObj));
       Map<String, Object> ipOptions = new Map<String, Object>(); 
       
       // Add any extra information to the payload that might be useful and otherwise not available via the DataRaptors configured in the Callout
       ipInput.put('orchestration_item_id',   item.Id);
       
       ipInput.put('orchestration_item_name', item.Name); 
       string access_token = Grid_Integration.authWithEpic('getToken',new Map<String, Object>(),new Map<String, Object>(), new Map<String, Object>());
       ipInput.put('Token', access_token);
       // Call the Integration Procedure
       Map<String, Object> ipOutput = new Map<String, Object>(); 
       try{
            ipOutput = (Map <String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(path, ipInput, ipOptions);              
       }catch(CalloutException e){
           throw new vlocity_cmt.XOMOrchestrationInterfaces.SystemInterfaceRecoverableException ('Callout exception  ' + e + ': trying to retry');    
       }
       
       // process any response
       processResponse(item, ipInput, ipOutput);
   }
   /**
    * This method is called from executeItem to handle the response from the Integration Procedure.
    * By default it does nothing (but some logging), but it could be customized to do something more.
    *
    * @param item      The Orchestration Item
    * @param ipInput   The request sent to the Integration Procedure
    * @param ipOutput  The response from the Integration Procedure
    */
   global virtual void processResponse(vlocity_cmt__OrchestrationItem__c item, Map<String, Object> ipInput, Map<String, Object> ipOutput) {
      
       // For debugging, store the Request in the Orchestration Item SObject
       item.vlocity_cmt__Request__c = JSON.serialize(ipInput);
       item.vlocity_cmt__Response__c = JSON.serialize(ipOutput);
       update item;
       
       Object success = ipOutput.get('success');
       Map<String,Object> info = (Map<String,Object>)ipOutput.get('info');
       String errorCode = '';
       String message = '';
       
       if(info != null){
           errorCode = (String)info.get('statusCode'); 
           message = (String)info.get('status');
       } 
       if(success == 'false'){
           throw new vlocity_cmt.XOMOrchestrationInterfaces.SystemInterfaceRecoverableException('IP Failed with error: '+errorCode+', message: '+message);   
       }       
   }
     
}